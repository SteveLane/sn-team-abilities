////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Title: Season 2018
// Author: Steve Lane
// Date: Sunday, 22 April 2018
// Synopsis: Fits a basic difference of abilities model to super netball scores.
// Uses the basic model as a base, and priors derived from season 2017.
// Time-stamp: <2018-04-25 19:19:02 (slane)>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

data {
  /* Number of teams */
  int<lower=1> nteams;
  /* Number of games (over the season to date) */
  int<lower=1> ngames;
  /* Number of rounds (to date) */
  int<lower=1> nrounds;
  /* Round number of game */
  int<lower=1> round_no[ngames];
  /* Home team ID */
  int<lower=1,upper=nteams> home[ngames];
  /* Away team ID */
  int<lower=1,upper=nteams> away[ngames];
  /* Score difference */
  real score_diff[ngames];
  /* Flag for first round */
  int<lower=0,upper=1> first_round;
  /* Ability at start of the season */
  row_vector[nteams] init_ability;
  /* Standard deviation of start of season ability */
  matrix<lower=0>[nteams, 2] init_sd;
  /* Initial HGA */
  vector[nteams] mu_hga;
  /* Standard deviation of HGA (Gamma prior) */
  real<lower=0> init_sigma_hga[2];
  /* Standard deviation of score differences (Gamma prior) */
  real<lower=0> init_sigma_y[2];
  /* Predictions for next round */
  /* Number of games to predict */
  int<lower=0> ngames_pred;
  /* Home teams for prediction */
  int<lower=1,upper=nteams> pred_home[ngames_pred];
  /* Away teams for prediction */
  int<lower=1,upper=nteams> pred_away[ngames_pred];
}

parameters {
  /* Home ground advantage (mean) */
  vector[nteams] hga_raw;
  /* HGA sd */
  real<lower=0> sigma_hga;
  /* Team specific initial abilities */
  row_vector[nteams] a_init;
  /* Team specific dynamic model */
  matrix[nrounds - 1, nteams] eta_raw;
  /* Standard deviation of team effect */
  row_vector<lower=0>[nteams] sigma_eta;
  /* Std. dev. for score difference */
  real<lower=0> sigma_y;
}

transformed parameters {
  /* Smoothed team abilities */
  matrix[nrounds, nteams] a;
  /* Mean score differential */
  real mean_score_diff[ngames];
  /* Home ground advantage */
  vector[nteams] hga;
  /* Abilities at start of season */
  a[1] = init_ability + sigma_eta .* a_init;
  /* Home ground advantage */
  hga = mu_hga + sigma_hga * hga_raw;
  /* Round by round team ability evolution */
  if (nrounds >= 2) {
    for (r in 2:nrounds) {
      a[r] = a[r - 1] + sigma_eta .* eta_raw[r - 1];
    }
  }
  /* Game by game mean score diff */
  for (g in 1:ngames) {
    mean_score_diff[g] = a[round_no[g], home[g]] - a[round_no[g], away[g]] + hga[home[g]];
  }
}

model{
  /* Prior for initial ability */
  a_init ~ normal(0, 1);
  /* Priors for team trends */
  to_vector(eta_raw) ~ normal(0, 1);
  for (i in 1:nteams) {
    sigma_eta[i] ~ gamma(init_sd[1], init_sd[2]);
  }
  /* Prior for home ground advantage */
  hga_raw ~ normal(0, 1);
  sigma_hga ~ gamma(init_sigma_hga[1], init_sigma_hga[2]);
  // Likelihood
  /* Prior for standard deviation */
  sigma_y ~ gamma(init_sigma_y[1], init_sigma_y[2]);
  /* Only run if not first round */
  if (first_round == 0) {
    score_diff ~ normal(mean_score_diff, sigma_y);
  }
}

generated quantities{
  /* Replicates for checking */
  vector[ngames] score_diffRep;
  vector[ngames] errorRep;
  /* Predictions */
  vector[nteams] pred_ability;
  vector[ngames_pred] pred_diff;
  vector[ngames_pred] prob_home;
  /* PPCs */
  for (g in 1:ngames){
    score_diffRep[g] = normal_rng(mean_score_diff[g], sigma_y);
    errorRep[g] = (score_diff[g] - score_diffRep[g])^2;
  }

  /* Predicted ability for next round (all teams) */
  for (i in 1:nteams) {
    real eta_pred;
    eta_pred = normal_rng(0, 1);
    pred_ability[i] = a[nrounds, i] + sigma_eta[i] * eta_pred;
  }

  /* Predicted difference in scores (and prob of home team winning) */
  for (g in 1:ngames_pred) {
    real mean_diff = pred_ability[pred_home[g]] - pred_ability[pred_away[g]] + hga[pred_home[g]];
    pred_diff[g] = normal_rng(mean_diff, sigma_y);
    prob_home[g] = (pred_diff[g] > 0) ? 1 : 0;
  }
}
