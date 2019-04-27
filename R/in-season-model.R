#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season model.
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Fits the model to in-season matches.
## Time-stamp: <2019-04-27 12:36:48 (slane)>
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
dirname <- paste0("data/sn-assets-", year, "-round-", round)
stan_data <- readRDS(here(dirname, "stan_data.rds"))
round_data <- readRDS(here(dirname, "game.rds"))

################################################################################
## Run the model.
model <- stan_model(here("stan", opt$mname))
output <- sampling(
  model,
  data = stan_data,
  iter = 4000,
  chains = cores,
  thin = 5,
  open_progress = FALSE,
  control = list(adapt_delta = 0.95,
    max_treedepth = 10)
)

################################################################################
## Save appropriate outputs and summaries.
## Create a 2x2 grid of the figures.
res <- sapply(1:4, predDiffHist, model = output, game_lookup = round_data)
pl_grid <- plot_grid(res[[1, 1]], res[[1, 2]], res[[1, 3]], res[[1, 4]])
save_plot(
  here(dirname, "round1-2018-plot-grid.png"),
  pl_grid,
  base_height = 70 / (1 + sqrt(5)),
  base_width = 35
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
  here(dirname, "predictions.rds"))
for (i in 1:4) {
  ggsave(
    here(dirname, paste0("game-", i, ".png")),
    res[[1, i]],
    width = 17.5, height = 35 / (1 + sqrt(5))
  )
}
