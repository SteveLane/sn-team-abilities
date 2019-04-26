#!/usr/bin/env Rscript --vanilla
################################################################################
################################################################################
## Title: In-season model.
## Author: Steve Lane
## Date: Tuesday, 23 April 2019
## Synopsis: Fits the model to in-season matches.
## Time-stamp: <2019-04-23 13:41:44 (slane)>
################################################################################
################################################################################

################################################################################
## Command line options.
library(methods)
library(docopt)
doc <- "
Usage:
  in-season-model.R year <year> round <round> home <home> away <away>
  in-season-model.R -h | --help

Options:
  -h --help        Show this help text.
"
opt <- docopt(doc)

################################################################################
## Libraries and loads for the model.
library(here)
library(dplyr)
message("The home teams are:", opt$home)

## load the appropriate seasons data
fname <- paste0("data-raw/season_", opt$year, ".rds")
data <- readRDS(here(fname))

## check that it contains up to date information
round <- as.integer(opt$round)
prev_round <- round - 1
if (round > 1) {
  ## do the data check here.
  data_round <- max(data$round)
  if (data_round < prev_round) {
    stop(paste0("Up-to-date data is not available for predicting round ", round,
      ".\nPlease update the season's data.\n"))
  }

}

################################################################################
## Run the model.

################################################################################
## Save appropriate outputs and summaries.
