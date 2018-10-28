#EAP 2018-10-27
#Sound processing snips, initally focussed on processing results from ECC records

#Import the results of claiffication.
ECC_Records <- read.csv("./R-Test/intermed/ECC/ECC_txt_classifier_results.csv", header = TRUE)

#=========================================================
#Extract date/time from file_name column in table
#Assume ECC formatting
date_time <- gsub("_", "", substr(file_name,5,19))
DateTime <- as.POSIXct(date_time, format="%Y%m%d%H%M%S")
#Putting it all into a single line to give all data and times in a list
DateTime <- as.POSIXct(gsub("_", "", substr(ECC_Records$filename,5,19)), format="%Y%m%d%H%M%S")
#Now create a new DataFrame with the dates/times as a new column
TestFrame <- data.frame(obs_datetime = as.POSIXct(gsub("_", "", substr(ECC_Records$filename,5,19)), format="%Y%m%d%H%M%S"), ECC_Records)
#Or to ammend the existing dataframe
ECC_Records <- data.frame(obs_datetime = as.POSIXct(gsub("_", "", substr(ECC_Records$filename,5,19)), format="%Y%m%d%H%M%S"), ECC_Records)
# Finally write the new dataframe out as a csv
write.csv(ECC_Records, "./R-Test/tidy/ECC/ECC_txt_classifier_results.csv", row.names = FALSE)


#======================================================
#Problem: Import and clean up all "Sensor.txt" files.
#These are created by the SM2 and record the internl temperature of the detector during each recording period.
#The files are tab delimited ".txt" files with no header row.  
#Columns are:
  # > Date of observation.
  # > Time of observation.
  # > Observed temperature Deg C, from internal sensor
  # > Observed temperature from external sensor.  If not installed this will read -20.5
# Files have the naming convention "ECC_Sensor-X.txt", where X = A:D depending on which card slot the SM2 was writing to.
#After importing, combining, and cleaning the data, it should be writen as "ECC_Sensor.csv¨ to the tidy/ECC directory.

#First Combine all sensor.txt files into one dataframe
HomeDir <- "/home/rstudio"  #Only vaid for AWS - RStudio - Server
RawDir <- "/home/rstudio/R-Test/raw"  #Only vaid for AWS - RStudio - Server
setwd(RawDir)
temp = list.files(pattern = "ECC_Sensor-*", recursive = TRUE)
tempfiles = do.call(rbind, lapply(temp, function(x) read.delim(x, header = FALSE, sep = "\t", stringsAsFactors = FALSE)))
setwd(HomeDir)
  #column names will be V1 to V6 although V5 & V6 will be NA
  #remove these columns by setting name to NA
tempfiles$V5 <- NULL
tempfiles$V6 <- NULL
  #Now rename the columns
names(tempfiles)[names(tempfiles)=="V1"] <- "ObsDate"
names(tempfiles)[names(tempfiles)=="V2"] <- "ObsTime"
names(tempfiles)[names(tempfiles)=="V3"] <- "IntTemperature"
names(tempfiles)[names(tempfiles)=="V4"] <- "ExtTemperature"

  #Now write the dataframe to a csv file
write.csv(tempfiles, "./R-Test/tidy/ECC/ECC_Sensors.csv", row.names = FALSE)

#Problem:  Based on observations in ECC_Sensors.csv generate a list of date on which observations were made
UniqueDates <- unique(tempfiles$ObsDate)

UniqueDates
  #Now wright this out to a csv file
write.csv(tempfiles, "./R-Test/tidy/ECC/ECC_OperatingDates.csv", row.names = FALSE)
