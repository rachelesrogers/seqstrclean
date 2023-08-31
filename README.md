
<!-- README.md is generated from README.Rmd. Please edit that file -->

# seqstrclean

<!-- badges: start -->
<!-- badges: end -->

The goal of seqstrclean is to clean sequential strings. In cumulative
note taking, notes from a previous section may be saved alongside notes
from the current section. This package aims to remove the previous
section’s notes, leaving only notes from the current section. For
example, a person may take the note: “A cat ran up a tree.” initially,
then add “The cat was chased by a dog”. The notepad would then show: “A
cat ran up a tree. The cat was chased by a dog”. This package is meant
to separate the notes into the two parts based on the different saves of
the notepad.

The firstnchar function compares the beginning of the latest notes to
the previous section, and removes from the latest notes if they are
similar enough (determined by edit distance).

The lcsclean function compares the entirety of both note sheets and
locates the longest common substring between the two, which is removed
from the latest note sheet if it represents a significant portion of the
previous notes.

## Installation

You can install the development version of seqstrclean from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rachelesrogers/seqstrclean")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(seqstrclean)
## basic example code
```
