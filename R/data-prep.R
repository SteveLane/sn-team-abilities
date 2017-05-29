################################################################################
################################################################################
## Title: Data Preparation
## Author: Steve Lane
## Date: Saturday, 27 May 2017
## Synopsis: Pull down data and transform into table.
## Time-stamp: <2017-05-29 21:36:28 (slane)>
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

## Now in long format for ease of manipulation
scoresHome <- scores %>%
    select(-contains("away"), -num_range("homeQ", 1:4), awayScore) %>%
    rename(`Team Name` = `Home team`,
           scoreFor = homeScore,
           scoreAgainst = awayScore,
           Win = homeWin,
           Draw = homeDraw,
           Loss = homeLoss,
           Points = homePoints
           )
scoresAway <- scores %>%
    select(-contains("home"), -num_range("awayQ", 1:4), homeScore) %>%
    rename(`Team Name` = `Away team`,
           scoreFor = awayScore,
           scoreAgainst = homeScore,
           Win = awayWin,
           Draw = awayDraw,
           Loss = awayLoss,
           Points = awayPoints
           )
scoresLong <- bind_rows(scoresHome, scoresAway) %>%
    group_by(`Team Name`) %>% arrange(`Round Number`) %>%
    mutate(`Cumulative Points` = cumsum(Points),
           For = cumsum(scoreFor),
           Against = cumsum(scoreAgainst),
           Percentage = For / Against * 100
           )

## Show ladder after home and away season (works!)
scoresLong %>% filter(`Round Number` == max(`Round Number`)) %>%
    select(`Team Name`, `Cumulative Points`, For, Against, Percentage) %>%
    arrange(desc(`Cumulative Points`), desc(Percentage))
