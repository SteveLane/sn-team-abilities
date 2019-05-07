# Time-stamp: <2019-05-07 16:28:27 (slane)>
# Set the directory of the Makefile.
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Generate the shrunken priors from last season.
.PHONY: shrinking
shrinking: data/shrunken_abilities_2019.rds
data/shrunken_abilities_2019.rds: R/post-finals-model.R data-raw/season_2018.rds
	cd $(<D) \
	&& Rscript $(<F) year 2018 round 17 comp_id 10394

# Make models for blogging.
# Round 1
round1: data/sn-assets-2019-round-1/stan_data.rds \
	data/sn-assets-2019-round-1/plot-grid.png
data/sn-assets-2019-round-1/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 1 comp_id 10724 \
		home "4 3 2 1" away "6 7 5 8"
data/sn-assets-2019-round-1/plot-grid.png: \
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
	&& touch .round1.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round1/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-1/*.png ~/github/website/static/sn-assets/2019/round1/

# Round 2
round2: data/sn-assets-2019-round-2/stan_data.rds \
	data/sn-assets-2019-round-2/plot-grid.png
data/sn-assets-2019-round-2/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 2 comp_id 10724 \
		home "6 8 5 4" away "3 7 1 2"
data/sn-assets-2019-round-2/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-2/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 2 mname season_2018.stan
# Make blog for round 2
round2-blog: Rmd/2019/.round2.bk
Rmd/2019/.round2.bk: Rmd/2019/round2.Rmd \
	data/sn-assets-2019-round-2/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round2.md ~/github/website/content/post/2019-05-04-round2.md \
	&& touch .round2.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round2/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-2/*.png ~/github/website/static/sn-assets/2019/round2/
# Wrap up Round 1
round1-wrapup: Rmd/2019/.round1-wrapup.bk
Rmd/2019/.round1-wrapup.bk: Rmd/2019/round1-wrapup.Rmd \
	data/sn-assets-2019-round-2/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& touch .round1-wrapup.bk \
	&& mv round1-wrapup.md ~/github/website/content/post/2019-05-03-round1-wrapup.md

# round 3
round3: data/sn-assets-2019-round-3/stan_data.rds \
	data/sn-assets-2019-round-3/plot-grid.png
data/sn-assets-2019-round-3/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 3 comp_id 10724 \
		home "1 5 7 2" away "4 8 6 3"
data/sn-assets-2019-round-3/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-3/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 3 mname season_2018.stan
# Make blog for round 3
round3-blog: Rmd/2019/.round3.bk
Rmd/2019/.round3.bk: Rmd/2019/round3.Rmd \
	data/sn-assets-2019-round-3/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round3.md ~/github/website/content/post/2019-05-07-round3.md \
	&& touch .round3.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round3/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-3/*.png ~/github/website/static/sn-assets/2019/round3/
# Wrap up round 2
round2-wrapup: Rmd/2019/.round2-wrapup.bk
Rmd/2019/.round2-wrapup.bk: Rmd/2019/round2-wrapup.Rmd \
	data/sn-assets-2019-round-3/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& touch .round2-wrapup.bk \
	&& mv round2-wrapup.md ~/github/website/content/post/2019-05-06-round2-wrapup.md
