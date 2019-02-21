#EAP 2018-10-27
#Sound processing snips, initally focussed on processing results from ECC records

#Import the results of classification.
ECC_Records <- read.csv("./R-Test/intermed/ECC/ECC_txt_classifier_results.csv", header = TRUE, stringsAsFactors = FALSE)

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
#filwrite.csv(ECC_Records, "./R-Test/tidy/ECC/ECC_txt_classifier_results.csv", row.names = FALSE)


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
tempfiles = do.call(rbind, lapply(temp, function(x) read.delim(x, header = FALSE, sep = "\t", )))
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

#Problem:  Based on observations in ECC_Sensors.csv generate a list of dates on which observations were made
UniqueDates <- unique(tempfiles$ObsDate)

UniqueDates
  #Now write this out to a csv file
write.csv(tempfiles, "./R-Test/tidy/ECC/ECC_OperatingDates.csv", row.names = FALSE)
############################# Summarising Results #####################
#absolute counts in dataframe
sp_counts <- ECC_Records %>% select(species) %>% group_by(species) %>% summarise(number = n())
# alternative 
table(ECC_Records)  #Probably easier

# Summary Statistics
accuracy_filter <- 0.75  #Change this value to set required accuracy cut-off.  In practice 0.5 is applied by Stuart when agreegating records.
ECC_Records %>%  
  filter(., accuracy >= accuracy_filter) %>% 
  group_by((species)) %>% 
  summarise(count = n(), max = max(accuracy), mean = mean(accuracy), min = min(accuracy), std_deviation = sd(accuracy))


######################### Extract Records for low frequency species #######
## based on:> https://stackoverflow.com/questions/20204257/subset-data-frame-based-on-number-of-rows-per-group
tt <- table(ECC_Records$species)  #This creates a temporary vector listing all species and the incidence of records
ECC_results_valudation <- subset(ECC_Records, species %in% names(tt[tt <= 20])) #Here the criterion is 30
table(ECC_Records$species)

############# Add columns to dataframe for validation of records ##############
ECC_results_valudation$to_validate <- TRUE  #Logical to indicate the record is to be validated
ECC_results_valudation$autoID_validate <- FALSE  #Logical to indicate if the auto ID is valid
ECC_results_valudation$species_val <- "-" #Char for validator to enter alternative species
ECC_results_valudation$validator <- "-" #Char for validator to enter their initials
ECC_results_valudation$validator_comments <- "-" #Char for validator to enter comments
write.csv(ECC_results_valudation, "./R-Test/tidy/ECC/ECC_results2validate.csv", row.names = FALSE)

############# Post validation 
#filter all records with "accuracy" less than 0.6.  
ECC_results_valudation2 <- subset(ECC_Records, accuracy >= 0.6, stringsAsFactors = FALSE)
table(ECC_results_valudation2$species)
#The 0.6 is an arbitary number but usefull to ass the impact of higher cutoffs

#Calculate the % reduction between the full and filtered dataset
round(((table(ECC_Records$species) - table(ECC_results_valudation2$species)) / table(ECC_Records$species) * 100), digits = 0)

############### Data Summaries
install.packages("dplyr", "lubridate")
library(dplyr)
library(lubridate)

#Add columns for Year, Month and DoM
#NB as this uses dplyr functions output needs to be a new df
test_df <- mutate(ECC_results_valudation2, Year = as.character.Date(obs_datetime, format = "%Y"), Month = as.character.Date(obs_datetime, format = "%m"), DoM = as.character.Date(obs_datetime, format = "%d" ))

#Now generate summaries
#1st by year
output_df <- test_df %>% group_by(Year, Month, species) %>% select(DoM) %>% summarise( Count = n())
#Alternatively by species
output_df <- test_df %>% 
  group_by(species, Year, Month) %>% 
  select(DoM) %>% 
  summarise( Count = n())
#Alternative for summary
output_df <- test_df %>% 
  group_by(species, Year, Month) %>% 
  select(DoM) %>% 
  summarise( Count = n())

