
#' Summarize Note Character Length
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
#' test_dataset <- data.frame(ID=c("1","1","2","2","1"),
#' Notes=c("The","cat","The","dog","ran"),
#' Page=c(1,2,1,2,3))
#' extremeid(dataset=test_dataset,clean_notes="Notes",extreme=2,pageid="Page")
extremeid <- function(dataset, extreme, clean_notes, pageid, group_list=NA){
  `%>%` <- magrittr::`%>%`
  dataset$note_length <- nchar(dataset[[clean_notes]])
 if (is.na(group_list)){
   summary_info <- dataset %>%
     dplyr::group_by_at(pageid) %>%
     dplyr::summarise (outlier = mean(note_length, na.rm=TRUE)+extreme*stats::sd(note_length, na.rm=TRUE),
                       mean=mean(note_length, na.rm=TRUE), sd = stats::sd(note_length, na.rm=TRUE))
   combined_dataset <- dplyr::left_join(dataset, summary_info, by="page_count")
 }else{
summary_info <- dataset %>%
  dplyr::group_by(noquote(deparse(substitute(pageid))),noquote(deparse(substitute(group_list)))) %>%
  dplyr::summarise (outlier = mean(note_length)+extreme*stats::sd(note_length), mean=mean(note_length), sd = stats::sd(note_length))
combined_dataset <- dplyr::left_join(dataset, summary_info, by=group_list)
}
combined_dataset

}