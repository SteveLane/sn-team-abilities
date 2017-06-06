################################################################################
################################################################################
## Title: Data Preparation
## Author: Steve Lane
## Date: Saturday, 27 May 2017
## Synopsis: Pull down data and transform into table.
## Time-stamp: <2017-06-07 08:02:37 (slane)>
################################################################################
################################################################################
library(dplyr)
library(jsonlite)
scores <- readRDS("../data/sn-scores.rds")
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
## Save as JSON for use in web? Try anyway...
scoresLongJSON <- toJSON(scoresLong, pretty = TRUE)
write(scoresLongJSON, "../data/sn-ladder.json")

## So, scores long shows the ladder/points/perc/abilities per round
## Now, need to have a list of games by team.
teams <- sort(unique(scores$`Home team`))
scoresByTeams <- lapply(teams, function(tm){
    data <- bind_rows(scores %>% filter(`Home team` == tm),
                      scores %>% filter(`Away team` == tm)) %>%
        arrange(`Round Number`)
    data
})
names(scoresByTeams) <- teams
## Save as JSON for use in web? Try anyway...
scoresByTeamsJSON <- toJSON(scoresByTeams, pretty = TRUE)
write(scoresByTeamsJSON, "../data/sn-scores-teams.json")

## Show ladder after home and away season (works!)
## scoresLong %>% filter(`Round Number` == max(`Round Number`)) %>%
##     select(`Team Name`, `Cumulative Points`, For, Against, Percentage) %>%
##     arrange(desc(`Cumulative Points`), desc(Percentage))