####### Look for "Next Best" result #####################
#  Useful to check classification to see if the next best result appeared in earlier / later calls #########
#  Need to be aware that each csv file can be 10 - 20 MB is size so may have space issues
#  Uses code from: https://stackoverflow.com/questions/11433432/how-to-import-multiple-csv-files-at-once
#  Using tidyvers functions
library(readr)
library(dplyr)
library(purrr)
#  Set up directories
Home_Dir <- "/home/rstudio"  #Only vaid for AWS - RStudio - Server
Raw_Dir <- "/home/rstudio/R-Test/raw/ECC" #Only vaid for AWS - RStudio - Server
Intermed_Dir <- "/home/rstudio/R-Test/intermed/ECC"  #Only vaid for AWS - RStudio - Server
Results_Dir <- "/home/rstudio/R-test/tidy/ECC"   #Only vaid for AWS - RStudio - Server
Output_Dir <- "/home/rstudio/R-test/output"   #Only vaid for AWS - RStudio - Server

setwd(Intermed_Dir)  #IdTot files are results of processing so in Intermed rather than Raw folders
tbl <-
  list.files(pattern = "IdTot.csv", recursive = TRUE) %>% 
  map_df(~read_csv(.))

#Now write the dataframe to a csv file
setwd(Results_Dir)
write.csv(tbl, "ECC_IdTot_all.csv", row.names = FALSE)
setwd(HomeDir)
#    Finished gathering data > now filter for only bats
# Will first filter on file name field to exclude all files that are not in ECC_Records.
# However as the filename column in ECC_Records is a factor this needs to be first converted to char
ECC_Records_files <- data_frame(filename = as.character(ECC_Records$filename))
#Now filter> 
tbl2 <- filter(tbl, Group.1 %in% ECC_Records_files$filename & SpMaxF2 %in% Norfolk_species$species )
View(tbl2)

########  Generate a list of Norfolk Bat Species using SpeciesList_HIGHALL.csv from SEN ====
#import the cvs
tmp_species <- read_csv("~/local/SpeciesList_HIGHALL.csv", col_names = TRUE, na = "FALSE", quoted_na = "FALSE")
#replace NA with NULL
tmp_species <- replace_na(tmp_species, list(NULL))
#filter for Norfolk bats
tmp_species <- filter(tmp_species, Norfolk == "x" & Group == "bat")
#remove unused columns
tmp_species$Nesp = NULL
tmp_species$France = NULL
tmp_species$Turquie = NULL
tmp_species$Norfolk = NULL
tmp_species$Devon = NULL
tmp_species$Group = NULL
tmp_species$Espagne = NULL
#rename the columns
names(tmp_species)[names(tmp_species) == 'Esp'] <-'species'
names(tmp_species)[names(tmp_species) == 'Scientific name'] <-'scientific_name'
# now write out at CSV
write_csv(tmp_species, "~/R-Test/tidy/Norfolk_Bat_Species_list", col_names = TRUE)
Norfolk_species <- read_csv("~/R-Test/tidy/Norfolk_Bat_Species_list", col_names = TRUE)


########  Odds and ends
names(table(ECC_Records$species))  # gets a list of all the species in the ECC_Records dataframe

tbl_Idshort <-
  +   list.files(pattern = "Idshort.csv", recursive = TRUE) %>% 
  +   map_df(~read_csv(.))

#create a table of dates
df <- data.frame(date = seq(from = as.Date("2015-01-01"), to = as.Date("2015-12-31"), by = 1))

# Still trying to extract a row to analyse
  #Example https://stackoverflow.com/questions/42492517/column-name-and-value-of-second-highest-values
DT$second_highest = colnames(DT)[2+apply(DT[,3:8], 1, function(x)
  which(x != 0 & x == sort(x, decreasing = TRUE)[2])[1])]

  # Promissing alternative
  # https://stackoverflow.com/questions/10296866/finding-the-column-number-and-value-the-of-second-highest-value-in-a-row
