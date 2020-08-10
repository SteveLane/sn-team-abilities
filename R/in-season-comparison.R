#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season comparison.
## Author: Steve Lane
## Synopsis: Takes the predictions from last round, and overlays the results.
## Time-stamp: <2019-05-07 16:45:26 (slane)>
################################################################################
################################################################################

################################################################################
## Command line options.
library(methods)
library(docopt)
doc <- "
Usage:
  in-season-comparison.R year <year> round <round>
  in-season-comparison.R -h | --help

Options:
  -h --help        Show this help text.
"
opt <- docopt(doc)

################################################################################
## Libraries and loads for the model.
library(here)
library(dplyr)
library(rstan)
library(tidyr)
library(purrr)
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
dirname_previous <- paste0("data/", year, "/sn-assets-round-", round - 1)
dirname_current <- paste0("data/", year, "/sn-assets-round-", round)
results <- readRDS(here(dirname_current, "/results_match.rds")) %>%
  mutate(diff = `Home Goals` - `Away Goals`)
output <- readRDS(here(dirname_previous, "/model.rds"))
round_data <- readRDS(here(dirname_previous, "/game.rds"))

################################################################################
## Save appropriate outputs and summaries.
## Create a 2x2 grid of the figures.
res <- sapply(1:4, predDiffHist, model = output, game_lookup = round_data)
pl_grid <- plot_grid(
  res[[1, 1]] + theme_steve(base_size = 12) +
    geom_vline(xintercept = results[["diff"]][1], size = 2, colour = "blue"),
  res[[1, 2]] + theme_steve(base_size = 12) +
    geom_vline(xintercept = results[["diff"]][2], size = 2, colour = "blue"),
  res[[1, 3]] + theme_steve(base_size = 12) +
    geom_vline(xintercept = results[["diff"]][3], size = 2, colour = "blue"),
  res[[1, 4]] + theme_steve(base_size = 12) +
    geom_vline(xintercept = results[["diff"]][4], size = 2, colour = "blue")
)
save_plot(
  here(dirname_current, "/plot-grid-comparison.png"),
  pl_grid,
  base_height = 35 / (1 + sqrt(5)),
  base_width = 17.5
)
