#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: Post finals model.
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Run model post-grand final.
## Time-stamp: <2021-05-03 16:07:25 (sprazza)>
################################################################################
################################################################################

################################################################################
## Command line options.
library(methods)
library(docopt)
doc <- "
Usage:
  post-finals-model.R year <year> round <round>
  post-finals-model.R -h | --help

Options:
  -h --help        Show this help text.
"
opt <- docopt(doc)

################################################################################
## Libraries and loads for the model.
library(here)
library(dplyr)
library(rstan)
library(superNetballR)
library(tidyr)
library(purrr)
rstan::rstan_options(auto_write = TRUE)
cores <- round(parallel::detectCores() - 2)
options(mc.cores = cores)
source(here("R", "fit_funs.R"))
source(here("R", "updateData.R"))


################################################################################
## Update data with grand final outcome.
year <- as.integer(opt$year)
round <- as.integer(opt$round)
comp_id <- opt$comp_id
fname <- paste0("data-raw/season_", year, ".rds")
data <- readRDS(here(fname))
## If data is not updated, update it now
max_round <- max(data$round)
if (max_round < round) {
  download_entire_season(year, comp_id, max_round + 1)
}
## Transform
model_data <- data %>%
  matchResults() %>%
  select(-goals, -squadId, -squadNickname, -squadCode, -points) %>%
  group_by(round, game) %>%
  nest() %>%
  group_by(round, game) %>%
  mutate(game_results = map(data, spreadGame)) %>%
  select(-data) %>%
  unnest() %>%
  ## Only use home and away data
  filter(round <= 14)

teamLookup <- readRDS(here::here("data", "teamLookup.rds"))
model_data <- left_join(model_data, teamLookup,
  by = c("homeTeam" = "squadName")) %>%
  rename(homeInt = squadInt, homeColour = squadColour) %>%
  left_join(., teamLookup, by = c("awayTeam" = "squadName")) %>%
  rename(awayInt = squadInt, awayColour = squadColour)
round_data <- tibble(homeSquad = c(8), awaySquad = c(7)) %>%
  left_join(., teamLookup, by = c("homeSquad" = "squadInt")) %>%
  rename(homeTeam = squadName,
    homeColour = squadColour) %>%
  left_join(., teamLookup, by = c("awaySquad" = "squadInt")) %>%
  rename(awayTeam = squadName,
    awayColour = squadColour)

################################################################################
## Run model to get final abilities
model <- stan_model(here("stan/abilities_model.stan"))
init_abilities <- readRDS(here("data", paste0(year, "/shrunken_abilities.rds")))
abilities_sd <- readRDS(here("data", paste0(year, "/initial_abilities_sd.rds")))
hga_post <- readRDS(here("data", paste0(year, "/initial_hga.rds")))
hga_sd <- readRDS(here("data", paste0(year, "/initial_hga_sd.rds")))
sigma_y <- readRDS(here("data", paste0(year, "/initial_sigma_y.rds")))
stan_data <- with(
  model_data, list(nteams = 8, ngames = nrow(model_data),
    nrounds = max(round), round_no = round, home = homeInt,
    away = awayInt, score_diff = score_diff,
    init_ability = init_abilities,
    init_sd = cbind(abilities_sd[,2], abilities_sd[,3]),
    mu_hga = hga_post$value,
    init_sigma_hga = as.numeric(hga_sd),
    init_sigma_y = as.numeric(sigma_y),
    ngames_pred = c(1),
    pred_home = as.array(round_data$homeSquad),
    pred_away = as.array(round_data$awaySquad),
    first_round = 0)
)
output <- sampling(
  model,
  data = stan_data,
  iter = 2000,
  chains = 12,
  thin = 5,
  open_progress = FALSE,
  control = list(adapt_delta = 0.95,
    max_treedepth = 10)
)

################################################################################
## Final abilities.
abilities <- rstan::extract(output, "a")$a
abilities <- as.data.frame(abilities) %>%
    gather(game, Ability) %>%
    group_by(game) %>%
    summarise(
        ll1 = quantile(Ability, 0.1),
        ll2 = quantile(Ability, 0.25),
        med = quantile(Ability, 0.5),
        ul1 = quantile(Ability, 0.9),
        ul2 = quantile(Ability, 0.75),
        sigma = sd(Ability)
    )
ids <- t(sapply(abilities$game, splitRound)) %>%
    as_tibble() %>%
    unnest()
abilities <- bind_cols(ids, abilities) %>%
    left_join(., teamLookup, by = "squadInt")
