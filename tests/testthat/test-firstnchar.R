test_that("basic example works", {
  test_dataset <- data.frame(ID=c("1","1","2","2","1", "3", "3"),
  Notes=c("The","The cat","The","The dog","The cat ran",
  "the chicken was chased", "The goat chased the chicken"),
  Page=c(1,2,1,2,3,1,2))
  first_test <- firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,identifier="ID",pageid="Page")
  expect_equal(first_test$page_notes, c("The"," cat","The"," dog"," ran","the chicken was chased",
                                        "The goat chased the chicken"))
})
