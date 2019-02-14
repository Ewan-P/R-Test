#Tidy Inputs

# Load local species list
species_list <- data.frame(read_csv(paste("~/R-Test/tidy/", as.character(LocalSpeciesList), sep = ""), col_names = TRUE))

#  Consolidate the input files and write out a new csv to the "tidy" directory
tbl_Idshort <-
  list.files(path = as.character(d_intermed), pattern = "Idshort.csv", recursive = TRUE, full.names = TRUE) %>% 
  map_df(~read_csv(.))
write_csv(tbl_Idshort, "~/R-Test/tidy/ECC/ECC_Idshort.csv", col_names = TRUE)

#Consolidate IdTot.csv files
  #these file contain all results of the classifier for bats + other species.
  #after import the non-bat related information should be removed in order to limit the file size and associated processing time
tbl_IdTot <-
  list.files(path = as.character(d_intermed), pattern = "IdTot.csv", recursive = TRUE, full.names = TRUE) %>% 
  map_df(~read_csv(.))
tbl_IdTot <- filter(tbl_IdTot, tbl_IdTot$SpMaxF2 %in% species_list$species) # Remove all rows where non-bat species are most likely
names(tbl_IdTot)[1] <- "filename" #the first column of the .csv is called Group1, replace this with "filename"
tbl_IdTot <- tbl_IdTot[,(names(tbl_IdTot) %in% columns2keep)] #Now remove columns for non-bat species
write_csv(tbl_IdTot, paste(as.character(d_tidy), "/", "ECC_IdTot.csv", sep = ""), col_names = TRUE)

# Consolidate txt_classifier_results.csv
tbl_tcResults <-
  list.files(path = as.character(d_intermed), pattern = "txt_classifier_results.csv", recursive = TRUE, full.names = TRUE) %>% 
  map_df(~read_csv(.))
  #Check if there are duplicates and if not extract date/ times, then write creat the consolidated .csv
if( n_distinct(tbl_tcResults) == count(tbl_tcResults)) { #No duplicates
  #Extract date/time from file_name column in table
  tbl_tcResults <- data.frame(obs_datetime = as.POSIXct(
    gsub("_", "", substr(tbl_tcResults$filename,5,19)), format="%Y%m%d%H%M%S"), tbl_tcResults)  
  write_csv(tbl_tcResults, "~/R-Test/tidy/ECC/ECC_tcResults.csv", col_names = TRUE)
}else {
  SM2_Error <- c(TRUE, "Duplicate Records Found")
}

#===============================================================================
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
temp <- list.files(path = as.character((d_raw)),  pattern = "ECC_Sensor-*", recursive = TRUE)
tempfiles <- do.call(rbind, lapply(temp, function(x) read.delim(x, header = FALSE, sep = "\t" )))
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

######## Import MothTrap data ########################
# Data is a sequence of dates and status:  M_Trap_On | M_Trap_Off
# This needs to be imported and converted to a time series by day with status either On/ Off
tbl_mtStatus <- list.files(path = as.character(d_raw), pattern = "MothTrapDates.csv", recursive = TRUE, full.names = TRUE) %>% 
  map_df(~read_csv(.))

####### Import NorfolkBatList =====================
tbl_NorBatList <- list.files(path = "/home/rstudio/R-Test/tidy", pattern = "Norfolk_Bat_Species_list.csv", recursive = TRUE, full.names = TRUE) %>% 
  map_df(~read_csv(.))
