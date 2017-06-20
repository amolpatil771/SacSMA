#===========================================================
# Name: Run Sac-SMA
# Author: D. Broman, USBR Technical Service Center
# Last Modified: 2017-06-20
# Description: Sets up and runs Sac-SMA hydrology model
# Uses NWSRFS mcp3 executable
#===========================================================
library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)
library(data.table)
library(tools)
library(doParallel)
library(foreach)

split_str_by_index <- function(target, index) {
  index <- sort(index)
  substr(rep(target, length(index) + 1),
         start = c(1, index),
         stop = c(index -1, nchar(target)))
}

#Taken from https://stat.ethz.ch/pipermail/r-help/2006-March/101023.html
interleave <- function(v1,v2)
{
  ord1 <- 2*(1:length(v1))-1
  ord2 <- 2*(1:length(v2))
  c(v1,v2)[order(c(ord1,ord2))]
}

insert_str <- function(target, insert, index) {
  insert <- insert[order(index)]
  index <- sort(index)
  paste(interleave(split_str_by_index(target, index), insert), collapse="")
}

#===========================================================
# User Inputs:

#- Working Directory
setwd('/work/dbroman/projects/salt_river_sro/process_loca/')
static_dir = 'data/static/'
matmap_dir = 'data/matmap/'
matmap_head = '/work/dbroman/projects/salt_river_sro/process_loca/data/processed/sacsma/hourly/'
sacsam_exe = '/awips/hydroapps/lx/rfc/nwsrfs/calb/bin/RELEASE/mcp3'
sacsam_exe = '/work/dbroman/scratch/lx/rfc/nwsrfs/calb/bin/RELEASE/mcp3'
timestep = 1 # in hours

#- Deck List
deck_file_path = 'lib/basinzone_list.txt'

#- Run Table (see description for format)
run_table_path = 'lib/sacsma_run_tbl.csv'

#- Data Name (for output)
data_name = 'saltverde'

#- Set Environmental Vars (currently doesn't work within R; export command needs to be run outside first before starting R)
system('export APPS_DEFAULTS_SITE=lib/Defaults')
system('export TMPDIR=tmp')

#===========================================================
# Set Up Run:

deck_list = scan(deck_file_path, what = character())
loca_run_list = scan(projection_file_path, what = 'character')
run_tbl = fread(run_table_path)

nruns = length(loca_run_list)
