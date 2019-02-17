################ Process xlsx from Stuart
# Routines to import and process xlsx files for ECC and Southrepps as supplied by SEN
# EAP 2019-02-14
# Files are called
#   2019-02-12_SN_EP_Classifier_results_SRepp.xlsx, and
#   2019-02-12_SN_EP_Classifier_results_Eccles.xlsx
#
# Files are delivered as Microsoft Excel .xlsx format
# Files have the following structure
#   filename        : chr > character string, see below for details.
#   species         : chr > 6 character string with species code
#   confidence_index: num > Confidence index assigned by the classifier range 0.00 to 1.00 (0.99?)
#   real_error      : num > Relative Error calculated by the classifier range 0.00 to 1.00 (0.99?) See Barrre et.al. 2018
#
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
#   load data xlsx into a data.frame
#   extract date & time from filename
#   create new column fo observation date/time
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
library(readxl) #Needed to process xlxs files
# Load tidyvers functions
library(readr)
library(dplyr)
library(purrr)
library(lubridate)


# Site Specific Information
validsitecodes <- c("SR2", "ECC")
site_code <- "SR2" #See below for alternatives


#Evaluation parameters
re_threshold <-
  0.5 #Change this value to set required accuracy cut-off. 
      #In practice 0.5 is applied by Stuart when agreegating records.


#Directories  NB these are only vaid for AWS - RStudio - Server
d_home <-
  "/home/rstudio/R-Test/"  
d_raw <-
  paste(d_home, "raw/", site_code, "/", sep = "") 
d_intermed <-
  paste(d_home, "intermed/", site_code, "/", sep = "")  
d_tidy <-
  paste(d_home, "tidy/", site_code, "/", sep = "") 
d_output <-
  paste(d_home, "output/", sep = "")   #


########  CODE Follows ##########################
# Configure Environment & paths etc.
setwd(d_home)


# NB  Following are hard coded paths rather than derived from site_code
ECC_sourcefile <-
  paste(d_home,
        "intermed/ECC/2019-02-12_SN_EAP_Classifier_results_Eccles.xlsx",
        sep = "")
SR2_sourcefile <-
  paste(d_home,
        "intermed/SR2/2019-02-12_SN_EAP_Classifier_results_SRepp.xlsx",
        sep = "")
ECC_outputfile <-
  paste(d_home, "tidy/ECC/2019-02-12_SEN_Evaluation_ECC.csv", sep = "")
SR2_outputfile <-
  paste(d_home, "tidy/SR2/2019-02-12_SEN_Evaluation_SR2.csv", sep = "")


# Read the files
# NB These functions are site specific so have hard coded pathes
SN_classifier_results_SR2 <- read_excel(SR2_sourcefile)
SN_classifier_results_ECC <- read_excel(ECC_sourcefile)


# Create the Date-Time column
# NB These functions are site specific so have hard coded pathes
SN_classifier_results_SR2 <- data.frame(obs_datetime = as.POSIXct(gsub(
  "_", "", substr(SN_classifier_results_SR2$filename, 5, 19)
), format = "%Y%m%d%H%M%S"),
SN_classifier_results_SR2)
SN_classifier_results_ECC <- data.frame(obs_datetime = as.POSIXct(gsub(
  "_", "", substr(SN_classifier_results_ECC$filename, 5, 19)
), format = "%Y%m%d%H%M%S"),
SN_classifier_results_ECC)


#write results to csv
# NB These functions are site specific so have hard coded pathes
write_csv(SN_classifier_results_ECC, ECC_outputfile, col_names = TRUE)
write_csv(SN_classifier_results_SR2, SR2_outputfile, col_names = TRUE)


# Monthly Summary, results writen to tbl_mnlyStats
# There must be a better way to group by year/ month
if (!(site_code %in% validsitecodes))  {
  stop("Invalid Site Code")
} else {
  if (site_code == "ECC") {
    tmp_input <-  SN_classifier_results_ECC
  } else  if (site_code == "SR2") {
    tmp_input <-  SN_classifier_results_SR2
  }
  tbl_mnlyStats <- tmp_input %>%
    filter(., real_error >= re_threshold) %>%
    group_by(year(as.Date(obs_datetime, "%Y-%m-%d")),
             month(as.Date(obs_datetime, "%Y-%m-%d")),
             species) %>%
    summarise(
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
}
