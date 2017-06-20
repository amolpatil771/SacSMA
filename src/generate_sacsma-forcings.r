#===========================================================
# Name: Disaggregate Sac-SMA Forcing Files
# Author: D. Broman, USBR Technical Service Center
# Last Modified: 2017-05-18
# Description: Reads in disaggregated temperature and precipitation
# and calculated reference ET and writes out data in Sac-SMA
# card format - MAT, MAP, MAPE
#===========================================================
# Load Libraries:
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(lubridate)
library(data.table)
library(tools)
library(ncdf4)
library(gdata)
library(doParallel)
library(foreach)
library(splitstackshape)

#===========================================================
# User Inputs

#- Working Directory 
setwd('/work/dbroman/projects/salt_river_sro/process_loca/')
outdir = 'data/processed/sacsma/hourly/'
#- Period Inputs (mcp3 has issues generating long simulations; this allows for splitting the run into multiple periods)

#-'a' period
year_start_a = 1950
month_start_a = 1
year_end_a = 2050
month_end_a = 12
year_offset_a = -20 

#-'b' period
year_start_b = 2002
month_start_b = 1
year_end_b = 2099
month_end_b = 12
year_offset_b = -72

#-Basin and Zone List
basinzone_file_path = 'lib/basinzone_list.txt'

#- Projection File List
projection_file_path = 'lib/loca_run_list.txt'

#===========================================================
# Set Up Run

date_start_a = as.Date(paste(year_start_a, month_start_a, '01', sep = '-'))
date_end_a = as.Date(paste(year_end_a, month_end_a, '31', sep = '-')) 
date_tbl_a = data.table(date = seq(from = date_start_a, to = date_end_a, by = 'day')) %>% mutate(year = year(date), month = month(date)) %>% group_by(year, month) %>% mutate(nday = n()) %>% mutate(yrmn = str_pad(paste0(month, substr(year + year_offset_a, 3,4)), side = 'left', width = 4, pad = ' '), rowind = ceiling(nday * 4 / 6)) %>% mutate(nele = rowind * 6 - nday * 4, mapind = nday * 4) %>% dplyr::select(year, month, yrmn, rowind, nele, mapind) %>% ungroup() %>% distinct()
date_tbl_a2 = data.table(date = seq(from = date_start_a, to = date_end_a, by = 'day')) %>% mutate(year = year(date), month = month(date)) %>% group_by(year, month) %>% mutate(nday = n()) %>% mutate(yrmn = str_pad(paste0(month, substr(year + year_offset_a, 3,4)), side = 'left', width = 4, pad = ' '), rowind = ceiling(nday / 6)) %>% mutate(nele = rowind * 6 - nday, mapind = nday) %>% dplyr::select(year, month, yrmn, rowind, nele, mapind) %>% ungroup() %>% distinct()
datefile_a = paste0(year_start_a, year_end_a, '/')

date_start_b = as.Date(paste(year_start_b, month_start_b, '01', sep = '-'))
date_end_b = as.Date(paste(year_end_b, month_end_b, '31', sep = '-')) 
date_tbl_b = data.table(date = seq(from = date_start_b, to = date_end_b, by = 'day')) %>% mutate(year = year(date), month = month(date)) %>% group_by(year, month) %>% mutate(nday = n()) %>% mutate(yrmn = str_pad(paste0(month, substr(year + year_offset_b, 3,4)), side = 'left', width = 4, pad = ' '), rowind = ceiling(nday * 4 / 6)) %>% mutate(nele = rowind * 6 - nday * 4, mapind = nday * 4) %>% dplyr::select(year, month, yrmn, rowind, nele, mapind) %>% ungroup() %>% distinct()
date_tbl_b2 = data.table(date = seq(from = date_start_b, to = date_end_b, by = 'day')) %>% mutate(year = year(date), month = month(date)) %>% group_by(year, month) %>% mutate(nday = n()) %>% mutate(yrmn = str_pad(paste0(month, substr(year + year_offset_b, 3,4)), side = 'left', width = 4, pad = ' '), rowind = ceiling(nday / 6)) %>% mutate(nele = rowind * 6 - nday, mapind = nday) %>% dplyr::select(year, month, yrmn, rowind, nele, mapind) %>% ungroup() %>% distinct()
datefile_b = paste0(year_start_b, year_end_b, '/')

basinzone_list = scan(basinzone_file_path, what = character())
loca_run_list = scan('lib/loca_run_list.txt', what = 'character')
nset = length(loca_run_list)
for(iset in 1:nset) {
	set_sel = loca_run_list[iset]
  # remove hard coded data dir
  # set which inputs to use
  # set file extension
	map_sampled_1hr = readRDS(paste0('data/processed/sacsma/hourly/', set_sel, '.MAP01.rda'))
	mat_sampled_6hr = readRDS(paste0('data/processed/sacsma/hourly/', set_sel, '.MAT.rda'))
	mape_24hr = readRDS(paste0('data/processed/sacsma/hourly/', set_sel, '.MAPE.rda'))
	basinzone_list = unique(mape_24hr$basinzone)
	nbasinzone = length(basinzone_list)
	nmodeldays = length(unique(mat_sampled_6hr$date))
	
  output_dir = paste0(outdir, set_sel, '/')
	if(dir.exists(output_dir) == FALSE){
		dir.create(output_dir)
	}
	if(dir.exists(paste0(output_dir, datefile_a)) == FALSE){
		dir.create(paste0(output_dir, datefile_a))
	}
	if(dir.exists(paste0(output_dir, datefile_b)) == FALSE){
		dir.create(paste0(output_dir, datefile_b))
	}
# add in rest of code...	
}
