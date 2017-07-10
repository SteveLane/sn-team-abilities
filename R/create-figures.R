################################################################################
################################################################################
## Title: Create Figures
## Author: Steve Lane
## Date: Monday, 10 July 2017
## Synopsis: Create figures from predicted models
## Time-stamp: <2017-07-10 21:20:05 (slane)>
################################################################################
################################################################################
library(dplyr)
library(ggplot2)
predDiffs <- readRDS("../data/predDiffs.rds")
abilities <- readRDS("../data/abilities.rds")
source("../R/ggsteve.R")
theme_set(theme_steve())
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Plot abilities
################################################################################
################################################################################
vixGrn <- "#00A885"
vixPink <- "#DF005A"
sclOrange <- "#FDB71F"
plAbilities <- ggplot(abilities, aes(x = `Round Number`, y = `50%`,
                                     group = `Home team`)) +
    geom_line(colour = "grey") +
    geom_line(data = filter(abilities, `Home team` == "Melbourne Vixens"),
              colour = vixPink, lwd = 1) +
    geom_line(data = filter(abilities,
                            `Home team` == "Sunshine Coast Lightning"),
              colour = sclOrange, lwd = 1) +
    xlab("Round number") +
    ylab("Team ability") +
    ggtitle("SUPER NETBALL TEAM ABILITIES, 2017",
            "Melbourne Vixens vs. Sunshine Coast Lightning")
ggsave("../graphics/abilities-vixens-lightning.png", plAbilities,
       width = 16, height = 9)
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Plot posterior predicted score diffs
################################################################################
################################################################################
plDiffs <- ggplot(filter(predDiffs, `Team Name` == "Melbourne Vixens"),
                  aes(x = `Round Number`, y = actualDiff)) +
    geom_ribbon(aes(ymin = `25%`, ymax = `75%`, fill = vixPink,
                    alpha = 0.15)) +
    geom_point() +
    geom_line(aes(y = `50%`), colour = vixPink) +
    scale_fill_hue(guide = "none") +
    scale_alpha(guide = "none") +
    xlab("Round number") +
    ylab("Score difference") +
    ggtitle("SUPER NETBALL SCORE DIFFERENCES, 2017",
            "Melbourne Vixens")
ggsave("../graphics/score-diff-vixens.png", plDiffs, width = 16, height = 9)
################################################################################
################################################################################
