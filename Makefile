# Time-stamp: <2019-04-27 13:37:31 (slane)>
# Set the directory of the Makefile.
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Generate the shrunken priors from last season.
.PHONY: shrinking
shrinking: data/shrunken_abilities_2019.rds
data/shrunken_abilities_2019.rds: R/post-finals-model.R data-raw/season_2018.rds
	cd $(<D) \
	&& Rscript $(<F) year 2018 round 17 comp_id 10394

# Make models for blogging.
round1: data/sn-assets-2019-round-1/stan_data.rds \
	data/sn-assets-2019-round1/round1-2018-plot-grid.png
data/sn-assets-2019-round-1/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 1 comp_id 10395 \
		home "4 3 2 1" away "6 7 5 8"
data/sn-assets-2019-round1/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-1/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 1 mname season_2018.stan
# Make blog for round 1
round1-blog: Rmd/2019/.round1.bk
Rmd/2019/.round1.bk: Rmd/2019/round1.Rmd \
	data/sn-assets-2019-round-1/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round1.md ~/github/website/content/post/2019-04-27-round1.md \
  && mkdir -p ~/github/website/static/sn-assets/2019/round1/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-1/*.png ~/github/website/static/sn-assets/2019/round1/
