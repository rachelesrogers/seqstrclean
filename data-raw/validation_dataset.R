## code to prepare `validation_dataset` dataset goes here

# validation_dataset_import <-
#   read_csv("~/PhD Research/Firearm Demonstrative Evidence/Comment Analysis/validation_dataset.csv") %>%
#   subset(select=c("clean_prints","page_count", "notes",
#                   "corrected_notes", "time", "submission_time", "algorithm"))
# latest_observation <- validation_dataset_import %>%
#   group_by(clean_prints, page_count) %>%
#   summarise(latest_time = max(time[time < submission_time])) %>% ungroup()
#
# combined_validation <- left_join(validation_dataset_import, latest_observation)
# validation_dataset <- combined_validation %>% filter(time==latest_time) %>%
#   subset(select=c("clean_prints","page_count", "notes",
#                   "corrected_notes", "algorithm"))

usethis::use_data(validation_dataset, overwrite = TRUE)
