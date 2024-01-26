
<!-- README.md is generated from README.Rmd. Please edit that file -->

# seqstrclean <a href="https://rachelesrogers.github.io/seqstrclean/"><img src="man/figures/logo.png" align="right" height="139" alt="seqstrclean website" /></a>

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

There are three methods used for sequential note cleaning in this
package: First N Character, Longest Common Substring, and a hybrid
method combining the two. The First N Character method is faster, while
in a small verification study the Longest Common Substring method was
more accurate. The hybrid method strikes a balance between the speed of
the First N Character method and the accuracy of the Longest Common
Substring method by only applying the Longest Common Substring method to
difficult cases (where previous text cannot be removed using the First N
Character method, or the supplied note sheet is unusually long).

### First N Character Method

The first method is the First N Character method, where the entirety of
the previous page’s notes are compared with the first n characters of
the current page’s notes (where n is the length of the previous page’s
notes). If the notes are similar enough (based on edit distance), the
first n characters will be removed from the current page.

``` r
library(seqstrclean)

test_dataset <- data.frame(ID=c("1","1","2","2","1", "3", "3"),
Notes=c("The","The cat","The","The dog","The cat ran", "the chicken was chased", "The goat chased the chicken"),
Page=c(1,2,1,2,3,1,2))

test_dataset
#>   ID                       Notes Page
#> 1  1                         The    1
#> 2  1                     The cat    2
#> 3  2                         The    1
#> 4  2                     The dog    2
#> 5  1                 The cat ran    3
#> 6  3      the chicken was chased    1
#> 7  3 The goat chased the chicken    2
```

In the test dataset shown above, there are third note-takes (identified
by ID number), and 2-3 pages of notes. The first individual wrote “The”,
“cat”, and “ran” sequentially on their notes, with one word per page.
The second individual wrote “The” and “dog” sequentially. The third
individual wrote “the chicken was chased” on the first page, and “The
goat chased the chicken” on the second page, which does not reflect
sequential note-taking. The First N Character method can be used to
separate these notes, based on what was written per page.

``` r

firstnchar(dataset=test_dataset,notes="Notes",char_diff=3,identifier="ID",pageid="Page")
#>   ID                       Notes Page                  page_notes edit_distance
#> 1  1                         The    1                         The            NA
#> 2  1                     The cat    2                         cat             0
#> 3  2                         The    1                         The            NA
#> 4  2                     The dog    2                         dog             0
#> 5  1                 The cat ran    3                         ran             0
#> 6  3      the chicken was chased    1      the chicken was chased            NA
#> 7  3 The goat chased the chicken    2 The goat chased the chicken            17
```

Here, page_notes displays the clean notes, and edit_distance refers to
the distance between the previous page of notes and the first n
character of the current page of notes. In the cases of sequential notes
(for individuals 1 and 2), the edit distance is 0, as the beginning of
the notes match the previous page’s notes. In the case of the third
individual, the edit distance is 4 (there are four substitutions
necessary to change from “goat” to “chick”), which is greater than the
set threshold of 3. Thus, the second page of the third individual’s
notes include the full text recorded on the second page (nothing was
removed).

### Longest Common Substring Method

The second method is the Longest Common Substring method, where the two
page note strings are compared in their entirity for the longest string
they have in common, above a certain threshold. This longest string is
then removed from the current page of notes, and the process is repeated
until the longest common substring is no longer above the assigned
cutoff.

``` r
test_dataset <- data.frame(ID=c("1","1","2","2","1", "3", "3"),
Notes=c("The","The cat","The","The dog","The cat ran", "the chicken was chased", "The goat chased the chicken"),
Page=c(1,2,1,2,3,1,2))
```

The dataset above is the same as that of the First N Character method,
aside from the third notetaker. In this case, the third notetaker wrote
“the chicken was chased” on the first page, and “The goat chased the
chicken” on the second page.

``` r
lcsclean(test_dataset,"Notes",0.5,"ID","Page")
#>   ID                       Notes Page                  page_notes
#> 1  1                         The    1                         The
#> 2  1                     The cat    2                         cat
#> 3  2                         The    1                         The
#> 4  2                     The dog    2                         dog
#> 5  1                 The cat ran    3                         ran
#> 6  3      the chicken was chased    1      the chicken was chased
#> 7  3 The goat chased the chicken    2 The goat chased the chicken
```

When the proportion threshold is set to 0.5, nothing is removed from the
third note taker’s second page, as the longest common substring (“the
chicken”) represents exactly half of the characters in the page.