maxn <- function(n) function(x) order(x, decreasing = TRUE)[n]
apply(test_IdTot, 1, maxn(2))

####### Sampling of records for valuidation
# Objective to return for each species up to 10 records for each accuracy interval 
# 0.5 - 0.59, 0.6 - 0.69 etc.
# This is easy to achieve using summarise and sample_n EXCEPT when there are less 
# than 10 rows in the interval.
# A logical test should resolve this however summarise (n()) doesn't work. see:
# https://stackoverflow.com/questions/22801153/dplyr-error-in-n-function-should-not-be-called-directly
tmp <- tbl_tcResults %>%
  group_by(species, round(accuracy * 10)) %>%
  #summarise(n= n()) %>%
  sample_n( size = summarise(n = n()))

  # possible alternative
  # https://stackoverflow.com/questions/23831711/sample-n-random-rows-per-group-in-a-dataframe
tmp <- lapply(split(tbl_tcResults,tbl_tcResults$species),
              function(subdf) subdf[sample(1:nrow(subdf), 1),]
)
  #The above creates a list containing a dataframe for each species
  #Initially this had problems with sample which would barf if there were less than n rows
  #for a species.
  # the following appears to address this:
tmp <- lapply( split( tbl_tcResults, tbl_tcResults$species),
              function(subdf) 
                subdf[sample(1:nrow(subdf), if (nrow(subdf) < 10) nrow(subdf) else 10 ),]
)  
  #the if statemnet returns either the number of rows in the sub sample or 10 rows
  #this returns in tmp a list of dataframes.
  #those can be combined into a single dataframe using
tmp <- do.call('rbind', tmp) 
# or combined with above into a single snip:>
tmp <- lapply( split( tbl_tcResults, tbl_tcResults$species),
               function(subdf) 
                 subdf[sample(1:nrow(subdf), if (nrow(subdf) < 10) nrow(subdf) else 10 ),]
)  
tmp <- do.call( 'rbind', tmp)
#End Snip++++++++++++++++++++++++++++++++++++
  #Now try to subset on accuracy as well
tmp <- lapply( split( tbl_tcResults, tbl_tcResults$species),
               lapply( split(tbl_tcResults, round(tbl_tcResults$accuracy * 10)),
                       function(subdf) 
                         subdf[sample(1:nrow(subdf), if (nrow(subdf) < 10) nrow(subdf) else 10 ),]
               ))   
# This didn't work


tmp <- tbl_tcResults %>%
  group_by(species, round(accuracy * 10)) %>%
  #summarise(n= n()) %>%
  function(subdf) 
    subdf[sample(1:nrow(subdf), if (nrow(subdf) < 10) nrow(subdf) else 10 ),]

############# Duplicate Processing
#
# Following codes may be useful for dealing with duplicates in the tbl_tcResults dataframe
# Duplicated records can arrise for a number of reasons, i.e.
#   1)  Not being erased when a card is downloaded so that file are re-loaded when the card is reused.
#   2)  Manual errors when copying files/ directories
#   3)  ...


# The following will generate a list of the files that are duplicated.
t_dups_details <- list.files(path = as.character(d_intermed), pattern = "txt_classifier_results.csv", recursive = TRUE, full.names = TRUE) %>% 
  lapply(., function(x) c(x, nrow( read_csv(x))))

#  When the file name has been identified it can be best to use the "System" shell to search for the files e.g. using:
system(("find . | grep SR2_20170511")) #which will search for each instance of "SR2_20170511"

############### Clean up functions
# Cleanup packages
# http://r.789695.n4.nabble.com/Reset-R-s-library-to-base-packages-only-remove-all-installed-contributed-packages-td3596151.html

ip <- installed.packages()
pkgs.to.remove <- ip[!(ip[,"Priority"] %in% c("base", "recommended")), 1] 

# Clear global environment
# https://github.com/KevBarre/Semi-automated-method-to-account-for-identification-errors-in-biological-acoustic-surveys/blob/master/4_ErrorRate.R
rm(list = ls()) 