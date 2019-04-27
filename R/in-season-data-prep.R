#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season data preparation.
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Produces data for modelling in-season matches.
## Time-stamp: <2019-04-27 12:02:00 (slane)>
################################################################################
################################################################################

################################################################################
## Command line options.
library(methods)
library(docopt)
doc <- "
Usage:
  in-season-data-prep.R year <year> round <round> comp_id <comp_id> home <home> away <away>
  in-season-data-prep.R -h | --help

Options:
  -h --help        Show this help text.
"
opt <- docopt(doc)

################################################################################
## Libraries and loads for the model.
library(here)
library(dplyr)
library(superNetballR)
library(tidyr)
library(purrr)
source(here("R", "updateData.R"))
source(here("R", "fit_funs.R"))

## check that it contains up to date information
round <- as.integer(opt$round)
year <- as.integer(opt$year)
prev_round <- round - 1
if (round == 1) {
  ## Load previous year's data just to have a consistent framework.
  fname <- paste0("data-raw/season_", year - 1, ".rds")
  data <- readRDS(here(fname))
} else {
  ## Compile and load the appropriate seasons data
  updateData(year, prev_round, opt$comp_id)
  fname <- paste0("data-raw/season_", year, ".rds")
  data <- readRDS(here(fname))
  ## Match the results and predictions (if in round 2 or greater). Produce ladder.
  match_results <- matchResults(data) %>%
    filter(round == prev_round)
  ladder <- ladders(data, prev_round)
  results <- matchPredictions(prev_round, opt$year, match_results)
}

################################################################################
## Load priors for the model, and the model statement.
init_abilities <- readRDS(here("data", paste0("shrunken_abilities_", year, ".rds")))
abilities_sd <- readRDS(here("data", paste0("initial_abilities_sd_", year, ".rds")))
hga_post <- readRDS(here("data", paste0("initial_hga_", year, ".rds")))
hga_sd <- readRDS(here("data", paste0("initial_hga_sd_", year, ".rds")))
sigma_y <- readRDS(here("data", paste0("initial_sigma_y_", year, ".rds")))

################################################################################
## Transform data into appropriate format for the Stan model.
model_data <- data %>%
  matchResults() %>%
  select(-goals, -squadId, -squadNickname, -squadCode, -points) %>%
  group_by(round, game) %>%
  nest() %>%
  group_by(round, game) %>%
  mutate(game_results = map(data, spreadGame)) %>%
  select(-data) %>%
  unnest() %>%
  filter(round <= prev_round)

teamLookup <- readRDS(here("data", "teamLookup.rds"))
model_data <- left_join(model_data, teamLookup,
  by = c("homeTeam" = "squadName")) %>%
  rename(homeInt = squadInt, homeColour = squadColour) %>%
  left_join(., teamLookup, by = c("awayTeam" = "squadName")) %>%
  rename(awayInt = squadInt, awayColour = squadColour)

## format the round data
home <- as.integer(unlist(strsplit(opt$home, " ")))
away <- as.integer(unlist(strsplit(opt$away, " ")))
round_data <- tibble(homeSquad = home, awaySquad = away) %>%
  left_join(., teamLookup, by = c("homeSquad" = "squadInt")) %>%
  rename(homeTeam = squadName,
    homeColour = squadColour) %>%
  left_join(., teamLookup, by = c("awaySquad" = "squadInt")) %>%
  rename(awayTeam = squadName,
    awayColour = squadColour)
stan_data <- with(
  model_data, list(nteams = 8, ngames = nrow(model_data),
    nrounds = ifelse(round == 1, 1, max(round)), round_no = round,
    home = homeInt, away = awayInt, score_diff = score_diff,
    init_ability = init_abilities,
    init_sd = cbind(abilities_sd[,2], abilities_sd[,3]),
    mu_hga = hga_post$value,
    init_sigma_hga = as.numeric(hga_sd),
    init_sigma_y = as.numeric(sigma_y),
    ngames_pred = length(home),
    pred_home = round_data$homeSquad,
    pred_away = round_data$awaySquad,
    first_round = ifelse(round == 1, 1, 0))
)

################################################################################
## Save appropriate outputs and summaries.
dirname <- paste0("data/sn-assets-", opt$year, "-round-", opt$round)
if (!dir.exists(here(dirname))) {
  dir.create(here(dirname), recursive = TRUE)
}
saveRDS(
  stan_data,
  here(dirname, "stan_data.rds")
)
saveRDS(
  round_data,
  here(dirname, "game.rds")
)
if (round > 1) {
  ## save the matched results/ladder.
  saveRDS(results,
    here(dirname, "results_match.rds"))
}
