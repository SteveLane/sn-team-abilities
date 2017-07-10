################################################################################
################################################################################
## Title: Fit model
## Author: Steve Lane
## Date: Wednesday, 07 June 2017
## Synopsis: Fit the super-netball abilities models
## Time-stamp: <2017-07-10 20:37:00 (slane)>
################################################################################
################################################################################
library(dplyr)
library(rstan)
library(jsonlite)
scores <- readRDS("../data/sn-scores.rds")
tmNames <- readRDS("../data/team-lookups.rds")
source("../R/functions.R")
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Compile and fit model to all data
################################################################################
################################################################################
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
model <- stan_model("../stan/basic-model.stan")
allRounds <- lapply(1:14, function(rn){
    fits <- fitToN(scores, model, rn, tmNames)
    fits
})
predDiffs <- lapply(allRounds, function(x) x$PredDiffs) %>%
    bind_rows()
abilities <- lapply(allRounds, function(x) x$abilities) %>%
    bind_rows()
if(!dir.exists("../data/")) dir.create("../data/")
saveRDS(predDiffs, "../data/predDiffs.rds")
saveRDS(abilities, "../data/abilities.rds")
################################################################################
################################################################################
