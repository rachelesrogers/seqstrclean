
#' Longest Common Substring Note Cleaning
#'
#' @param dataset the dataset containing the notes
#' @param notes the column name for the notes
#' @param propor minimum necessary of matching proportion of previous notes for removal
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
#' lcsclean(test_dataset,"Notes",0.5,"ID","Page")
lcsclean <- function(dataset, notes, propor, identifier, pageid){

  reduced_comments_substring <- data.frame(page_count = NA, page_notes=NA, identifier=NA)
  unique_ids <- unique(dplyr::select(dataset,tidyselect::all_of(identifier)))

  for (i in 1:dim(unique_ids)[1]){
    reduced_comments <- data.frame(page_count = NA, page_notes=NA, identifier=NA)

    by_id <- dataset[dataset[[identifier]]==unlist(unique_ids[i,]),]

    if (dim(by_id[by_id[[pageid]]==1,])[1] > 1){
      print(paste("Multiple Page 1 for ID", unique_ids[i,], sep= " "))
      break
    }
    for (j in 1:max(by_id[[pageid]])){
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
      previous_notes <- gsub("[^\x01-\x7F]", "",by_id[by_id[[pageid]]==j-1,][[notes]])
      current_notes <- gsub("[^\x01-\x7F]", "",by_id[by_id[[pageid]]==j,][[notes]])
      reduced_comments[j,]$page_notes <- current_notes

      if (nchar(previous_notes) > 0){

        longest_sub <- PTXQC::LCS(previous_notes, reduced_comments[j-1,]$page_notes)
        longest_val <- propor*nchar(previous_notes)

        while (nchar(longest_sub) > longest_val){
          reduced_comments[j,]$page_notes <- gsub(longest_sub,"",
                                                    reduced_comments[j,]$page_notes,fixed=TRUE)
          longest_sub <- PTXQC::LCS(previous_notes, reduced_comments[j,]$page_notes)
        }

      }
      reduced_comments[j,]$identifier <- unlist(unique_ids[i,])
      reduced_comments[j,]$page_count <- j

    }
  }
    reduced_comments_substring <- rbind(reduced_comments_substring, reduced_comments)
  }
  colnames(reduced_comments_substring)[colnames(reduced_comments_substring) == "identifier"] = identifier
  colnames(reduced_comments_substring)[colnames(reduced_comments_substring) == "page_count"] = pageid
  char_validation_set <- dplyr::left_join(dataset, reduced_comments_substring,
                                   by=c(pageid, identifier))

  char_validation_set
}
