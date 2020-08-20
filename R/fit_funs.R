################################################################################
################################################################################
## Title: Functions to fit models and produce output
## Author: Steve Lane
## Date: Sunday, 22 April 2018
## Synopsis: Description
## Time-stamp: <2019-04-27 12:33:56 (slane)>
################################################################################
################################################################################
## Function have home team, away team, and score difference on a single row for
## stan modelling.
spreadGame <- function(df) {
    home <- df %>%
        filter(isHome == 1) %>%
        rename(homeTeam = squadName) %>%
        select(-isHome)
    away <- df %>%
        filter(isHome == 0) %>%
        rename(awayTeam = squadName) %>%
        select(awayTeam)
    df <- bind_cols(home, away)
    df
}

## Function takes stan output and produces a histogram and results table
predDiffHist <- function(game, model, game_lookup) {
    home <- toupper(game_lookup$homeTeam[game])
    away <- toupper(game_lookup$awayTeam[game])
    pred_diff <- rstan::extract(model, paste0("pred_diff[", game, "]"))[[1]]
    dens <- density(pred_diff)
    ## Add 50% interval
    ll <- quantile(pred_diff, 0.25)
    ul <- quantile(pred_diff, 0.75)
    pred_df <- tibble(score_diff = dens$x, y = dens$y) %>%
        mutate(prob_win = ifelse(score_diff > 0, home, away))
    col_list = c(game_lookup$homeColour[game],
                 game_lookup$awayColour[game])
    names(col_list) <- c(home, away)
    prob <- rstan::extract(model, paste0("prob_home[", game, "]"))[[1]]
    prob <- round(mean(prob) * 100)
    title_text <- paste0(home, " v.s. ", away)
    subtitle_text <- paste0("Chance of ", home, " winning: ", prob, "%")
    pl_diff <- ggplot(pred_df, aes(x = score_diff, y = y, fill = prob_win)) +
        geom_line() +
        geom_ribbon(aes(ymin = 0, ymax = y, fill = prob_win)) +
        scale_fill_manual(values = col_list, name = NULL) +
        geom_vline(xintercept = ll, lty = 2, colour = "darkgreen",
                   size = 2) +
        geom_vline(xintercept = ul, lty = 2, colour = "darkgreen",
                   size = 2) +
        xlab("Score differential") +
        ylab("") +
        ggtitle(title_text, subtitle_text)
    df <- game_lookup %>%
        slice(game) %>%
        mutate(prob = paste0(prob, "%"))
    list(plot = pl_diff, results = df, density = dens)
}

## Function to calculate mean absolute prediction error
mape <- function(density, actual_diff) {
  trapz <- function(x, y) {
    idx <- 2:length(x)
    return (as.double( (x[idx] - x[idx-1]) %*% (y[idx] + y[idx-1])) / 2)
  }
  errs <- abs(density$x - actual_diff)
  fx <- errs * density$y
  mape <- trapz(density$x, fx)
  mape
}

## Function to split up round/game names
splitRound <- function(rnd) {
    rnd <- unlist(strsplit(rnd, "\\."))
    tibble(Round = as.numeric(rnd[1]),
               squadInt = as.numeric(rnd[2]))
}

## Fit gamma function
fitGamma <- function(df, dname) {
    x <- df[[dname]]
    gam <- MASS::fitdistr(x, "gamma")
    tibble(shape = gam$estimate[1], rate = gam$estimate[2])
}

## Functions to calculate approximate team posteriors to act as priors in new
## seasons
fitPosteriorTeams <- function(model, parameter, team_lookup) {
    ests <- rstan::extract(model, parameter)[[1]] %>%
        as.data.frame()
    names(ests) <- teamLookup$squadName
    ests <- ests %>%
        gather(squadName, value) %>%
        group_by(squadName) %>%
        nest() %>%
        group_by(squadName) %>%
        mutate(ests = map(data, fitGamma, dname = "value")) %>%
        select(-data) %>%
        unnest()
    ests
}

fitPosteriorSingle <- function(model, parameter) {
    ests <- rstan::extract(model, parameter) %>%
        as.data.frame()
    names(ests) <- "value"
    ests <- fitGamma(ests, dname = "value")
    ests
}
