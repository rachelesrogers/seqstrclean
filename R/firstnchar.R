
#' First N Character Note Cleaning
#'
#' @param dataset the dataset containing the notes
#' @param notes the column name for the notes
#' @param char_diff allowable character difference for removing notes
#' @param identifier column name for uniquely identifying identification
#' @param pageid column name for page number
#'
#' @return a data frame
#' @export
#'
#' @examples
#' test_dataset <- data.frame(ID=c("1","1","2","2","1"),
#' Notes=c("The","The cat","The","The dog","The cat ran"),
#' Page=c(1,2,1,2,3))
#' firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,identifier="ID",pageid="Page")
firstnchar <- function(dataset, notes, char_diff, identifier, pageid){

  full_reduced_comments <- data.frame(page_count = NA, page_notes=NA, edit_distance=NA, identifier=NA)

  #unique_ids <- dataset %>% dplyr::select(tidyselect::all_of(identifier)) %>% unique()
  unique_ids <- unique(dplyr::select(dataset,tidyselect::all_of(identifier)))

  for (i in 1:dim(unique_ids)[1]){
    reduced_comments <- data.frame(page_count = NA, page_notes=NA, edit_distance=NA, identifier=NA)
    by_id <- dataset[dataset[[identifier]]==as.numeric(unique_ids[i,]),]
    if (length(by_id[by_id[[pageid]]==1,1]) > 1){
      print(paste("Multiple Page 1 for ID", unique_ids[i,], sep= " "))
      break
    }
    for (j in 2:max(by_id[[pageid]])){
      if (length(by_id[by_id[[pageid]]==j,1]) > 1){
        print(paste("Multiple Page", j, "for ID", unique_ids[i,], sep= " "))
        break

      }

      previous_notes <- substr(by_id[by_id[[pageid]]==j,][[notes]], 1, nchar(by_id[by_id[[pageid]]==j-1,][[notes]]))

      if (nchar(previous_notes) > 0){

        edit_distance <-utils::adist(previous_notes, by_id[by_id[[pageid]]==j-1,][[notes]])
        if (edit_distance < char_diff){ #Should only call nchar once - not do the same calculation twice
          reduced_comments[j-1,]$page_notes <- substring(by_id[by_id[[pageid]]==j,][[notes]],nchar(by_id[by_id[[pageid]]==j-1,][[notes]])+1)
        }else{
          reduced_comments[j-1,]$page_notes <- by_id[by_id[[pageid]]==j,][[notes]]
        }
        reduced_comments[j-1,]$edit_distance <- edit_distance

      }else{
        reduced_comments[j-1,]$page_notes <- by_id[by_id[[pageid]]==j,][[notes]]
        reduced_comments[j-1,]$edit_distance <- 0

      }
      reduced_comments[j-1,]$identifier <- as.numeric(unlist(unique_ids[i,]))
      reduced_comments[j-1,]$page_count <- j

    }
    full_reduced_comments <- rbind(full_reduced_comments, reduced_comments)
  }

  colnames(full_reduced_comments)[colnames(full_reduced_comments) == "identifier"] = identifier
  colnames(full_reduced_comments)[colnames(full_reduced_comments) == "page_count"] = pageid
#  full_reduced_comments <- dplyr::rename(full_reduced_comments, parse(identifier) = "identifier", parse(pageid) = "page_count")
  char_validation_set <- left_join(dataset, full_reduced_comments,
                                   by=c(pageid, identifier))

 char_validation_set

 # full_reduced_comments[-1,]
}