``` r
lcsclean(test_dataset,"Notes",0.49,"ID","Page")
#>   ID                       Notes Page             page_notes
#> 1  1                         The    1                    The
#> 2  1                     The cat    2                    cat
#> 3  2                         The    1                    The
#> 4  2                     The dog    2                    dog
#> 5  1                 The cat ran    3                    ran
#> 6  3      the chicken was chased    1 the chicken was chased
#> 7  3 The goat chased the chicken    2       The goat chased
```

When the threshold is lowered to 0.49, “the chicken” is removed from the
second page of notes. This would represent the removal of the longest
common substring after one iteration, as the next longest substring
(“chased”) does is below the cutoff threshold.

``` r
lcsclean(test_dataset,"Notes",0.25,"ID","Page")
#>   ID                       Notes Page             page_notes
#> 1  1                         The    1                    The
#> 2  1                     The cat    2                    cat
#> 3  2                         The    1                    The
#> 4  2                     The dog    2                    dog
#> 5  1                 The cat ran    3                    ran
#> 6  3      the chicken was chased    1 the chicken was chased
#> 7  3 The goat chased the chicken    2              The goat
```

However, if the threshold is reduced further to 0.25 (or 1/4 of the
previous notes), “chased” will be removed from the second page of notes
as well, leaving only “the goat” in the clean notes.

### Hybrid Method

The third method attempts to combine the speed of the First N Character
method with the accuracy of the Longest Common Substring method. This
works by first applying the First N Character method, then applying the
Longest Common Substring method for difficult cases - either when the
edit distance is too large for the First N Character method to remove
notes (such as the chicken chasing example above), or when the length of
the cleaned notes is unusually large. Unusually large is defined as more
than a set number of standard deviations above the mean clean note
length, and is calculated using the extremeid function.

For this method, a larger dataset may be necessary to demonstrate the
presence of outliers, in terms of note size.

``` r
library(kableExtra)
#> Warning: package 'kableExtra' was built under R version 4.3.2
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following object is masked from 'package:kableExtra':
#> 
#>     group_rows
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
fnc<-firstnchar(validation_dataset, "notes", 16, "clean_prints", "page_count")

kable(head(fnc, 3))
```

<table>
<thead>
<tr>
<th style="text-align:right;">
clean_prints
</th>
<th style="text-align:right;">
page_count
</th>
<th style="text-align:left;">
notes
</th>
<th style="text-align:left;">
corrected_notes
</th>
<th style="text-align:left;">
algorithm
</th>
<th style="text-align:left;">
page_notes
</th>
<th style="text-align:right;">
edit_distance
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:right;">
NA
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:left;">
discharge firearm in business- felony, not guilty
</td>
<td style="text-align:left;">
discharge firearm in business- felony, not guilty
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
discharge firearm in business- felony, not guilty
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:left;">

discharge firearm in business- felony, not guilty

ski mask. no money, no injuries. 9mm, arrested after confiscated and
testing.
</td>
<td style="text-align:left;">
ski mask. no money, no injuries. 9mm, arrested after confiscated and
testing.
</td>
<td style="text-align:left;">
Yes
</td>
<td style="text-align:left;">
ski mask. no money, no injuries. 9mm, arrested after confiscated and
testing.
</td>
<td style="text-align:right;">
0
</td>
</tr>
</tbody>
</table>

Above demonstrates the validation dataset cleaned using the First N
Character method, with a character difference cutoff of 16 (meaning that
up to and including a 15 character difference is acceptable). In order
to determine if there are any extremely long note pages that should be
considered for the Longest Common Substring method, the extremeid
function is applied. Here, extreme values are defined as those that are
larger than 4 standard deviations above the mean page length, based on
algorithm condition (because these resulted in different pages, and thus
different notes).

``` r

extreme_dataset <- extremeid(dataset=fnc, extreme=4, clean_notes="page_notes", 
                             pageid="page_count", group_list = c("algorithm"))

kable(head(extreme_dataset %>% filter(extreme_value==TRUE, clean_prints==39) %>% subset(select=c("clean_prints", "page_count", "notes", "corrected_notes", "page_notes", "extreme_value")), 1))
```

<table>
<thead>
<tr>
<th style="text-align:right;">
clean_prints
</th>
<th style="text-align:right;">
page_count
</th>
<th style="text-align:left;">
notes
</th>
<th style="text-align:left;">
corrected_notes
</th>
<th style="text-align:left;">
page_notes
</th>
<th style="text-align:left;">
extreme_value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
39
</td>
<td style="text-align:right;">
12
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.

