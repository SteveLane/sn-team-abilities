#' Updates the season match data
#'
#' \code{updateData} downloads the provided round, and joins with all seasonal
#' data.
#'
#' @param year Integer. Year of the competition.
#' @param round Integer. The round number to download and join.
#' @param comp_id A string identifying which season the game is
#'     in. \code{comp_id} is different depending on regular season or finals.
#'
#' @return A dataframe containing the full (to date) seasons data. As a
#'     by-product, the function saves the data.
updateData <- function(year, round, comp_id = "10393") {
  if (round != 1) {
    ## Pop in some backups for good measure
    file.copy(
      here("data-raw", paste0("season_", year, ".rds")),
      here("data-raw/backups/",
        paste0("season_", year, "_", lubridate::today(), ".rds"))
    )
    file.copy(
      here("data-raw", paste0("players_", year, ".rds")),
      here("data-raw/backups/",
        paste0("players_", year, "_", lubridate::today(), ".rds"))
    )
    season <- readRDS(here("data-raw", paste0("season_", year, ".rds")))
    players <- readRDS(here("data-raw", paste0("players_", year, ".rds")))
    if (max(season[['round']]) >= round) {
      warning("Up-to-date data is already available; proceed to modelling.\n")
    }
  }
  for (i in seq_len(4)) {
    data <- downloadMatch(comp_id, round, i)
    tidied_data <- tidyMatch(data)
    tidied_players <- tidyPlayers(data)
    if (round == 1 && i == 1) {
      season <- tidied_data
      players <- tidied_players
    } else {
      season <- bind_rows(season, tidied_data)
      players <- bind_rows(players, tidied_players)
    }
  }
  saveRDS(season, here("data-raw", paste0("season_", year, ".rds")))
  saveRDS(players, here("data-raw", paste0("players_", year, ".rds")))
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
  dirname <- paste0("data/", year, "/sn-assets-round-", round)
  teamLookup <- readRDS(here("data", "teamLookup.rds"))
  game <- readRDS(here(dirname, "game.rds"))
  predictions <- readRDS(here(dirname, "predictions.rds")) %>%
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
      `Home Goals` = home_score,
      `Away Goals` = away_score,
      Winner)
  results
}

#' Updates the finals match data
#'
#' \code{updateData} downloads the provided round, and joins with all seasonal
#' data.
#'
#' @param round Integer. The round number (in sequence as per modelling).
#' @param comp_id A string identifying which season the game is
#'     in. \code{comp_id} is different depending on regular season or finals.
#' @param finals_round Integer. The round number (of the finals)
#'
#' @return A dataframe containing the full (to date) seasons data. As a
#'     by-product, the function saves the data.
updateFinals <- function(year, round, comp_id, finals_round) {
  season <- readRDS(here("data-raw", paste0("season_", year, ".rds")))
  players <- readRDS(here("data-raw", paste0("players_", year, ".rds")))
  if (max(season[['round']]) == round) {
    message("Up-to-date data is already available; proceed to modelling.\n")
  }
  for (i in seq_len(4)) {
    data <- downloadMatch(comp_id, finals_round, i)
    if (!is.null(data)) {
      tidied_data <- tidyMatch(data)
      tidied_players <- tidyPlayers(data)
      season <- bind_rows(season, tidied_data)
      players <- bind_rows(players, tidied_players)
    }
  }
  saveRDS(season, here("data-raw", paste0("season_", year, ".rds")))
  saveRDS(players, here("data-raw", paste0("players_", year, ".rds")))
}
