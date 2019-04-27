# Time-stamp: <2019-04-27 11:52:29 (slane)>
# Generate the shrunken priors from last season.
.PHONY: shrinking
shrinking: data/shrunken_abilities_2019.rds
data/shrunken_abilities_2019.rds: R/post-finals-model.R data-raw/season_2018.rds
	cd $(<D) \
	&& Rscript $(<F) year 2018 round 17 comp_id 10394

# Make models for blogging.
round1: sn-assets-2019-round-1/stan_data.rds
sn-assets-2019-round-1/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 1 comp_id 10395 \
		home "4 3 2 1" away "6 7 5 8"
