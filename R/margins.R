################################################################################
################################################################################
## Title: Margins analysis
## Author: Steve Lane
## Date: Monday, 13 May 2019
## Synopsis: Analysis of margins over seasons
## Time-stamp: <2019-05-13 14:57:48 (slane)>
################################################################################
################################################################################
library(here)
library(dplyr)
library(ggplot2)
library(superNetballR)
library(rstanarm)
source(here("R", "ggsteve.R"))
theme_set(theme_steve(base_size = 24))
options(mc.cores = 4)
data(season_2017)
season_2018 <- readRDS(here("data-raw/season_2018.rds"))
season_2019 <- readRDS(here("data-raw/season_2019.rds"))

## Tidy for analysis
matches_2017 <- matchResults(season_2017) %>%
  mutate(
    score_diff = abs(score_diff),
    season = 2017
  )
matches_2018 <- matchResults(season_2018) %>%
  mutate(
    score_diff = abs(score_diff),
    season = 2018
  )
matches_2019 <- matchResults(season_2019) %>%
  mutate(
    score_diff = abs(score_diff),
    season = 2019
  )
all_matches <- bind_rows(
  matches_2017,
  matches_2018,
  matches_2019
) %>%
  ungroup() %>%
  mutate(Season = as.character(season))

all_matches_scores <- all_matches %>%
  group_by(Season, round) %>%
  summarise(Goals = mean(goals))

all_matches_diff <- all_matches %>%
  distinct(Season, round, game, .keep_all = TRUE)

## mean score diffs, season
all_matches_round <- all_matches_diff %>%
  group_by(Season, round) %>%
  summarise(
    score_diff = mean(score_diff)
  )

## mean score diffs, season
all_matches_mean <- all_matches_diff %>%
  group_by(season) %>%
  summarise(score_diff = mean(score_diff))

## simple regression
lm1 <- lm(score_diff ~ factor(Season), data = all_matches_diff)
summary(lm1)
## stan for probs
lm_stan <- stan_glm(
  score_diff ~ factor(Season), data = all_matches_diff
)

## plot score differences by round
pl_diffs <- ggplot(all_matches_round,
  aes(x = round, y = score_diff, colour = Season)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  ylab("") +
  xlab("Round") +
  ggtitle("Average margin per round")
ggsave(
  here("margins.png"),
  pl_diffs,
  width = 17.5, height = 35 / (1 + sqrt(5))
)

## Plot average team scores by round
pl_scores <- ggplot(all_matches_scores,
  aes(x = round, y = Goals, colour = Season)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  ylab("") +
  xlab("Round") +
  ggtitle("Average team score per round")
ggsave(
  here("scores.png"),
  pl_scores,
  width = 17.5, height = 35 / (1 + sqrt(5))
)