sq_cols <- teamLookup$squadColour
names(sq_cols) <- teamLookup$squadName
pl_abilities <- ggplot(abilities, aes(x = Round, y = med)) +
    geom_ribbon(aes(ymin = ll1, ymax = ul1, fill = squadName,
                    alpha = 0.05)) +
    geom_ribbon(aes(ymin = ll2, ymax = ul2, fill = squadName,
                    alpha = 0.05)) +
    scale_fill_manual(values = sq_cols, guide = "none") +
    scale_alpha(guide = "none") +
    geom_line(aes(colour = squadName), lwd = 2) +
    scale_colour_manual(values = sq_cols, guide = "none") +
    geom_hline(aes(yintercept = 0), colour = "darkgrey") +
    facet_wrap(~ squadName, nrow = 2) +
    ylab("Ability")

################################################################################
## Home ground advantage
hga <- rstan::extract(output, "hga")$hga
hga <- as.data.frame(hga)
names(hga) <- teamLookup$squadName
hga <- hga %>%
    gather(squadName, hga) %>%
    group_by(squadName) %>%
    summarise(
        ll1 = quantile(hga, 0.1),
        ll2 = quantile(hga, 0.25),
        med = quantile(hga, 0.5),
        ul1 = quantile(hga, 0.9),
        ul2 = quantile(hga, 0.75)
    )
pl_hga <- ggplot(hga, aes(x = forcats::fct_reorder(squadName, med),
                          colour = squadName)) +
    geom_linerange(aes(ymin = ll1, ymax = ul1, alpha = 0.05), lwd = 2) +
    geom_linerange(aes(ymin = ll2, ymax = ul2, alpha = 0.05), lwd = 2.5) +
    geom_point(aes(y = med), size = 4, fill = "white", shape = 21) +
    geom_hline(aes(yintercept = 0), colour = "darkgrey") +
    scale_colour_manual(values = sq_cols, guide = "none") +
    scale_alpha(guide = "none") +
    xlab("Squad") +
    ylab("Home ground advantage") +
    coord_flip()

################################################################################
## Priors for next season.
next_year <- year + 1
abilities_latest <- abilities %>%
  filter(Round == 14) %>%
  select(squadInt, squadName, med, sigma)
abilities_sd <- fitPosteriorTeams(output, "sigma_eta", teamLookup)
hga_post <- rstan::extract(output, "hga")$hga %>%
                                 as.data.frame()
names(hga_post) <- teamLookup$squadName
hga_post <- hga_post %>%
  gather(squadName, value) %>%
  group_by(squadName) %>%
  summarise(value = median(value))
## Singular fits
hga_sd <- fitPosteriorSingle(output, "sigma_hga")
sigma_y <- fitPosteriorSingle(output, "sigma_y")
## Shrink the final abilities
abilities_sd <- abilities_sd %>%
  mutate(mean = shape / rate)
stan_shrink <- with(abilities_latest,
  list(nteams = nrow(abilities_latest), ability = med,
    ability_sd = abilities_sd$mean))
shrink_model <- stan_model(here("stan", "shrink_abilities.stan"))
shrink <- sampling(
  shrink_model,
  data = stan_shrink,
  iter = 2000,
  chains = cores,
  open_progress = FALSE,
  control = list(adapt_delta = 0.95, max_treedepth = 10)
)
new_ability <- rstan::extract(shrink, "theta")$theta
new_ability <- apply(new_ability, 2, median)

################################################################################
## Save out assets etc.
dirname <- paste0("data/", next_year, "/pre-season-abilities")
if (!dir.exists(here(dirname))) {
  dir.create(here(dirname), recursive = TRUE)
}
ggsave(
  here(dirname, "final-abilities.png"),
  pl_abilities, width = 17.5, height = 35 / (1 + sqrt(5))
)
ggsave(
  here(dirname, "hga.png"),
  pl_hga,
  width = 17.5, height = 35 / (1 + sqrt(5))
)
saveRDS(
  abilities_latest,
  here("data", paste0(next_year, "/initial_abilities.rds"))
)
saveRDS(
  new_ability,
  here("data", paste0(next_year, "/shrunken_abilities.rds"))
)
saveRDS(
  abilities_sd,
  here("data", paste0(next_year, "/initial_abilities_sd.rds"))
)
saveRDS(hga_post, here("data", paste0(next_year, "/initial_hga.rds")))
saveRDS(hga_sd, here("data", paste0(next_year, "/initial_hga_sd.rds")))
saveRDS(sigma_y, here("data", paste0(next_year, "/initial_sigma_y.rds")))
