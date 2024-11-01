test_that("example works with trimming", {
  test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
  Notes=c("The","The cat","The","The dog","The cat ran",
  "the chicken was chased", "The goat chased the chicken"),
  Page=c(1,2,1,2,3,1,2))


  lcs_test <-   lcsclean(test_dataset,"Notes",0.5,"ID","Page")
  expect_equal(lcs_test$page_notes, c("The","cat","The","dog","ran","the chicken was chased",
                                        "The goat chased the chicken"))
})
