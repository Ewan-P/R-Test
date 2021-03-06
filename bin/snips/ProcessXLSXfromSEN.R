################ Process xlsx from Stuart
# Routines to import and process xlsx files for ECC and Southrepps as supplied by SEN
# EAP 2019-02-14
# Files are called
#   2019-02-12_SN_EP_Classifier_results_SRepp.xlsx, and
#   2019-02-12_SN_EP_Classifier_results_Eccles.xlsx
##  Update ## 2019-02-28 a further file recieved for Southrepps for 2016 - 2018,
##  Update ## 2019-02-28, this file is called
#   2019-02-28_SN_EAP_Classifier_results_Southrepps2.xlsx
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

# Load tidyvers functions
#if (!require(tidyverse)) install.packages('tidyverse')
#library(tidyverse)
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
site_code <- "SR2" #See below for alternatives
input_file_name <-
  "2019-02-28_SN_EAP_Classifier_results_Southrepps2.xlsx"
output_file_name <- "2019-02-28_SEN_Evaluation_SR2.csv"

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


# NB  Following are hard coded paths rather than derived from site_code
tmp_sourcefile <-
  paste(d_intermed,
        input_file_name,
        sep = "")
tmp_outputfile <-
  paste(d_tidy,
        output_file_name,
        sep = "")

# Read the input file
tmp_SNclassifier_results <- read_excel(tmp_sourcefile)


tmp_SNclassifier_results <-
  data.frame(obs_datetime = as.POSIXct(gsub(
    "_", "", substr(tmp_SNclassifier_results$filename, 5, 19)
  ), format = "%Y%m%d%H%M%S"),
  tmp_SNclassifier_results) # Create the Date-Time column


#write results to csv
if (save_csv == TRUE) {
  write_csv(tmp_SNclassifier_results, tmp_outputfile, col_names = TRUE)
}

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
# rmarkdown::render(paste(d_home,"bin/snips/ProcessXLSXfromSEN.R", sep = ""), "pdf_document")
#
#### END END END ####


#### Supplementary code to combine the two SR2 files from SEN.
# Parameters
source_files <- c(
  "2019-02-12_SEN_Evaluation_SR2.csv",
  "2019-02-28_SEN_Evaluation_SR2.csv"
)

output_file_name <- "2019-03-04_Summary_SEN_Evaluation_SR2.csv"

tmp_file1 <- read_csv(paste(d_tidy, source_files[1], sep = ""))
tmp_file2 <- read_csv(paste(d_tidy, source_files[2], sep = ""))

tmp_file1 <- tmp_file1 %>% transmute(
  .,
  obs_datetime = obs_datetime,
  filename = filename,
  species = species,
  confidence_index = confidence_index,
  real_error = real_error
)

tmp_file2 <- tmp_file2 %>% transmute(
  .,
  obs_datetime = obs_datetime,
  filename = filename,
  species = species,
  confidence_index = confidence_index,
  real_error = real_error
)

tmp_SNclassifier_results <- bind_rows(
  tmp_file1,
  tmp_file2,
  .id = NULL
)

write_csv(tmp_SNclassifier_results, paste(d_tidy, output_file_name, sep = ""), col_names = TRUE)