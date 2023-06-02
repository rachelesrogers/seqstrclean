firstnchar <- function(dataset, notes, char_diff, identifier, pageid){

  full_reduced_comments <- data.frame(page_count = NA, page_notes=NA, edit_distance=NA, identifier=NA)

  unique_ids <- dataset %>% select(all_of(identifier)) %>% unique()

  for (i in 1:dim(unique_ids)[1]){
    reduced_comments <- data.frame(page_count = NA, page_notes=NA, edit_distance=NA, identifier=NA)
    by_id <- dataset[dataset[[identifier]]==as.numeric(unique_ids[i,]),]
    if (length(by_id[by_id[[pageid]]==1,1]) > 1){
      print(paste("Multiple Page 1 for ID", unique_ids[i,], sep= " "))
      end
    }
    for (j in 2:max(by_id[[pageid]])){
      if (length(by_id[by_id[[pageid]]==j,1]) > 1){
        print(paste("Multiple Page", j, "for ID", unique_ids[i], sep= " "))

      }

      previous_notes <- substr(by_id[by_id[[pageid]]==j,][[notes]], 1, nchar(by_id[by_id[[pageid]]==j-1,][[notes]]))

      if (nchar(previous_notes) > 0){

        edit_distance <-adist(previous_notes, by_id[by_id[[pageid]]==j-1,][[notes]])
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
      reduced_comments[j-1,]$identifier <- unique_ids[i,]
      reduced_comments[j-1,]$page_count <- j

    }
    full_reduced_comments <- rbind(full_reduced_comments, reduced_comments)
  }
#   char_validation_set <- left_join(dataset, full_reduced_comments,
#                                    by=paste("c(\"",pageid,"\",\"",identifier,"\")", sep=""))
#
# char_validation_set

  full_reduced_comments[-1,]
}

