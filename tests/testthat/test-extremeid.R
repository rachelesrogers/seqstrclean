test_that("example works", {
  test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
  Notes=c("The","The cat","The","The dog","The cat ran",
  "the chicken was chased", "The goat chased the chicken"),
  Page=c(1,2,1,2,3,1,2))
  cleaned_dataset<-
  firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,
  identifier="ID",pageid="Page")
  extremeid_test <- extremeid(dataset=cleaned_dataset,clean_notes="page_notes",extreme=2,pageid="Page")

  expect_equal(extremeid_test$extreme_value, c(FALSE,FALSE,FALSE,FALSE,NA,FALSE,FALSE))
})

test_that("reducing threshold works", {
  test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
                             Notes=c("The","The cat","The","The dog","The cat ran",
                                     "the chicken was chased",
                                     "It was a Tuesday, as I recall, when the goat decided to stage its violent attack.
                                     It approached the innocent chick in a casual manner, giving no hint to its true intentions."),
                             Page=c(1,2,1,2,3,1,2))
  cleaned_dataset<-
    firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,
               identifier="ID",pageid="Page")
  extremeid_test <- extremeid(dataset=cleaned_dataset,clean_notes="page_notes",extreme=1,pageid="Page")

  expect_equal(extremeid_test$extreme_value, c(FALSE,FALSE,FALSE,FALSE,NA,TRUE,TRUE))
})
