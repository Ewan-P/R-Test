
#####  Configure Environment 

# Site Specific Information
site_code <- "ECC" #See below for alternatives
validsitecodes <- c("SR2","ECC")

#Directories
d_home <- "/home/rstudio/R-Test/"  #Only vaid for AWS - RStudio - Server
d_raw <- paste(d_home, "raw/", site_code, "/", sep = "") #Only vaid for AWS - RStudio - Server
d_intermed <- paste(d_home, "intermed/", site_code, "/", sep = "")  #Only vaid for AWS - RStudio - Server
d_tidy <- paste(d_home, "tidy/", site_code, "/", sep = "") #Only valid for AWS - RStudio - Server
d_output <- paste(d_home, "output/", sep = "")   #Only vaid for AWS - RStudio - Server

#  Use tidyvers functions
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
