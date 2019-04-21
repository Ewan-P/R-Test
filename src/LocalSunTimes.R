###---   title: "Night Times"
# author: "Steve Markham"
# date: 2018-04-05T21:13:45-01:00
# categories: ["R"]
# tags: ["R Markdown", "bats", "suntimes"]
# Source https://github.com/Nattereri/rbats-blog/blob/master/content/post/2018-04-05-rbats_night_time.Rmd
# 
### 2019-03-21 Ewan Parsons
# Modified to use start end dates, and unix timezones.
# Includes demo code to generate a csv of sun rise/set times.
# demo will only execute if "runSunTimesTest is TRUE
# 2019-04-19 EAP
# revised demo code to avoid overwriting exisiting output files


library(tidyverse)
library(rlang)
library(StreamMetabolism) # for sunset / sunrise times
library(gridExtra)
library(broman)
library(ggmap)
library(knitr)
library(hms)
library(kableExtra)

#<----------------------------------------------------------------------
#Function - For getting sunset sun rise and night length (used by Exit_Reentry_Times)
#<----------------------------------------------------------------------
NightData <-
  function(startDate,
           durationDays,
           lat,
           long,
           timeZone) {
    # Function to return sunset sunrise and night length with long/lat and night
    # Aruments list (fist Night, duration , lon, lat)

    #Works with night so and an extra day to get dawn

    #Get sunrise and sunset times for period of static placement

    if (durationDays == 0) {
      durationDays <- 1
    }

    if (is_missing(timeZone)) {
      timeZone <- "UTC"
    }
    
    if (is_false(tzValid(timeZone))) {
      timeZone <- "UTC"
    }
    
    SunTimes <-
      sunrise.set(lat,
                  long,
                  startDate,
                  timeZone,
                  num.days = durationDays + 1)
    
    ## Table of Night and sun rise/set and times 
    ## (based on EmergenceData data frame)
    
    # Take away last row
    SunSets <- SunTimes %>%
      slice(1:(n() - 1)) %>%
      pull(sunset)
    
    # Take away first row
    SunRises <- SunTimes %>%
      slice(2:n()) %>%
      pull(sunrise)
    
    Nights <-
      seq.Date(from = startDate,
               length.out = durationDays,
               by = 'days')
    
    NightLength <- round_hms(as.hms(- (SunSets - SunRises)), 60)
    
    #NightLength <-
    
    NightStats <- tibble(Nights, SunSets, SunRises, NightLength)
    
    return(NightStats)
    
  }

