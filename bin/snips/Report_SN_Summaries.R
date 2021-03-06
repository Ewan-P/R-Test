################ Process xlsx from Stuart
# Routines to generate reports for ECC and Southrepps using data from SEN.
# EAP 2019-03-04
# Assumes original files have been:
#   imported,
#   tidied,
#   saved in the tidy sub-directory for each location
#   file names will be structured
#     YYYY-MM-DD_Summary_SEN_Evaluation_XXX.csv, where XXX is a valid site code
#  
# The input files have the following columns 
#   obs_datetime : date a time of the recording 
#   filename : relates to the original wav/wac file generated by the SM2
#   species : as identified by the classifier
#   confidence_index : as identified by the classifier, was called "accuracy"
#   real_error : as calculated by the classifier following methor in Barre et. al
# Structure of values in the filename column:
#   XXX             : chr > 3 digit site code  SR2 = Southrepps (Dowlands), ECC == Eccls
#   _               : chr > separator
#   yyyymmdd        : num > date of recording (assigned by SM2) ISO format
#   _               : chr > separator
#   hhmmss          : num > time of recording (assigned by SM2 no DST correction applied. hours since midnight)
#   _               : chr > separator
#   NNN              : num > 3 digit number assigned by classifier, thought to be the call number in the recording file.
#
# Processing will be required to:
#   load data files into a data.frame
#   
#   
#
# Input file are located in the following locations:
#   ~/R-Test/intermed/ECC, and
#   ~/R-Test/intermed/SR2
#
# Output files will be writen to the following locations:
#   ~/R-Test/tidy/ECC, and
#   ~/R-Test/tidy/SR2
#
# Output files will have the following structure:
#   2019-02-12_SEN_Evaluation_XXX.csv : where XXX is either ECC or SR2 as relevant
#
########  CONFIG Follows ##########################

# Load required libraries

# Load tidyvers functions
#if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
#library(readr)
#library(dplyr)
#library(purrr)
library(lubridate)
library(readxl) #Needed to process xlxs files
library(knitr)

#Evaluation parameters
re_threshold <-
  0.5 #Change this value to set required accuracy cut-off.
#In practice 0.5 is applied by Stuart when agreegating records.
save_csv <-
  TRUE #Change to FALSE if you don't want to create a new csv file
site_code <- "ECC" #See below for alternatives
input_file_pattern <- "*_Summary_SEN_Evaluation*"

#output_file_name <- "2019-02-28_SEN_Evaluation_SR2.csv"

#Directories  NB these are only vaid for AWS - RStudio - Server
d_home <- "~/R-Test/"
d_raw <-  paste(d_home, "raw/", site_code, "/", sep = "")
d_intermed <- paste(d_home, "intermed/", site_code, "/", sep = "")
d_tidy <- paste(d_home, "tidy/", site_code, "/", sep = "")
d_output <-   paste(d_home, "output/", sep = "")


# Site Specific Information
validsitecodes <- c("SR2", "ECC")


########  CODE Follows ##########################
# Check if we have a valid site code
if (!(site_code %in% validsitecodes))  {
  stop("Invalid Site Code")
}


# Configure Environment & paths etc.
setwd(d_home)
getwd()


# Read the input file
tmp_SNclassifier_results <- list.files(
  path = as.character(d_tidy),
  pattern = input_file_pattern,
  recursive = TRUE,
  full.names = TRUE
) %>%
  map_df(~ read_csv(.))



# Monthly Summary, results writen to tbl_mnlyStats
tbl_mnlyStats <- tmp_SNclassifier_results %>%
  dplyr::filter(., real_error >= re_threshold) %>%
  group_by(year(as.Date(obs_datetime, "%Y-%m-%d")),
           month(as.Date(obs_datetime, "%Y-%m-%d")),
           species) %>%
  dplyr::summarise(
    count = n(),
    max = max(confidence_index),
    mean = round(mean(confidence_index), 2),
    min = min(confidence_index),
    std_dev = round(sd(confidence_index), 2)
  )
names(tbl_mnlyStats)[1] <- "Year"
names(tbl_mnlyStats)[2] <- "Month"
tbl_mnlyStats <- as.data.frame(tbl_mnlyStats)


#Now generate species summaries
species_found <- unique(tbl_mnlyStats$species)
print(paste(site_code, "Evaluation by SN"))
for (row in 1:length(species_found)) {
  tmp_species <-
    filter(tbl_mnlyStats, species == species_found[row])
  print(knitr::kable(tmp_species))
  
}

#### NOTE NOTE NOTE ####
#
# To generate a pdf report from this process  it is not possible to use 
# the RStudio ctr-K short cut as this throws a number of errors.
# Instead use the following code entered at the console
#
# rmarkdown::render(paste(d_home,"bin/snips/Report_SN_Summaries.R", sep = ""), "pdf_document")
#
#### END END END ####