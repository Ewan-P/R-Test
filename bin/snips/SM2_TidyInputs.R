#Tidy Inputs


########## Load local species list
species_list <-
  data.frame(read_csv(paste(
    "~/R-Test/tidy/", as.character(LocalSpeciesList), sep = ""
  ), col_names = TRUE))


##########  Consolidate the input files and write out a new csv to the "tidy" directory
tbl_Idshort <-
  list.files(
    path = as.character(d_intermed),
    pattern = "Idshort.csv",
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df(~ read_csv(.))
write_csv(tbl_Idshort,
          paste(d_tidy, site_code, "_Idshort.csv", sep = ""),
          col_names = TRUE)

########### Consolidate IdTot.csv files
#these file contain all results of the classifier for bats + other species.
#after import the non-bat related information should be removed in order to limit the file size and associated processing time
tbl_IdTot <-
  list.files(
    path = as.character(d_intermed),
    pattern = "IdTot.csv",
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df( ~ read_csv(.))

# Remove all rows where non-bat species are most likely
tbl_IdTot <-
  filter(tbl_IdTot, tbl_IdTot$SpMaxF2 %in% species_list$species)
names(tbl_IdTot)[1] <-
  "filename" #the first column of the .csv is called Group1, replace this with "filename"
tbl_IdTot <-
  tbl_IdTot[, (names(tbl_IdTot) %in% columns2keep)] #Now remove columns for non-bat species
write_csv(tbl_IdTot,
          paste(as.character(d_tidy), site_code, "_IdTot.csv", sep = ""),
          col_names = TRUE)

############# Consolidate txt_classifier_results.csv
tbl_tcResults <-
  list.files(
    path = as.character(d_intermed),
    pattern = "txt_classifier_results.csv",
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df(~ read_csv(.))

#Check if there are duplicates and if not extract date/ times, then write creat the consolidated .csv
if (n_distinct(tbl_tcResults) == count(tbl_tcResults)) {
  # No duplicates
  # so extract date/time from file_name column in table
  tbl_tcResults <- data.frame(obs_datetime = as.POSIXct(gsub(
    "_", "", substr(tbl_tcResults$filename, 5, 19)
  ), format = "%Y%m%d%H%M%S"), tbl_tcResults)
  write_csv(
    tbl_tcResults,
    paste(as.character(d_tidy), site_code, "_tcResults.csv", sep = ""),
    col_names = TRUE
  )
} else {
  # Oh dear! we have duplicates
  SM2_Error <- c(TRUE, "Duplicate Records Found")
  print("Error: Duplicate Records Found")
  t_dups <- (tbl_tcResults[duplicated(tbl_tcResults), 1])
  if (menu(c("Yes", "No"), title = "Remove duplicates?")) {
    print("Removing duplicates")
    tbl_tcResults <-  unique(tbl_tcResults)
    tbl_tcResults <- data.frame(obs_datetime = as.POSIXct(gsub(
      "_", "", substr(tbl_tcResults$filename, 5, 19)
    ), format = "%Y%m%d%H%M%S"), tbl_tcResults)
    write_csv(
      tbl_tcResults,
      paste(as.character(d_tidy), site_code, "_tcResults.csv", sep = ""),
      col_names = TRUE)
  }
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
# Files have the naming convention "site_code_Sensor-X.txt", where X = A:D depending on which card slot the SM2 was writing to.
#After importing, combining, and cleaning the data, it should be writen as "site_code_Sensor.csv¨ to the tidy/site_code directory.

#First Combine all sensor.txt files into one dataframe
sensors <-
  list.files(
    path = as.character(d_intermed),
    paste(site_code, "_Sensor-*", sep = ""),
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df( ~ read.delim2(., header = FALSE, sep = "\t")) %>%
  select(
    .,
    ObsDate = V1,
    ObsTime = V2,
    IntTemperature = V3,
    ExtTemperature = V4
  )

write.csv(sensors,
          paste(d_tidy, site_code, "_Sensors.csv", sep = ""),
          row.names = FALSE)

######## Import MothTrap data ########################
# Data is a sequence of dates and status:  M_Trap_On | M_Trap_Off
# This needs to be imported and converted to a time series by day with status either On/ Off
tbl_mtStatus <-
  list.files(
    path = as.character(d_raw),
    pattern = "MothTrapDates.csv",
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df(~ read_csv(.))

####### Import NorfolkBatList =====================
tbl_NorBatList <-
  list.files(
    path = "/home/rstudio/R-Test/tidy",
    pattern = "Norfolk_Bat_Species_list.csv",
    recursive = TRUE,
    full.names = TRUE
  ) %>%
  map_df(~ read_csv(.))