#<----------------------------------------------------------------------
#Function - With NightData will return text of Suntimes ready for a Table (Kable)
#<----------------------------------------------------------------------
TextSunTimes <- function(Data, Type) {
  #if Type = 1 the no Night Length included
  #if Type = 2 the Night Length is included
  #if Type = 3  week day is included but not the Night Length
  #if Type = 4  week day and Night Length is included
  
  if (missing(Type)) {
    Type <- 1
  }
  
  if (Type == 1) {
    Data <- Data %>%
      mutate(
        justmin1 = stringr::str_pad(
          lubridate::minute(SunSets),
          2,
          side = "left",
          pad = "0"
        ),
        timeset = paste(lubridate::hour(SunSets), justmin1, sep = ":"),
        justmin2 = stringr::str_pad(
          lubridate::minute(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        justmin3 = stringr::str_pad(
          lubridate::hour(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        timerise = paste(justmin3, justmin2, sep = ":"),
        night = Fm_date(Nights, 1)
      ) %>%
      select(night, timeset, timerise)
    
    names(Data) <- c("Night", "Sunset (hrs)", "Sunrise (hrs)")
    
  } else if (Type == 2) {
    Data <- Data %>%
      mutate(
        justmin1 = stringr::str_pad(
          lubridate::minute(SunSets),
          2,
          side = "left",
          pad = "0"
        ),
        timeset = paste(lubridate::hour(SunSets), justmin1, sep = ":"),
        justmin2 = stringr::str_pad(
          lubridate::minute(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        justmin3 = stringr::str_pad(
          lubridate::hour(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        timerise = paste(justmin3, justmin2, sep = ":"),
        night = Fm_date(Nights, 1),
        NightLength = stringr::str_sub(as.character(NightLength), 1, 5)
      ) %>%
      select(night, timeset, timerise, NightLength)
    
    names(Data) <-
      c("Night",
        "Sunset (hrs)",
        "Sunrise (hrs)",
        "Duration (hrs:min)")
    
  } else if (Type == 3) {
    Data <- Data %>%
      mutate(
        justmin1 = stringr::str_pad(
          lubridate::minute(SunSets),
          2,
          side = "left",
          pad = "0"
        ),
        timeset = paste(lubridate::hour(SunSets), justmin1, sep = ":"),
        justmin2 = stringr::str_pad(
          lubridate::minute(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        justmin3 = stringr::str_pad(
          lubridate::hour(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        timerise = paste(justmin3, justmin2, sep = ":"),
        night = Fm_date(Nights, 1),
        weekday = lubridate::wday(Nights, label = T, abbr = F)
      ) %>%
      select(weekday, night, timeset, timerise)
    
    names(Data) <-
      c("Day of Week", "Night", "Sunset (hrs)", "Sunrise (hrs)")
    
  } else if (Type == 4) {
    Data <- Data %>%
      mutate(
        justmin1 = stringr::str_pad(
          lubridate::minute(SunSets),
          2,
          side = "left",
          pad = "0"
        ),
        timeset = paste(lubridate::hour(SunSets), justmin1, sep = ":"),
        justmin2 = stringr::str_pad(
          lubridate::minute(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        justmin3 = stringr::str_pad(
          lubridate::hour(SunRises),
          2,
          side = "left",
          pad = "0"
        ),
        timerise = paste(justmin3, justmin2, sep = ":"),
        night = Fm_date(Nights, 1),
        weekday = lubridate::wday(Nights, label = T, abbr = F),
        NightLength = stringr::str_sub(as.character(NightLength), 1, 5)
      ) %>%
      select(weekday, night, timeset, timerise, NightLength)
    
    names(Data) <-
      c("Day of Week",
        "Night",
        "Sunset (hrs)",
        "Sunrise (hrs)",
        "Duration (hrs:min)")
    
  }
  
  return(Data)
  
}

###########################################################################
#Formats a POSdate or Date for Reporting.
Fm_date <- function(Format.Date, style) {
  if (style == 1) {
    stringr::str_c(
      lubridate::day(Format.Date) ,
      lubridate::month(Format.Date, label = TRUE),
      lubridate::year(Format.Date),
      sep = " "
    )
    
  } else if (style == 2) {
    #Abbr month and date only
    stringr::str_c(
      lubridate::day(Format.Date),
      lubridate::month(Format.Date, label = TRUE, abbr = FALSE),
      lubridate::year(Format.Date),
      sep = " "
    )
    
  } else if (style == 3) {
    stringr::str_c(lubridate::day(Format.Date),
                   lubridate::month(Format.Date, label = TRUE),
                   sep = " ")
    
  } else if (style == 4) {
    #Full date e.g. Thursday 3 August 2017
    stringr::str_c(
      lubridate::wday(Format.Date, label = TRUE, abbr = FALSE),
      lubridate::day(Format.Date),
      lubridate::month(Format.Date, label = TRUE, abbr = FALSE),
      lubridate::year(Format.Date),
      sep = " "
    )
    
  } else if (style == 5) {
    #Full date and Time e.g. Thu 3 Aug 2017 20:13:56
    stringr::str_c(
      lubridate::wday(Format.Date, label = TRUE, abbr = TRUE),
      " ",
      lubridate::day(Format.Date),
      " ",
      lubridate::month(Format.Date, label = TRUE, abbr = TRUE),
      " ",
      lubridate::year(Format.Date),
      " ",
      stringr::str_pad(
        lubridate::hour(Format.Date),
        2,
        side = "left",
        pad = "0"
      ),
      ":",
      stringr::str_pad(
        lubridate::minute(Format.Date),
        2,
        side = "left",
        pad = "0"
      ),
      "hrs",
      sep = ""
    )
    
  } else if (style == 6) {
    #Simple date
    stringr::str_c(
      lubridate::day(Format.Date),
      lubridate::month(Format.Date),
      stringr::str_sub(
        lubridate::year(Format.Date),
        start = 3,
        end = 4
      ),
      sep = "-"
    )
    
  } else if (style == 7) {
    # date (month and Year)
    stringr::str_c(
      lubridate::month(Format.Date, label = TRUE, abbr = FALSE),
      lubridate::year(Format.Date),
      sep = " "
    )
    
  }
}





### EAP ###
#<----------------------------------------------------------------------
#Function - For validating time zones,
#<----------------------------------------------------------------------
tzValid <- function(timeZone) {
  # returns True if timezone is found in the Olson list, or
  # FALSE if not found
  
  return(isTRUE (grep("TRUE", OlsonNames() == timeZone) >= 1))
}



#<----------------------------------------------------------------------
#Function - For getting sunset sun rise and night length (used by Exit_Reentry_Times)
#<----------------------------------------------------------------------
NightData_ed <- function(startDate, endDate, lat, long, timeZone) {
  # wrapper around function NightData
  # Function to return sunset sunrise and night length with long/lat and night
  # Arguments list (fist Night, last Night , lon, lat, timeZone)

    durationDays <- as.numeric(gsub(
    ".*?([0-9]+).*",
    "\\1",

    difftime(
      strptime(endDate, format = "%Y-%m-%d"),
      strptime(startDate, format = "%Y-%m-%d"),
      units = "days"
    )
  ))
  
  return(
    NightData(startDate, 
              durationDays, 
              lat, 
              long, 
              timeZone))
}


### Test Code ### Test Code ### Test Code ###
# Will only execute if "runSunTimesTest is TRUE
# and there needs to be a sitedata.csv file in the d_tidy directory
if (runSunTimeTest) {

  dataFile <- paste0(d_tidy, "sitedata.csv")
  if (!isTRUE(file.exists(dataFile)))
    stop("No data file found")
  
  library(readr)
  siteDetails <- as.data.frame(read_csv(dataFile))
  v_startDate <- "01-01-2016"  #Hard-coded change to suit application
  v_endDate <- "31-12-2019" #Hard-coded change to suit application
  
  for (i in 1:nrow(siteDetails)) {
    v_siteCode <- siteDetails[i, 1]
    v_siteLat <- as.double(siteDetails[i, 2])
    v_siteLong <- as.double(siteDetails[i, 3])
    v_timeZone <- as.character(siteDetails[i, 4])
    
    if (is.na(v_siteCode))
      next
    if ( isTRUE( file.exists( paste0( d_tidy,
                                      v_siteCode,
                                      "-SunTime.csv")))) { #skip exising files
      next
    }
    
    print(paste(v_siteCode, v_siteLat, v_siteLong, sep = " "))
    tbl_sunTimes <-
      NightData_ed(
        lubridate::dmy(v_startDate),
        lubridate::dmy(v_endDate),
        v_siteLat,
        v_siteLong,
        v_timeZone
      )
    
    write.csv(tbl_sunTimes,
              paste0(d_tidy,
                     v_siteCode,
                     "-SunTime.csv"),
              row.names = FALSE)
  }
  
}
