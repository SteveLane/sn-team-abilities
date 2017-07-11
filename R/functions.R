################################################################################
################################################################################
## Title: Functions
## Author: Steve Lane
## Date: Monday, 10 July 2017
## Synopsis: Required functions
## Time-stamp: <2017-07-11 10:42:33 (slane)>
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Function to fit model up to N rounds
################################################################################
################################################################################
fitToN <- function(data, model, round, teams){
    allRounds <- data %>% filter(`Round Number` <= round)
    stanData <- with(allRounds,
                     list(nteams = max(homeInt, awayInt),
                          ngames = nrow(allRounds),
                          nrounds = max(`Round Number`),
                          roundNo = `Round Number`,
                          home = homeInt, away = awayInt, scoreDiff = homeDiff))
    modOutput <- sampling(model, data = stanData, iter = 2000)
    ## Save coefs for any forecasting at a later stage
    allCoefs <- extract(modOutput)
    fn <- paste0("../data/coefs-round-", round, ".rds")
    saveRDS(allCoefs, file = fn)
    aCoef <- extract(modOutput, pars = "a")$a
    aSum <- t(apply(aCoef[, round, ], 2, quantile,
                    probs = c(0.25, 0.5, 0.75))) %>%
        as_data_frame() %>% bind_cols(., teams) %>%
        arrange(desc(`50%`)) %>%
        mutate(`Round Number` = round)
    oneRound <- data %>% filter(`Round Number` == round)
    hga <- extract(modOutput, pars = "hga")$hga
    hga <- matrix(rep(hga, 4), ncol = 4)
    diffs <- hga + aCoef[, round, oneRound$homeInt] -
        aCoef[, round, oneRound$awayInt]
    diffsHome <- t(apply(diffs, 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
        as_data_frame() %>%
        bind_cols(., data_frame(homeInt = oneRound$homeInt)) %>%
        arrange(desc(`50%`)) %>%
        left_join(oneRound %>%
                  select(homeInt, `Home team`, actualDiff = homeDiff)) %>%
        rename(`Team Name` = `Home team`) %>% select(-homeInt)
    diffsAway <- t(apply(-diffs, 2, quantile, probs = c(0.25, 0.5, 0.75))) %>%
        as_data_frame() %>%
        bind_cols(., data_frame(awayInt = oneRound$awayInt)) %>%
        arrange(desc(`50%`)) %>%
        left_join(oneRound %>%
                  select(awayInt, `Away team`, actualDiff = homeDiff)) %>%
        mutate(actualDiff = -actualDiff) %>%
        rename(`Team Name` = `Away team`) %>% select(-awayInt)
    diffs <- bind_rows(diffsHome, diffsAway) %>%
        mutate(`Round Number` = round)
    list(predDiffs = diffs, abilities = aSum)
}
################################################################################
################################################################################

################################################################################
################################################################################
## Begin Section: Predictions (using the posterior parameters)
################################################################################
################################################################################
forecasts <- function(coefs, curRound, homePred, awayPred){
    ngames <- length(homePred)
    nsims <- nrow(coefs$hga)
    eta_fc <- matrix(rnorm(nsims * 8, 0, 1), ncol = 8)
    sigA <- coefs$sigma_a
    innov <- sigA * eta_fc
    a <- coefs$a[, curRound, ]
    abilities <- a + innov
    preds <- sapply(1:ngames, function(i){
        meanDiff <- coefs$hga + abilities[, homePred[i]] -
            abilities[, awayPred[i]]
        predDiff <- sapply(1:nsims, function(x) {
            meanDiff[x] + coefs$sigma_y[x] * rt(1, df = coefs$nu[x])
        })
        predDiff
    })
    preds
}
################################################################################
################################################################################
