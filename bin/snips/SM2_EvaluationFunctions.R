###### SM2 Evaluation Functions
# Load results data file
source_data = "_tcResults.csv"
source_file <- as.character(paste(d_tidy, site_code, source_data, sep = ""))
if (! exists("tbl_tcResults")) {
  stopifnot( file.exists(source_file))
  tbl_tcResults <- read.csv(source_file, header = TRUE) 
}
names(tbl_tcResults)[4] <- "confidence"

# Summary Statistics
tbl_tcResults %>%  
  filter(., confidence >= confidence_filter) %>% 
  group_by((species)) %>% 
  summarise(count = n(), max = max(confidence), mean = mean(confidence), min = min(confidence), std_deviation = sd(confidence))

# Monthly Summary, results writen to tbl_mnlyStats
# There must be a better way to group by year/ month
tbl_mnlyStats <- tbl_tcResults %>%  
  filter(., confidence >= confidence_filter) %>% 
  group_by(year(as.Date(obs_datetime, "%Y-%m-%d")), month(as.Date(obs_datetime, "%Y-%m-%d")),species) %>% 
  summarise(count = n(), max = max(confidence), mean = mean(confidence), min = min(confidence), std_deviation = sd(confidence))
names(tbl_mnlyStats)[1] <- "Year"
names(tbl_mnlyStats)[2] <- "Month"

### Weekly Summary
tbl_wklyStats <- tbl_tcResults %>%  
  filter(., confidence >= confidence_filter) %>% 
  group_by(year(as.Date(obs_datetime, "%Y-%m-%d")), week(as.Date(obs_datetime, "%Y-%m-%d")),species) %>% 
  summarise(count = n(), 
            max = max(confidence), 
            mean = mean(confidence), 
            min = min(confidence), 
            std_deviation = sd(confidence)) %>%
  as_tibble()

names(tbl_wklyStats)[1] <- "Year"
names(tbl_wklyStats)[2] <- "Week"

# select data for heat map
#
test_year = 2017
wkly_summary <- tbl_wklyStats %>%
  filter(Year == test_year) %>%
  select(., 
         "WeekNum" = Week, 
         "Species" = species, 
         "Count" = count)

gg <- ggplot(data = wkly_summary, aes(x = WeekNum  , y = Species)) +
  geom_tile(aes(fill = Count ), color = "white") +
  scale_fill_gradient(low = "white", high = "steelblue")
gg



 

######################### Extract Records for low frequency species #######
## based on:> https://stackoverflow.com/questions/20204257/subset-data-frame-based-on-number-of-rows-per-group
## NB This code needs to be modified to remove site referene "EE" etc and can be simplified
tt <- table(ECC_Records$species)  #This creates a temporary vector listing all species and the incidence of records
ECC_results_valudation <- subset(ECC_Records, species %in% names(tt[tt <= 20])) #Here the criterion is 30
table(ECC_Records$species)
############# Add columns to dataframe for validation of records ##############
## NB This code needs to be modified to remove site reference "ECC" etc and can be simplified
ECC_results_valudation$to_validate <- TRUE  #Logical to indicate the record is to be validated
ECC_results_valudation$autoID_validate <- FALSE  #Logical to indicate if the auto ID is valid
ECC_results_valudation$species_val <- "-" #Char for validator to enter alternative species
ECC_results_valudation$validator <- "-" #Char for validator to enter their initials
ECC_results_valudation$validator_comments <- "-" #Char for validator to enter comments
write.csv(ECC_results_valudation, "./R-Test/tidy/ECC/ECC_results2validate.csv", row.names = FALSE)