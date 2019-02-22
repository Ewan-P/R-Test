###### SM2 Validation Functions
# Main validation is by manual review of selected records.
#
# Records will be selected as follows:
#   For Each Species
#     For each Confidence Bin (0.5 - 0.59, 0.6 - 0.69, etc)
#       if count of records <= 25
#         select all records
#       else
#         select a random sample
#
# Output will be a .csv file with the following columns
#   filename      :for the original wav file
#   obs_datatime  :extracted from teh file name when data was imported
#   species       :as determined by the classifier
#   confidence    :as determined by the classifier
#   sucess        :will be set by validator if there is agreement with the classifier
#   species_man   :will be input by the validator
#   validator     :initials of the validator, for future reference
#   comments      :free form comments from validator.


######################### Extract Records for low frequency species #######
## This follows the sampling system adopted by Barre et. al.
check_calls <- tbl_tcResults %>%
  group_by(species, conf_intvl = round(confidence * 10)) %>%
  sample_n(., ifelse(n() <= records_to_validate, n(), records_to_validate)) %>%
  select(filename, obs_datetime, species_auto = species, conf_intvl) %>%
  add_column(
    .,
    sucess = FALSE,
    #Logical, set manually, default FALSE,
    species_man  = "-",
    #Char, set manually
    validator    = "-",
    #Char, validator to enter their initials
    validator_comments = "-"#Char, for validator to enter comments
  )

print(check_calls %>%
  group_by(species_auto) %>%
  summarise(n = n())
)

if (menu(c("Yes", "No"), title = "Write CSV file?")) {
  write.csv(
    check_calls,
    paste0(
      d_intermed,
      site_code,
      "_check_calls.csv",
      sep = ""
    ),
    row.names = FALSE
  )
}
