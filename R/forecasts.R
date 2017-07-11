################################################################################
################################################################################
## Title: Fit model
## Author: Steve Lane
## Date: Wednesday, 07 June 2017
## Synopsis: Fit the super-netball abilities models
## Time-stamp: <2017-07-11 10:41:45 (slane)>
################################################################################
################################################################################
library(dplyr)
library(tidyr)
library(ggplot2)
coefs <- readRDS("../data/coefs-round-14.rds")
scores <- readRDS("../data/sn-scores.rds")
tmNames <- readRDS("../data/team-lookups.rds")
source("../R/functions.R")
source("../R/ggsteve.R")
theme_set(theme_steve(base_size = 20))
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Forecast for first week of finals.
################################################################################
################################################################################
## Vixens vs lightning, giants vs magpies
homeTms <- c(4, 2)
awayTms <- c(7, 3)
gmNames <- sapply(1:2, function(i){
    paste0(tmNames$`Home team`[homeTms[i]], " v.s. ",
           tmNames$`Home team`[awayTms[i]])
})
actDiffs <- data_frame(gmName = gmNames, predDiff = c(-1, 1))
fcDiffs <- forecasts(coefs, 14, homeTms, awayTms)
colnames(fcDiffs) <- gmNames
fcDiffs <- fcDiffs %>% as_data_frame() %>% gather(gmName, predDiff) %>%
    mutate(gmName = factor(gmName, levels = gmNames))
vixPink <- "#DF005A"
sclOrange <- "#FDB71F"
giantsOrange <- "#F17A30"
magBlack <- "#000000"
plDiffs <- ggplot(fcDiffs, aes(x = predDiff)) +
    geom_histogram(aes(fill = gmName, alpha = 0.5)) +
    scale_fill_manual(guide = "none", values = c(vixPink, giantsOrange)) +
    scale_alpha(guide = "none") +
    geom_vline(aes(xintercept = predDiff, colour = gmName), data = actDiffs) +
    scale_colour_manual(guide = "none", values = c(magBlack, sclOrange)) +
    facet_wrap(~ gmName, ncol = 2) +
    theme(axis.text.y = element_blank()) +
    xlab("Predicted difference") +
    ggtitle("PREDICTED SCORE DIFFERENCES", "Finals, week one")
ggsave("../graphics/finals-pred-diffs.png", plDiffs, width = 16, height = 9)
################################################################################
################################################################################
