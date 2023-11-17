
#' Longest Common Substring Note Cleaning for Hybrid Method
#'
#' @param dataset the dataset containing the notes
#' @param notes the column name for the notes
#' @param propor minimum necessary of matching proportion of previous notes for removal
#' @param identifier column name for uniquely identifying identification
#' @param pageid column name for page number
#' @param toclean column name for notes to clean
#'
#' @return a data frame
#' @export
#'
#' @examples


lcsclean_hybrid <- function(dataset, notes, propor, identifier, pageid, toclean){
  #Currently case-sensitive.
  toclean_subset <- dataset[dataset[[toclean]]==TRUE,]

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
