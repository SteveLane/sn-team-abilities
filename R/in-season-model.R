#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season model.
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Fits the model to in-season matches.
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
dirname <- paste0("data/sn-assets-", year, "-round-", round)
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
  chains = cores,
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
## Save appropriate outputs and summaries.
## Create a 2x2 grid of the figures.
res <- sapply(1:4, predDiffHist, model = output, game_lookup = round_data)
pl_grid <- plot_grid(res[[1, 1]], res[[1, 2]], res[[1, 3]], res[[1, 4]])
save_plot(
  here(dirname, "plot-grid.png"),
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
ggsave(
  here(dirname, "abilities.png"),
  pl_abilities,
  width = 17.5, height = 35 / (1 + sqrt(5))
)
ggsave(
  here(dirname, "hga.png"),
  pl_hga,
  width = 17.5, height = 35 / (1 + sqrt(5))
)
