################################################################################
################################################################################
## Title: Data Preparation
## Author: Steve Lane
## Date: Saturday, 27 May 2017
## Synopsis: Pull down data and transform into table.
## Time-stamp: <2017-05-28 17:23:35 (steve)>
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
        awayWin = 1 - homeWin,
        homeDraw = ifelse(homeScore == awayScore, 1, 0),
        awayDraw = 1 - awayDraw,
        homeLoss = ifelse(homeScore < awayScore, 1, 0),
        awayLoss = 1 - awayLoss,
        homePoints = case_when(
            .$homeScore > .$awayScore ~ 2,
            .$homeScore < .$awayScore ~ 0,
            .$homeScore == .$awayScore ~ 1),
        awayPoints = 2 - homePoints
    )