Q: Is there something fixed about the amount of what has to be found to
constitute sufficient agreement? A: No, there is not a fixed amount or a
numerical value for my visual comparison. For the algorithm, however, a
score above 0.8 is a general indicator of sufficient agreement.
</td>
<td style="text-align:left;">
Q: Is there something fixed about the amount of what has to be found to
constitute sufficient agreement? A: No, there is not a fixed amount or a
numerical value for my visual comparison. For the algorithm, however, a
score above 0.8 is a general indicator of sufficient agreement.
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.

Q: Is there something fixed about the amount of what has to be found to
constitute sufficient agreement? A: No, there is not a fixed amount or a
numerical value for my visual comparison. For the algorithm, however, a
score above 0.8 is a general indicator of sufficient agreement.
</td>
<td style="text-align:left;">
TRUE
</td>
</tr>
</tbody>
</table>

The comments that should then be considered using the Longest Common
Substring method are those with an extremely large amount of notes
(extreme_value=TRUE), and those with an edit distance above the cutoff
used in the First N Character method (larger than 15). Note that the
previous page of notes is also necessary for comparison in the Longest
Common Substring method.

``` r

extreme_dataset <- extreme_dataset %>% mutate(apply_lcs = ifelse(!is.na(edit_distance) & (extreme_value==TRUE | edit_distance > 15), TRUE, FALSE))

kable(head(extreme_dataset %>% filter(apply_lcs==TRUE, clean_prints==39) %>% subset(select=c("clean_prints", "page_count", "notes", "page_notes", "apply_lcs")), 1))
```

<table>
<thead>
<tr>
<th style="text-align:right;">
clean_prints
</th>
<th style="text-align:right;">
page_count
</th>
<th style="text-align:left;">
notes
</th>
<th style="text-align:left;">
page_notes
</th>
<th style="text-align:left;">
apply_lcs
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
39
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.
</td>
<td style="text-align:left;">
TRUE
</td>
</tr>
</tbody>
</table>

Observations where “apply_lcs” is true indicate those difficult cases.
They can then be run through the hybrid application of lcs to clean the
remaining notes. Due to time, this process was only completed on a
single participant.

``` r

hybrid_dataset <- lcsclean_hybrid(dataset=subset(extreme_dataset, clean_prints==39), notes="notes", propor=0.333, identifier="clean_prints", pageid="page_count", toclean="apply_lcs")

kable(head(hybrid_dataset[hybrid_dataset$apply_lcs==TRUE,] %>% subset(select=c("clean_prints", "page_count", "notes", "page_notes", "lcs_notes")), 1))
```

<table>
<thead>
<tr>
<th style="text-align:right;">
clean_prints
</th>
<th style="text-align:right;">
page_count
</th>
<th style="text-align:left;">
notes
</th>
<th style="text-align:left;">
page_notes
</th>
<th style="text-align:left;">
lcs_notes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
39
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.
</td>
<td style="text-align:left;">

In this case, the defendant - Richard Cole - has been charged with
willfully discharging a firearm in a place of business. This crime is a
felony.

Mr. Cole has pleaded not guilty to the charge.Police received a 911 call
from a convenience store clerk stating that a man had entered the store,
pulled out a firearm, fired a shot into the ceiling, and then demanded
money. The man ended up leaving the store without receiving any money
and no one was hurt by the gunshot.

The store clerk took the stand and stated that she did not get a close
enough look at the robber’s face to make an identification, because the
robber wore a ski mask.

As the cashier was pulling out the money to hand to him, she pressed a
hidden button that activated an alarm and called the police. Startled by
the alarm bells, the robber rushed out of the store.

Next, the detective testified that he arrived at the convenience store
and interviewed the clerk. The detective recovered the 9mm bullet from
the ceiling of the store, which was collected for forensic analysis.

Two days later, a police officer pulled over Richard Cole for speeding.
During a search of the Defendant’s vehicle, the detective located a 9mm
handgun, which was legally licensed to the Defendant. Because this gun
was the same caliber as the one used in the convenience store shooting,
it was confiscated for testing. Richard Cole was subsequently arrested
and charged with willfully discharging a firearm in a place of business.

