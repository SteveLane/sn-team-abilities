################################################################################
################################################################################
## Title: Data Preparation
## Author: Steve Lane
## Date: Saturday, 27 May 2017
## Synopsis: Pull down data and transform into table.
## Time-stamp: <2017-05-27 09:07:43 (steve)>
################################################################################
################################################################################
library(dplyr)
library(googlesheets)
snGS <- "https://docs.google.com/spreadsheets/d/18-JY8Bbg1GOY7XecDkKpEDGuM_KF62GWz4YAq3i3oFM/pubhtml"
scores <- snGS %>% gs_url()
