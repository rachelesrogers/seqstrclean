% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lcsclean.R
\name{lcsclean}
\alias{lcsclean}
\title{Longest Common Substring Note Cleaning}
\usage{
lcsclean(dataset, notes, propor, identifier, pageid)
}
\arguments{
\item{dataset}{the dataset containing the notes}

\item{notes}{the column name for the notes}

\item{propor}{minimum necessary of matching proportion of previous notes for removal}

\item{identifier}{column name for uniquely identifying identification}

\item{pageid}{column name for page number}
}
\value{
a data frame
}
\description{
Longest Common Substring Note Cleaning
}
\examples{
test_dataset <- data.frame(ID=c("1","1","2","2","1"),
Notes=c("The","The cat","The","The dog","The cat ran"),
Page=c(1,2,1,2,3))
lcsclean(test_dataset,"Notes",0.5,"ID","Page")
}