terry smith: Q: What training is required to become a firearms examiner
with the local police department? A: I received my bachelor’s degree in
forensic science and in 2015 I transferred to the crime lab from the
crime scene unit. I underwent a two-year training program, which was
supervised by experienced firearms examiners; I’ve toured manufacturing
facilities and saw how firearms and ammunition were produced; and I’ve
attended several national and regional meetings of firearms examiners.
A: Yes. I received training in the use of a bullet matching algorithm.
This is an algorithm that evaluates the characteristics of two fired
bullets, in order to produce a score for the similarity of the bullets,
where more similar bullets are more likely to have been fired from the
same gun. I attended a workshop on the algorithm on 1/11/2020, held by
CSAFE - Center for Statistics and Applications in Forensic Evidence. The
training taught me to use the algorithm alongside my personal judgement.
I found that my conclusion was reflected in the similarity score
produced by the algorithm in all 21 cases. Q: How long have the state
police been using the bullet matching algorithm? A: They have been using
it since January of 2020.

Q: Have you testified in court previously using the bullet matching
algorithm? A: Yes, I have, approximately 10 times.

Q: As a firearms examiner, have you testified about your conclusions,
given the results of your testing? A: Yes, I have. A: No. When firing a
firearm there is a dynamic process because it is a contained explosion.
When the firing pin hits the primer, which is basically the initiator,
what gets it going, it will explode, burn the gun powder inside the
casing, and the bullet will travel down the barrel, picking up the
microscopic imperfections of the barrel, and the cartridge case will
slam rearward against the support mechanism. During that dynamic
process, each time it happens, a bullet will be marked slightly
differently from one to the next.

Prosecution: Your Honor, at this time I would ask that Terry Smith be
qualified as an expert in the field of firearms identification subject
to cross examination. Court: Any cross on their credentials? Defense:
No, Your Honor. Court: This witness is an expert in the area of firearms
identification. They can testify to their opinions as well as facts. Go
ahead. A: Yes. In the interior of a barrel there are raised portions
called lands and depressed areas called grooves. When a bullet passes
down the barrel, a bullet will spin and that gives it stability and
accuracy over a distance. Those raised areas are designed by the
manufacturer. They’re cut into the barrel. And each particular file has
a different combination of lands and grooves. But essentially what those
lands do is grip a bullet and spin it, and as that bullet passes down
the barrel, it scratches the random imperfections of that barrel into
the bullet. A: I place them under the comparison microscope, and I roll
the bullet around until I can see the agreement in a particular area:
unique surface contour that has sufficient agreement. At that point,
when I’ve seen that, I start to rotate the bullets around and I look at
all the different lands and grooves, impressions, for that unique
detail. When I can see those, that agreement on multiple areas of the
bullet, I identify the bullet as having sufficient agreement. A: The
algorithm uses 3D measurements to make a comparison between the surface
contours of each of the lands on each bullet. These comparisons result
in a match score between 0 and 1, where 1 indicates a clear match, and 0
indicates that there is not a match. The bullet is aligned based on the
maximum agreement between the lands, and the average match score for the
lands is computed. This average score gives an overall match score for
the entire bullet.

Q: What was the match score between the two test-fired bullets? A: The
match score was 0.976.

Q: What was the match score between the better-marked test fire bullet
and the fired evidence? A: The match score was 0.989.

Q: What does this match score indicate about the bullets? A: The match
score indicates that there is substantial similarity between the two
bullets, which suggests that they were most likely fired from the same
barrel.

Q: Is it the local police department’s protocol to have somebody else
who’s a firearms tool mark examiner in your lab review that report,
review your work, and determine if it’s correct? A: Yes.

Q: That’s what we call peer review? A: Peer review, yes.
</td>
<td style="text-align:left;">
A: No. When firing a firearm there is a dynamic process because it is a
contained explosion. When the firing pin hits the primer, which is
basically the initiator, what gets it going, it will explode, burn the
gun powder inside the casing, and the bullet will travel down the
barrel, picking up the microscopic imperfections of the barrel, and the
cartridge case will slam rearward against the support mechanism. During
that dynamic process, each time it happens, a bullet will be marked
slightly differently from one to the nextQ: Is it the local police
department’s protocol to have somebody else who’s a firearms tool mark
examiner in your lab review that report, review your work, and determine
if it’s correct?A: Yes.Q: That’s what we call peer review?A: Peer
review, yes.
</td>
</tr>
</tbody>
</table>

The above notes show the difficult cases for the First N Character
method (indicated as “page_notes”) and the Longest Common Substring
(“lcs_notes”). The hybrid column combines the two methods for the
complete notes.

## Acknowledgements

This work was funded (or partially funded) by the Center for Statistics
and Applications in Forensic Evidence (CSAFE) through Cooperative
Agreements 70NANB15H176 and 70NANB20H019 between NIST and Iowa State
University, which includes activities carried out at Carnegie Mellon
University, Duke University, University of California Irvine, University
of Virginia, West Virginia University, University of Pennsylvania,
Swarthmore College and University of Nebraska, Lincoln.
