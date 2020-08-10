#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season model. (no HGA)
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Fits the model to in-season matches, without HGA (season 2020 is a
## bit weird!)
## Time-stamp: <2019-05-07 16:45:26 (slane)>
################################################################################
################################################################################

################################################################################
## Command line options.
library(methods)
library(docopt)
doc <- "
Usage:
  in-season-model.R year <year> round <round> mname <mname>
  in-season-model.R -h | --help

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
library(parallel)
library(cowplot)
library(forcats)
rstan::rstan_options(auto_write = TRUE)
cores <- round(parallel::detectCores() - 2)
options(mc.cores = cores)
source(here("R", "fit_funs.R"))
source(here("R", "ggsteve.R"))
theme_set(theme_steve(base_size = 24))

## load the appropriate seasons data
year <- as.integer(opt$year)
round <- as.integer(opt$round)
dirname <- paste0("data/", year, "/sn-assets-round-", round)
stan_data <- readRDS(here(dirname, "stan_data.rds"))
round_data <- readRDS(here(dirname, "game.rds"))
teamLookup <- readRDS(here("data", "teamLookup.rds"))

################################################################################
## Run the model.
model <- stan_model(here("stan", opt$mname))
output <- sampling(
  model,
  data = stan_data,
  iter = 4000,
  chains = 6,
  thin = 5,
  open_progress = FALSE,
  control = list(adapt_delta = 0.95,
    max_treedepth = 10)
)

################################################################################
## Abilities and HGA plots
abilities <- rstan::extract(output, "a")$a
abilities <- as.data.frame(abilities) %>%
  gather(game, Ability) %>%
  group_by(game) %>%
  summarise(
    ll1 = quantile(Ability, 0.1),
    ll2 = quantile(Ability, 0.25),
    med = quantile(Ability, 0.5),
    ul1 = quantile(Ability, 0.9),
    ul2 = quantile(Ability, 0.75)
  )
ids <- t(sapply(abilities$game, splitRound)) %>%
  as.data.frame() %>%
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
  scale_x_continuous(breaks = 1:17) +
  scale_fill_manual(values = sq_cols, guide = "none") +
  scale_alpha(guide = "none") +
  geom_line(aes(colour = squadName), lwd = 2) +
  scale_colour_manual(values = sq_cols, guide = "none") +
  geom_hline(aes(yintercept = 0), colour = "darkgrey") +
  facet_wrap(~ squadName, nrow = 2) +
  ylab("Ability")

################################################################################
## Save appropriate outputs and summaries.
## Create a 2x2 grid of the figures.
res <- sapply(1:4, predDiffHist, model = output, game_lookup = round_data)
pl_grid <- plot_grid(
  res[[1, 1]] + theme_steve(base_size = 12),
  res[[1, 2]] + theme_steve(base_size = 12),
  res[[1, 3]] + theme_steve(base_size = 12),
  res[[1, 4]] + theme_steve(base_size = 12)
)
save_plot(
  here(dirname, "plot-grid-no-hga.png"),
  pl_grid,
  base_height = 35 / (1 + sqrt(5)),
  base_width = 17.5
)
## Save prediction table
res_table <- bind_rows(res[2, ]) %>%
  select(
    Home = homeTeam,
    Away = awayTeam,
    `Chance of home team winning` = prob
  )
saveRDS(
  res_table,
  here(dirname, "predictions-no-hga.rds"))
ggsave(
  here(dirname, "abilities-no-hga.png"),
  pl_abilities,
  width = 17.5, height = 35 / (1 + sqrt(5))
)

## Save model output to add actual results to predicted score diffs
saveRDS(
  output,
  here(dirname, "model-no-hga.rds")
)
