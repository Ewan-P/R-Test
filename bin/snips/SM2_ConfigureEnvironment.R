
#####  Configure Environment 

# Cleanup packages
# http://r.789695.n4.nabble.com/Reset-R-s-library-to-base-packages-only-remove-all-installed-contributed-packages-td3596151.html

ip <- installed.packages()
pkgs.to.remove <- ip[!(ip[,"Priority"] %in% c("base", "recommended")), 1] 

# Clear global environment
# https://github.com/KevBarre/Semi-automated-method-to-account-for-identification-errors-in-biological-acoustic-surveys/blob/master/4_ErrorRate.R
rm(list = ls()) 

# Site Specific Information
site_code <- "SR2" #See below for alternatives
validsitecodes <- c("SR2","ECC")

#Directories
d_home <- "/home/rstudio/R-Test/"  #Only vaid for AWS - RStudio - Server
d_raw <- paste(d_home, "raw/", site_code, "/", sep = "") #Only vaid for AWS - RStudio - Server
d_intermed <- paste(d_home, "intermed/", site_code, "/", sep = "")  #Only vaid for AWS - RStudio - Server
d_tidy <- paste(d_home, "tidy/", site_code, "/", sep = "") #Only valid for AWS - RStudio - Server
d_output <- paste(d_home, "output/", sep = "")   #Only vaid for AWS - RStudio - Server

#  Use tidyvers functions
library(tidyverse)
library(readr)
library(dplyr)
library(purrr)
library(lubridate)

#Evaluation parameters
accuracy_filter <- 0.5 #Change this value to set required accuracy cut-off. In practice 0.5 is applied by Stuart when agreegating records.
columns2keep <- c("filename", "Barbar", "Eptser", "Myoalc", "Myobec", "Myobra", 
                  "Myodau", "Myomys", "Myonat", "Nyclei", "Nycnoc", "Pipnat", 
                  "Pippip", "Pippyg", "Pleaur", "Rhifer", "Rhihip", "FreqM", 
                  "FreqP", "FreqC", "Tstart", "Tend", "NbCris", "DurMed", 
                  "Dur90", "Ampm50", "Ampm90", "AmpSMd", "DiffME", "SR", 
                  "Order", "Ind", "SpMaxF2", "Version") #Used to select columnes from the IdTot.csv input files.

#Flags
SM2_Error <- c(FALSE, "All OK")

#Reference Files
LocalSpeciesList <- "Norfolk_Bat_Species_list.csv"
