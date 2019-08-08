# Time-stamp: <2019-06-23 20:28:46 (sprazza)>
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

# round 4 (needs editing, I've just got data at the moment)
round4: data/sn-assets-2019-round-4/stan_data.rds \
	data/sn-assets-2019-round-4/plot-grid.png
data/sn-assets-2019-round-4/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 4 comp_id 10724 \
		home "3 5 8 6" away "1 7 4 2"
data/sn-assets-2019-round-4/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-4/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 4 mname season_2018.stan
# Make blog for round 4
round4-blog: Rmd/2019/.round4.bk
Rmd/2019/.round4.bk: Rmd/2019/round4.Rmd \
	data/sn-assets-2019-round-4/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round4.md ~/github/website/content/post/2019-05-15-round4.md \
	&& touch .round4.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round4/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-4/*.png ~/github/website/static/sn-assets/2019/round4/
# Wrap up round 3
round3-wrapup: Rmd/2019/.round3-wrapup.bk
Rmd/2019/.round3-wrapup.bk: Rmd/2019/round3-wrapup.Rmd \
	data/sn-assets-2019-round-4/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& touch .round3-wrapup.bk \
	&& mv round3-wrapup.md ~/github/website/content/post/2019-05-14-round3-wrapup.md

# round 5
round5: data/sn-assets-2019-round-5/stan_data.rds \
	data/sn-assets-2019-round-5/plot-grid.png
data/sn-assets-2019-round-5/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 5 comp_id 10724 \
		home "3 7 4 1" away "8 2 5 6"
data/sn-assets-2019-round-5/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-5/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 5 mname season_2018.stan

# round 6 (needs editing, I've just got data at the moment)
round6: data/sn-assets-2019-round-6/stan_data.rds \
	data/sn-assets-2019-round-6/plot-grid.png
data/sn-assets-2019-round-6/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 6 comp_id 10724 \
		home "7 6 5 2" away "4 8 3 1"
data/sn-assets-2019-round-6/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-6/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 6 mname season_2018.stan

# round 7 (needs editing, I've just got data at the moment)
round7: data/sn-assets-2019-round-7/stan_data.rds \
	data/sn-assets-2019-round-7/plot-grid.png
data/sn-assets-2019-round-7/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 7 comp_id 10724 \
		home "1 8 6 4" away "7 2 5 3"
data/sn-assets-2019-round-7/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-7/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 7 mname season_2018.stan

# round 8 (needs editing, I've just got data at the moment)
round8: data/sn-assets-2019-round-8/stan_data.rds \
	data/sn-assets-2019-round-8/plot-grid.png
data/sn-assets-2019-round-8/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 8 comp_id 10724 \
		home "7 8 6 5" away "3 1 4 2"
data/sn-assets-2019-round-8/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-8/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 8 mname season_2018.stan

# round 9 (needs editing, I've just got data at the moment)
round9: data/sn-assets-2019-round-9/stan_data.rds \
	data/sn-assets-2019-round-9/plot-grid.png
data/sn-assets-2019-round-9/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 9 comp_id 10724 \
		home "7 2 1 3" away "8 4 5 6"
data/sn-assets-2019-round-9/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-9/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 9 mname season_2018.stan

# round 10
round10: data/sn-assets-2019-round-10/stan_data.rds \
	data/sn-assets-2019-round-10/plot-grid.png
data/sn-assets-2019-round-10/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 10 comp_id 10724 \
		home "6 8 3 4" away "7 5 2 1"
data/sn-assets-2019-round-10/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-10/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 10 mname season_2018.stan
# Make blog for round 10
round10-blog: Rmd/2019/.round10.bk
Rmd/2019/.round10.bk: Rmd/2019/round10.Rmd \
	data/sn-assets-2019-round-10/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round10.md ~/github/website/content/post/2019-07-26-round10.md \
	&& touch .round10.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round10/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-10/*.png ~/github/website/static/sn-assets/2019/round10/
	
# round 11 (needs editing, I've just got data at the moment)
round11: data/sn-assets-2019-round-11/stan_data.rds \
	data/sn-assets-2019-round-11/plot-grid.png
data/sn-assets-2019-round-11/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 11 comp_id 10724 \
		home "4 7 2 1" away "8 5 6 3"
data/sn-assets-2019-round-11/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-11/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 11 mname season_2018.stan

# round 12
round12: data/sn-assets-2019-round-12/stan_data.rds \
	data/sn-assets-2019-round-12/plot-grid.png
data/sn-assets-2019-round-12/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 12 comp_id 10724 \
		home "2 5 6 8" away "7 4 1 3"
data/sn-assets-2019-round-12/plot-grid.png: \
	R/in-season-model.R data/sn-assets-2019-round-12/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year 2019 round 12 mname season_2018.stan
# Make blog for round 12
round12-blog: Rmd/2019/.round12.bk
Rmd/2019/.round12.bk: Rmd/2019/round12.Rmd \
	data/sn-assets-2019-round-12/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round12.md ~/github/website/content/post/2019-08-08-round12.md \
	&& touch .round12.bk \
  && mkdir -p ~/github/website/static/sn-assets/2019/round12/ \
	&& cd $(ROOT_DIR) \
	&& cp data/sn-assets-2019-round-12/*.png ~/github/website/static/sn-assets/2019/round12/
