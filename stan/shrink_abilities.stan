////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Title: Shrink Abilities
// Author: Steve Lane
// Date: Sunday, 22 April 2018
// Synopsis: Stan model to take fitted abilities from a season, and shrink them.
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

data {
  int<lower=1> nteams;
  /* Final ability */
  real ability[nteams];
  /* Final ability sd */
  real<lower=0> ability_sd[nteams];
}

parameters {
  /* Mean */
  real mu;
  /* Shrinkage */
  real<lower=0> tau;
  /* Deviation from mean */
  real eta[nteams];
}

transformed parameters {
  /* Adjusted mean */
  real theta[nteams];
  for (i in 1:nteams) {
    theta[i] = mu + tau * eta[i];
  }
}

model {
  target += normal_lpdf(eta | 0, 1);
  target += normal_lpdf(ability | theta, ability_sd);
}
