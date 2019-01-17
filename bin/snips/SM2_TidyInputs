#Tidy Inputs

tbl_Idshort <-
  list.files(pattern = "Idshort.csv", recursive = TRUE) %>% 
  map_df(~read_csv(.))
write_csv(tbl_Idshort, "~/R-Test/tidy/ECC/ECC_Idshort.csv", col_names = TRUE)

tbl_IdTot <-
  list.files(pattern = "IdTot.csv", recursive = TRUE) %>% 
  map_df(~read_csv(.))
  
  tbl_tcResults <-
  list.files(pattern = "txt_classifier_results.csv", recursive = TRUE) %>% 
  map_df(~read_csv(.))