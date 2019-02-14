################ Process xlsx from Stuart
# Routines to import and process xlsx files for ECC and Southrepps as supplied by SEN
# EAP 2019-02-14
# Files are called 
#   2019-02-12_SN_EP_Classifier_results_SRepp.xlsx, and 
#   2019-02-12_SN_EP_Classifier_results_ECC.xlsx
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
#   create new columns one for date, the other for time
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
########  CODE Follows ##########################
# Configure Environment & paths etc.
ECC_sourcefile <- "~/R-Test/intermed/ECC/2019-02-12_SN_EP_Classifier_results_ECC.xlsx"
SR2_sourcefile <- "~/R-Test/intermed/ECC/2019-02-12_SN_EP_Classifier_results_SR2.xlsx"
ECC_outputfile <- "~/R-Test/tidy/ECC/2019-02-12_SEN_Evaluation_ECC.csv"
SR2_outputfile <- "~/R-Test/tidy/SR2/2019-02-12_SEN_Evaluation_SR2.csv"
#
# Load required libraries
library(readxl)

