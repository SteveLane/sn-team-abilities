################################################################################
################################################################################
## Title: Fit model
## Author: Steve Lane
## Date: Wednesday, 07 June 2017
## Synopsis: Fit the super-netball abilities models
## Time-stamp: <2017-06-07 17:05:36 (slane)>
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
model <- stan_model("../stan/basic-model-m0.stan")
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

## THAT'S SUFFICIENT, BUT WE CAN NAIL DOWN A BIT. WHAT HAPPENS IF I TIGHTEN DOWN
## THE PRIOR A LOT?
model2 <- stan_model("../stan/basic-model-m1.stan")
modOutput2 <- sampling(model2, data = stanData, iter = 500)
a2 <- extract(modOutput2, pars = "a")$a
## Check ability after round 14 (last home and away)
aSum2 <- t(apply(a2[, 14, ], 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
    as_data_frame() %>% bind_cols(., tmNames) %>%
    arrange(desc(`50%`))
## That looks pretty reasonable. How does it compare to the ladder?
scoresLong %>% filter(`Round Number` == max(`Round Number`)) %>%
    select(`Team Name`, `Cumulative Points`, For, Against, Percentage) %>%
    arrange(desc(`Cumulative Points`), desc(Percentage))
## Wow! That's a bit different!
## What about some of the parameters?
print(modOutput2, digits = 2, pars = c("hga", "tau_a", "nu", "sigma_y"))
print(modOutput2, digits = 2, pars = c("sigma_a"))
## So, there's priors that a too skinny there!
################################################################################
################################################################################

## Ok, so take the middle ground with the priors
model3 <- stan_model("../stan/basic-model.stan")
modOutput3 <- sampling(model3, data = stanData, iter = 500)
a3 <- extract(modOutput3, pars = "a")$a
## Check ability after round 14 (last home and away)
aSum3 <- t(apply(a3[, 14, ], 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
    as_data_frame() %>% bind_cols(., tmNames) %>%
    arrange(desc(`50%`))
## That looks pretty reasonable. How does it compare to the ladder?
scoresLong %>% filter(`Round Number` == max(`Round Number`)) %>%
    select(`Team Name`, `Cumulative Points`, For, Against, Percentage) %>%
    arrange(desc(`Cumulative Points`), desc(Percentage))
## Wow! That's a bit different!
## What about some of the parameters?
print(modOutput3, digits = 2, pars = c("hga", "tau_a", "nu", "sigma_y"))
print(modOutput3, digits = 2, pars = c("sigma_a"))
## So, there's priors that a too skinny there!
################################################################################
################################################################################
