////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Title: Basic Model
// Author: Steve Lane
// Date: Monday, 16 April 2017
// Synopsis: Fits a basic difference of abilities model to super netball scores.
// Time-stamp: <2018-04-16 22:06:46 (slane)>
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
  /* Ability at start of the season */
  row_vector[nteams] init_ability;
  /* Standard deviation of start of season ability */
  row_vector<lower=0>[nteams] init_sd;
}

parameters {
  /* Home ground advantage (mean) */
  real hga[nteams];
  /* Team specific initial abilities */
  row_vector[nteams] a_init;
  /* Team specific dynamic model */
  matrix[nrounds - 1, nteams] eta_raw;
  /* Standard deviation of team effect */
  row_vector<lower=0>[nteams] sigma_eta;
  /* Degrees of freedom */
  real<lower=1> nu;
  /* Std. dev. for score difference */
  real<lower=0> sigma_y;
}

transformed parameters {
  /* Smoothed team abilities */
  matrix[nrounds, nteams] a;
  /* Mean score differential */
  real mean_score_diff[ngames];
  /* Abilities at start of season */
  a[1] = init_ability + init_sd .* a_init;
  /* Round by round team ability evolution */
  for (r in 2:nrounds) {
    a[r] = a[r - 1] + sigma_eta .* eta_raw[r - 1];
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
  sigma_eta ~ cauchy(0, 2.5);
  /* Prior for home ground advantage */
  hga ~ normal(0, 5);
  // Likelihood
  /* Prior for degrees of freedom */
  nu ~ gamma(2, 0.1);
  /* Prior for standard deviation */
  sigma_y ~ cauchy(0, 2.5);
  score_diff ~ student_t(nu, mean_score_diff, sigma_y);
}

generated quantities{
  // Statements for predictive outputs, e.g. new data
  vector[ngames] score_diffRep;
  vector[ngames] errorRep;
  for (g in 1:ngames){
    score_diffRep[g] = student_t_rng(nu, mean_score_diff[g], sigma_y);
    errorRep[g] = (score_diff[g] - score_diffRep[g])^2;
  }
}
