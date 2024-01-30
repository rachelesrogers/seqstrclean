

#' Longest Common Substring Note Cleaning for Hybrid Method
#'
#' This function is used to apply the longest common substring method to extreme values in a dataset.
#' To be used after applying [firstnchar()] and [extremeid()]. Dataset should have
#' a "page_notes" column corresponding to the cleaned notes outcome from [firstnchar()].
#'
#' @inheritParams lcsclean
#' @param toclean column name for identifying column of notes to clean (TRUE/FALSE)
#'
#' @return a data frame
#' @export
#'
#' @examples
#' test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
#' Notes=c("The","The cat","The","The dog","The cat ran",
#' "the chicken was chased", "The goat chased the chicken"),
#' Page=c(1,2,1,2,3,1,2), cleaning = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE),
#' page_notes = c("The","The cat","The","The dog","The cat ran",
#' "the chicken was chased", "The goat chased the chicken"))
#' lcsclean_hybrid(test_dataset,"Notes",0.5,"ID","Page", "cleaning")

lcsclean_hybrid <- function(dataset, notes, propor, identifier, pageid, toclean){
  #Currently case-sensitive.
  toclean_subset <- dataset[dataset[[toclean]]==TRUE,]
  toclean_subset <- toclean_subset[!is.na(toclean_subset[[identifier]]),]

  reduced_comments_substring <- data.frame(page_count = NA, lcs_notes=NA, identifier=NA)
  unique_ids <- unique(dplyr::select(toclean_subset,tidyselect::all_of(identifier)))

  for (i in 1:dim(unique_ids)[1]){
    reduced_comments <- data.frame(page_count = NA, lcs_notes=NA, identifier=NA)

    by_id <- toclean_subset[toclean_subset[[identifier]]==unlist(unique_ids[i,]),]
    page_list <- unique(by_id[[pageid]])

    if (dim(by_id[by_id[[pageid]]==1,])[1] > 1){
      print(paste("Multiple Page 1 for ID", unique_ids[i,], sep= " "))
      break
    }
    pg_count <- 0
    for (j in page_list){
      pg_count <- pg_count + 1
      if (j == 1){
        reduced_comments[j,]$page_notes <- by_id[by_id[[pageid]]==j,][[notes]]
        reduced_comments[j,]$identifier <- unlist(unique_ids[i,])
        reduced_comments[j,]$page_count <- j

      }else {
        if (dim(by_id[by_id[[pageid]]==j,])[1] > 1){
          print(paste("Multiple Page", j, "for ID", unique_ids[i,], sep= " "))
          break

        }
        ## Removing Emojis ####
        previous_notes <- gsub("[^\x01-\x7F]", "",
                               dataset[dataset[[pageid]]==j-1 & dataset[[identifier]]==unlist(unique_ids[i,]),][[notes]])
        previous_notes <- gsub("\r", "", previous_notes)
        previous_notes <- gsub("\n", "", previous_notes)
        current_notes <- gsub("[^\x01-\x7F]", "",by_id[by_id[[pageid]]==j,][[notes]])
        current_notes <- gsub("\r", "", current_notes)
        current_notes <- gsub("\n", "", current_notes)
        reduced_comments[pg_count,]$lcs_notes <- current_notes

        if(is.na(previous_notes)){
          previous_notes <- ""
        }

        if (nchar(previous_notes) > 0){

          longest_sub <- PTXQC::LCS(previous_notes, reduced_comments[pg_count,]$lcs_notes)
          longest_val <- propor*nchar(previous_notes)

          while (nchar(longest_sub) > longest_val){
            reduced_comments[pg_count,]$lcs_notes <- gsub(longest_sub,"",
                                                          reduced_comments[pg_count,]$lcs_notes,fixed=TRUE)
            longest_sub <- PTXQC::LCS(previous_notes, reduced_comments[pg_count,]$lcs_notes)
          }

        }
        reduced_comments[pg_count,]$identifier <- unlist(unique_ids[i,])
        reduced_comments[pg_count,]$page_count <- j

      }
    }
    reduced_comments_substring <- rbind(reduced_comments_substring, reduced_comments)
  }
  colnames(reduced_comments_substring)[colnames(reduced_comments_substring) == "identifier"] = identifier
  colnames(reduced_comments_substring)[colnames(reduced_comments_substring) == "page_count"] = pageid
  char_validation_set <- dplyr::left_join(dataset, reduced_comments_substring,
                                          by=c(pageid, identifier))

  char_validation_set$hybrid_notes <-
    ifelse(!is.na(char_validation_set$lcs_notes),
           char_validation_set$lcs_notes, char_validation_set$page_notes)
  char_validation_set
}
