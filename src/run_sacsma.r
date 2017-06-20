#===========================================================
# Name: Run Sac-SMA
# Author: D. Broman, USBR Technical Service Center
# Last Modified: 2017-06-20
# Description: Sets up and runs Sac-SMA hydrology model
# Uses NWSRFS mcp3 executable
#===========================================================
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
# User Inputs:

#- Working Directory
setwd('/work/dbroman/projects/salt_river_sro/process_loca/')

#- Data Name (for output)
data_name = 'saltverde'
