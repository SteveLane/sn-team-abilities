################################################################################
################################################################################
## Title: Helpers
## Author: Steve Lane
## Date: Saturday, 08 August 2020
## Synopsis: Script to help download all previous seasons data.
## Time-stamp: <>
################################################################################
################################################################################
library(tidyverse)
library(here)
library(superNetballR)
source(here::here("R/updateData.R"))

################################################################################
## Season 2017, Home and Away
for (i in seq_len(14)) {
  updateData(2017, i, "10083")
}
## Season 2017, Finals
for (i in 15:17) {
  updateFinals(2017, i, "10084", i - 14)
}

################################################################################
## Season 2018, Home and Away
for (i in seq_len(14)) {
  updateData(2018, i, "10393")
}
## Season 2018, Finals
for (i in 15:17) {
  updateFinals(2018, i, "10394", i - 14)
}

################################################################################
## Season 2019, Home and Away
for (i in seq_len(14)) {
  updateData(2019, i, "10724")
}
## Season 2019, Finals
for (i in 15:17) {
  updateFinals(2019, i, "10725", i - 14)
}
