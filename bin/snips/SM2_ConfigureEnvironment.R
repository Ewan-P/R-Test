
#####  Configure Environment 

# Site Specific Information
site_code <- "ECC" 

#Directories
d_home <- "/home/rstudio"  #Only vaid for AWS - RStudio - Server
d_raw <- "/home/rstudio/R-Test/raw/ECC" #Only vaid for AWS - RStudio - Server
d_intermed <- "/home/rstudio/R-Test/intermed/ECC"  #Only vaid for AWS - RStudio - Server
d_tidy <- "/home/rstudio/R-Test/tidy/ECC"   #Only vaid for AWS - RStudio - Server
d_output <- "/home/rstudio/R-test/output"   #Only vaid for AWS - RStudio - Server

#  Use tidyvers functions
library(readr)
library(dplyr)
library(purrr)
library(lubridate)

#Evaluation parameters
accuracy_filter <- 0.6  #Change this value to set required accuracy cut-off. In practice 0.5 is applied by Stuart when agreegating records.
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
