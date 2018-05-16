#' Updates the season match data
#'
#' \code{updateData} downloads the provided round, and joins with all seasonal
#' data.
#'
#' @param round Integer. The round number to download and join.
#'
#' @return A dataframe containing the full (to date) seasons data. As a
#'     by-product, the function saves the data.
updateData <- function(round) {
    if (round != 1) {
        season_2018 <- readRDS(here("data-raw", "season_2018.rds"))
        players_2018 <- readRDS(here("data-raw", "players_2018.rds"))
        if (max(season_2018[['round']]) == round) {
            return(season_2018)
        }
    }
    for (i in seq_len(4)) {
        data <- downloadMatch("10393", round, i)
        tidied_data <- tidyMatch(data)
        tidied_players <- tidyPlayers(data)
        if (round == 1 && i == 1) {
            season_2018 <- tidied_data
            players_2018 <- tidied_players
        } else {
            season_2018 <- bind_rows(season_2018, tidied_data)
            players_2018 <- bind_rows(players_2018, tidied_players)
        }
    }
    saveRDS(season_2018, here("data-raw", "season_2018.rds"))
    saveRDS(players_2018, here("data-raw", "players_2018.rds"))
    season_2018
}

#' Matches the predictions
#'
#' \code{matchPredictions} loads in the predictions, and matches them to the
#' actual results.
#'
#' @param round Integer. The round number to match.
#'
#' @return A dataframe containing the predictions and actual results.
matchPredictions <- function(round, year, results) {
    rnd <- paste0("round", round, "-", year)
    teamLookup <- readRDS(here("data", "teamLookup.rds"))
    game <- readRDS(here("Rmd", "sn-assets", rnd, "game.rds"))
    predictions <- readRDS(here("Rmd", "sn-assets", rnd,
                                "predictions.rds")) %>%
        select(-Away)
    home <- results %>%
        ungroup() %>%
        filter(isHome == 1) %>%
        select(squadName, home_score = goals, score_diff)
    away <- results %>%
        ungroup %>%
        filter(isHome == 0) %>%
        select(squadName, away_score = goals)
    results <- left_join(game, home,
                         by = c("homeTeam" = "squadName")) %>%
        left_join(., away, by = c("awayTeam" = "squadName")) %>%
        left_join(., predictions, by = c("homeTeam" = "Home")) %>%
        mutate(Winner = case_when(
                   score_diff > 0 ~ homeTeam,
                   score_diff < 0 ~ awayTeam,
                   TRUE ~ "Draw")) %>%
        select(Home = homeTeam, Away = awayTeam,
               `Chance of home team winning`,
               `Home Score` = home_score,
               `Away Score` = away_score,
               Winner)
    results
}
