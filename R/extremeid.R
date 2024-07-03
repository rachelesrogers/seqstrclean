
#' Summarize Note Character Length
#'
#'Use to identify extreme values, based on cleaned note length, in a dataset.
#'Can be used after applying [firstnchar()]
#'
#' @param dataset data frame of notes
#' @param extreme number of standard deviations above the mean character length that defines an extreme value
#' @param clean_notes column name of clean notes to provide summary values for
#' @param group_list list of variables to group by for cleaned notes
#' @param pageid column name for page number
#'
#' @return a data frame
#' @export
#'
#' @examples
#' test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
#' Notes=c("The","The cat","The","The dog","The cat ran",
#' "the chicken was chased", "The goat chased the chicken"),
#' Page=c(1,2,1,2,3,1,2))
#' cleaned_dataset<-
#' firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,
#' identifier="ID",pageid="Page")
#' extremeid(dataset=cleaned_dataset,clean_notes="page_notes",extreme=2,pageid="Page")
extremeid <- function(dataset, extreme, clean_notes, pageid, group_list=NA){
  `%>%` <- magrittr::`%>%`
  note_length <- NULL
  dataset$note_length <- nchar(dataset[[clean_notes]])

  if (sum(is.na(dataset$note_length))>0){
    dataset[is.na(dataset$note_length),]$note_length <- 0
    }

 if (is.na(group_list)){
   summary_info <- dataset %>%
     dplyr::group_by_at(pageid) %>%
     dplyr::summarise (outlier = mean(note_length, na.rm=TRUE)+extreme*stats::sd(note_length, na.rm=TRUE),
                       mean=mean(note_length, na.rm=TRUE), sd = stats::sd(note_length, na.rm=TRUE))
   combined_dataset <- dplyr::left_join(dataset, summary_info, by = {{pageid}}) #problem with by= statement (can't find right form)
 }else{
   groups <- append(group_list, pageid)
summary_info <- dataset %>%
  dplyr::group_by_at(groups) %>%
  dplyr::summarise (outlier = mean(note_length, na.rm=TRUE)+extreme*stats::sd(note_length, na.rm=TRUE),
                    mean=mean(note_length, na.rm=TRUE), sd = stats::sd(note_length, na.rm=TRUE))
combined_dataset <- dplyr::left_join(dataset, summary_info, by = {{groups}})
 }
  combined_dataset$extreme_value <- combined_dataset$note_length > combined_dataset$outlier
combined_dataset

}
