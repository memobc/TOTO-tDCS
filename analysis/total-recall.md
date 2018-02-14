Total Recall
================
Kyle Kurkela

Read it in
==========

``` r
datapath <- '/Users/kylekurkela/Google Drive/Experiments/TOTAL RECALL/Data/'
datafiles.study <- list.files(datapath,pattern='.*study.*', full.names=TRUE, recursive=TRUE)
df.study <- do.call(rbind, lapply(datafiles.study, read.csv))
```

Total time
==========

Below is a table of the maximum onset time relative to the start of the experiment for each subject. This gives us a rough idea of how much time people are taking the entire experiment as currently designed.

``` r
df.study %>%
  group_by(subjectID) %>%
  summarise(maxOnset = max(ExpOnset) / 60)
```

    ## # A tibble: 12 x 2
    ##    subjectID maxOnset
    ##    <fct>        <dbl>
    ##  1 trs001        37.2
    ##  2 trs002        37.4
    ##  3 trs003        37.5
    ##  4 trs004        37.7
    ##  5 trs005        37.1
    ##  6 trs006        37.5
    ##  7 trs007        37.1
    ##  8 trs008        37.3
    ##  9 Trs009        38.3
    ## 10 trs010        37.5
    ## 11 trs011        39.4
    ## 12 trs012        37.4

Time for each list
==================

Below is the average time it takes pariticpants to complete a list. Each participants completes a total of 16 lists. Each additional list will add an additional ~2.38 seconds onto the length of the experiment.

``` r
df.study %>%
  group_by(subjectID, listID) %>%
  summarise(maxOnset = (max(ListOnset) + 75) / 60) %>%
  ungroup() %>%
  summarize(average_time_to_complete_a_list = mean(maxOnset)) %>%
  print()
```

    ## # A tibble: 1 x 1
    ##   average_time_to_complete_a_list
    ##                             <dbl>
    ## 1                            2.28
