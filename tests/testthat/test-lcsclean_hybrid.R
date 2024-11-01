test_that("example works without white space", {
  test_dataset <- data.frame(ID=c("1","1","2","2","1", "3","3"),
  Notes=c("The","The cat","The","The dog","The cat ran",
  "the chicken was chased", "The goat chased the chicken"),
  Page=c(1,2,1,2,3,1,2), cleaning = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE),
  page_notes = c("The","The cat","The","The dog","The cat ran",
  "the chicken was chased", "The goat chased the chicken"))

  hybrid_test <- lcsclean_hybrid(test_dataset,"Notes",0.25,"ID","Page", "cleaning")
  expect_equal(hybrid_test$hybrid_notes, c("The","The cat","The","dog","The cat ran","the chicken was chased",
                                      "The goat"))
})
