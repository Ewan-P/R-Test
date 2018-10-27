#EAP 2018-10-27
#Sound processing snips, initally focussed on processing results from ECC records

#Import the results of claiffication.
ECC_Records <- read.csv("./R-Test/intermed/ECC/ECC_txt_classifier_results.csv", header = TRUE)

#Extract date/time from file_name column in table
#Assume ECC formatting
date_time <- gsub("_", "", substr(file_name,5,19))
DateTime <- as.POSIXct(date_time, format="%Y%m%d%H%M%S")
#Putting it all into a single line to give all data and times in a list
DateTime <- as.POSIXct(gsub("_", "", substr(ECC_Records$filename,5,19)), format="%Y%m%d%H%M%S")