################################################################################
################################################################################
## Title: Fit model
## Author: Steve Lane
## Date: Wednesday, 07 June 2017
## Synopsis: Fit the super-netball abilities models
## Time-stamp: <2017-07-10 20:24:26 (slane)>
################################################################################
################################################################################
library(dplyr)
library(rstan)
library(jsonlite)
scores <- readRDS("../data/sn-scores.rds")
tmNames <- readRDS("../data/team-lookups.rds")
## Read scores in long format, as it has a rolling ladder we can compare to.
scoresLong <- fromJSON("../data/sn-ladder.json")
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
stanData <- with(scores,
                 list(nteams = max(homeInt), ngames = nrow(scores),
                      nrounds = max(`Round Number`), roundNo = `Round Number`,
                      home = homeInt, away = awayInt, scoreDiff = homeDiff))
modOutput <- sampling(model, data = stanData, iter = 500)
a <- extract(modOutput, pars = "a")$a
## Check ability after round 14 (last home and away)
aSum <- t(apply(a[, 14, ], 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
    as_data_frame() %>% bind_cols(., tmNames) %>%
    arrange(desc(`50%`))
## That looks pretty reasonable. How does it compare to the ladder?
scoresLong %>% filter(`Round Number` == max(`Round Number`)) %>%
    select(`Team Name`, `Cumulative Points`, For, Against, Percentage) %>%
    arrange(desc(`Cumulative Points`), desc(Percentage))
## Wow! That's a bit different!
## What about some of the parameters?
print(modOutput, digits = 2, pars = c("hga", "tau_a", "nu", "sigma_y"))
print(modOutput, digits = 2, pars = c("sigma_a"))
## Nice!
################################################################################
################################################################################

## FROM HERE IS WHERE I NEED TO LOOP OVER ROUNDS.

################################################################################
################################################################################
## Begin Section: Loop through the data to refit after each round...
################################################################################
################################################################################
## Just test round 1
round1 <- scores %>% filter(`Round Number` == 1)
stanData1 <- with(round1,
                  list(nteams = max(homeInt, awayInt), ngames = nrow(round1),
                       nrounds = max(`Round Number`), roundNo = `Round Number`,
                       home = homeInt, away = awayInt, scoreDiff = homeDiff))
modOutput1 <- sampling(model, data = stanData1, iter = 1000)
aR1 <- extract(modOutput1, pars = "a")$a
## Check ability after round 23 (before finals)
aSumR1 <- t(apply(aR1[, 1, ], 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
    as_data_frame() %>% bind_cols(., tmNames) %>%
    arrange(desc(`50%`))
## That looks pretty reasonable...
## What about some of the parameters?
print(modOutput1, digits = 2, pars = c("hga", "tau_a", "nu", "sigma_y"))
print(modOutput1, digits = 2, pars = c("sigma_a"))
## Seems fine as well...
## Difference in scores (need hga)
hgaR1 <- extract(modOutput1, pars = "hga")$hga
hgaR1 <- matrix(rep(hgaR1, 4), ncol = 4)
diffR1 <- hgaR1 + aR1[, , round1$homeInt] - aR1[, , round1$awayInt]
diffSumR1 <- t(apply(diffR1, 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
    as_data_frame() %>%
    bind_cols(., data_frame(homeInt = round1$homeInt)) %>%
    bind_cols(., data_frame(awayInt = round1$awayInt)) %>%
    arrange(desc(`50%`)) %>%
    left_join(round1 %>% select(homeInt, actualDiff = homeDiff))
## That looks pretty good as well!
################################################################################
################################################################################
