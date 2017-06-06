################################################################################
################################################################################
## Title: Grab Data
## Author: Steve Lane
## Date: Wednesday, 07 June 2017
## Synopsis: Grab the super netball games data (stored in googlesheets).
## Time-stamp: <2017-06-07 08:02:14 (slane)>
################################################################################
################################################################################
library(dplyr)
library(googlesheets)
snGS <-
    "https://docs.google.com/spreadsheets/d/18-JY8Bbg1GOY7XecDkKpEDGuM_KF62GWz4YAq3i3oFM/pubhtml"
## Grab sheet and read in
scores <- snGS %>% gs_url() %>% gs_read() %>% select(-Timestamp)

## Total score
scores <- scores %>%
    mutate(
        homeScore = homeQ1 + homeQ2 + homeQ3 + homeQ4,
        awayScore = awayQ1 + awayQ2 + awayQ3 + awayQ4
    )

## Points per game
scores <- scores %>%
    mutate(
        homeWin = ifelse(homeScore > awayScore, 1, 0),
        awayWin = ifelse(homeScore < awayScore, 1, 0),
        homeDraw = ifelse(homeScore == awayScore, 1, 0),
        awayDraw = ifelse(homeScore == awayScore, 1, 0),
        homeLoss = ifelse(homeScore < awayScore, 1, 0),
        awayLoss = ifelse(homeScore > awayScore, 1, 0),
        homePoints = case_when(
            .$homeScore > .$awayScore ~ 2,
            .$homeScore < .$awayScore ~ 0,
            .$homeScore == .$awayScore ~ 1),
        awayPoints = 2 - homePoints
    )
if(!dir.exists("../data/")) dir.create("../data/")
saveRDS(scores, "../data/sn-scores.rds")
################################################################################
################################################################################
