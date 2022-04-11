# Time-stamp: <2022-04-11 19:10:52 (sprazza)>
# Set the directory of the Makefile.
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
YEAR:=2022
PAST_YEAR:=$(shell expr $(YEAR) \- 1)

# Make models for blogging.
# Round 1
round1: data/$(YEAR)/sn-assets-round-1/stan_data.rds \
	data/$(YEAR)/sn-assets-round-1/plot-grid.png
data/$(YEAR)/sn-assets-round-1/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 1 comp_id 11665 \
		home "1 5 6 8" away "3 2 4 7"
data/$(YEAR)/sn-assets-round-1/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-1/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 1 mname abilities_model.stan
# Make blog for round 1
round1-blog: Rmd/$(YEAR)/.round1.bk
Rmd/$(YEAR)/.round1.bk: Rmd/$(YEAR)/round1.Rmd \
	data/$(YEAR)/sn-assets-round-1/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round1.md ~/github/website/content/post/$(YEAR)-03-24-round1.md \
	&& touch .round1.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round1/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-1/*.png ~/github/website/static/sn-assets/$(YEAR)/round1/

# Round 2
round2: data/$(YEAR)/sn-assets-round-2/stan_data.rds \
	data/$(YEAR)/sn-assets-round-2/plot-grid.png
data/$(YEAR)/sn-assets-round-2/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 2 comp_id 11665 \
		home "5 7 3 1" away "4 6 8 2"
data/$(YEAR)/sn-assets-round-2/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-2/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 2 mname abilities_model.stan
# Make blog for round 2
round2-blog: data/$(YEAR)/sn-assets-round-2/plot-grid-current.png \
	Rmd/$(YEAR)/.round2.bk
data/$(YEAR)/sn-assets-round-2/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-2/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 2
Rmd/$(YEAR)/.round2.bk: Rmd/$(YEAR)/round2.Rmd \
	data/$(YEAR)/sn-assets-round-2/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round2.md ~/github/website/content/post/$(YEAR)-03-31-round2.md \
	&& touch .round2.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round2/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-2/*.png ~/github/website/static/sn-assets/$(YEAR)/round2/

# round 3
round3: data/$(YEAR)/sn-assets-round-3/stan_data.rds \
	data/$(YEAR)/sn-assets-round-3/plot-grid.png
	# data/$(YEAR)/sn-assets-round-3/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-3/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 3 comp_id 11665 \
		home "4 5 6 1" away "2 3 8 7"
data/$(YEAR)/sn-assets-round-3/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-3/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 3 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-3/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-3/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 3 mname abilities_model_no_hga.stan
# Make blog for round 3
round3-blog: data/$(YEAR)/sn-assets-round-3/plot-grid-current.png \
	Rmd/$(YEAR)/.round3.bk
data/$(YEAR)/sn-assets-round-3/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-3/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 3
Rmd/$(YEAR)/.round3.bk: Rmd/$(YEAR)/round3.Rmd \
	data/$(YEAR)/sn-assets-round-3/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round3.md ~/github/website/content/post/$(YEAR)-04-06-round3.md \
	&& touch .round3.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round3/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-3/*.png ~/github/website/static/sn-assets/$(YEAR)/round3/

# round 4
round4: data/$(YEAR)/sn-assets-round-4/stan_data.rds \
	data/$(YEAR)/sn-assets-round-4/plot-grid.png
	# data/$(YEAR)/sn-assets-round-4/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-4/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 4 comp_id 11665 \
		home "4 2 3 1" away "8 6 7 5"
data/$(YEAR)/sn-assets-round-4/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-4/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 4 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-4/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-4/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 4 mname abilities_model_no_hga.stan
# Make blog for round 4
round4-blog: data/$(YEAR)/sn-assets-round-4/plot-grid-current.png \
	Rmd/$(YEAR)/.round4.bk
data/$(YEAR)/sn-assets-round-4/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-4/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 4
Rmd/$(YEAR)/.round4.bk: Rmd/$(YEAR)/round4.Rmd \
	data/$(YEAR)/sn-assets-round-4/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round4.md ~/github/website/content/post/$(YEAR)-04-11-round4.md \
	&& touch .round4.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round4/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-4/*.png ~/github/website/static/sn-assets/$(YEAR)/round4/

# round 5
round5: data/$(YEAR)/sn-assets-round-5/stan_data.rds \
	data/$(YEAR)/sn-assets-round-5/plot-grid.png
	# data/$(YEAR)/sn-assets-round-5/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-5/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 5 comp_id 11665 \
		home "7 2 8 6" away "4 3 5 1"
data/$(YEAR)/sn-assets-round-5/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-5/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 5 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-5/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-5/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 5 mname abilities_model_no_hga.stan
# Make blog for round 5
round5-blog: data/$(YEAR)/sn-assets-round-5/plot-grid-current.png \
	Rmd/$(YEAR)/.round5.bk
data/$(YEAR)/sn-assets-round-5/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-5/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 5
Rmd/$(YEAR)/.round5.bk: Rmd/$(YEAR)/round5.Rmd \
	data/$(YEAR)/sn-assets-round-5/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round5.md ~/github/website/content/post/$(YEAR)-04-14-round5.md \
	&& touch .round5.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round5/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-5/*.png ~/github/website/static/sn-assets/$(YEAR)/round5/

# round 6
round6: data/$(YEAR)/sn-assets-round-6/stan_data.rds \
	data/$(YEAR)/sn-assets-round-6/plot-grid.png
	# data/$(YEAR)/sn-assets-round-6/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-6/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 6 comp_id 11665 \
		home "3 2 7 4" away "8 5 6 1"
data/$(YEAR)/sn-assets-round-6/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-6/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 6 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-6/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-6/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 6 mname abilities_model_no_hga.stan
# Make blog for round 6
round6-blog: data/$(YEAR)/sn-assets-round-6/plot-grid-current.png \
	Rmd/$(YEAR)/.round6.bk
data/$(YEAR)/sn-assets-round-6/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-6/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 6
Rmd/$(YEAR)/.round6.bk: Rmd/$(YEAR)/round6.Rmd \
	data/$(YEAR)/sn-assets-round-6/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round6.md ~/github/website/content/post/$(YEAR)-06-04-round6.md \
	&& touch .round6.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round6/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-6/*.png ~/github/website/static/sn-assets/$(YEAR)/round6/

round7: data/$(YEAR)/sn-assets-round-7/stan_data.rds \
	data/$(YEAR)/sn-assets-round-7/plot-grid.png
	# data/$(YEAR)/sn-assets-round-7/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-7/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 7 comp_id 11665 \
		home "2 3 1 6" away "7 4 5 8"
data/$(YEAR)/sn-assets-round-7/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-7/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 7 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-7/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-7/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 7 mname abilities_model_no_hga.stan
# Make blog for round 7
round7-blog: data/$(YEAR)/sn-assets-round-7/plot-grid-current.png \
	Rmd/$(YEAR)/.round7.bk
data/$(YEAR)/sn-assets-round-7/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-7/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 7
Rmd/$(YEAR)/.round7.bk: Rmd/$(YEAR)/round7.Rmd \
	data/$(YEAR)/sn-assets-round-7/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round7.md ~/github/website/content/post/$(YEAR)-06-09-round7.md \
	&& touch .round7.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round7/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-7/*.png ~/github/website/static/sn-assets/$(YEAR)/round7/

round8: data/$(YEAR)/sn-assets-round-8/stan_data.rds \
	data/$(YEAR)/sn-assets-round-8/plot-grid.png
	# data/$(YEAR)/sn-assets-round-8/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-8/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 8 comp_id 11665 \
		home "5 2 7 8" away "6 1 3 4"
data/$(YEAR)/sn-assets-round-8/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-8/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 8 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-8/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-8/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 8 mname abilities_model_no_hga.stan
# Make blog for round 8
round8-blog: data/$(YEAR)/sn-assets-round-8/plot-grid-current.png \
	Rmd/$(YEAR)/.round8.bk
data/$(YEAR)/sn-assets-round-8/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-8/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 8
Rmd/$(YEAR)/.round8.bk: Rmd/$(YEAR)/round8.Rmd \
	data/$(YEAR)/sn-assets-round-8/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round8.md ~/github/website/content/post/$(YEAR)-06-19-round8.md \
	&& touch .round8.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round8/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-8/*.png ~/github/website/static/sn-assets/$(YEAR)/round8/

# Round 9 in 2021 is run manually due to the vixens/fever game being postponed.
# The commented block is what would normally be run.
# round9: data/$(YEAR)/sn-assets-round-9/stan_data.rds \
# 	data/$(YEAR)/sn-assets-round-9/plot-grid.png \
# 	data/$(YEAR)/sn-assets-round-9/plot-grid-no-hga.png
round9: data/$(YEAR)/sn-assets-round-9/plot-grid.png
data/$(YEAR)/sn-assets-round-9/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 9 comp_id 11665 \
		home "7 5 1 6" away "4 8 3 2"
data/$(YEAR)/sn-assets-round-9/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-9/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 9 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-9/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-9/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 9 mname abilities_model_no_hga.stan
# Make blog for round 9
round9-blog: data/$(YEAR)/sn-assets-round-9/plot-grid-current.png \
	Rmd/$(YEAR)/.round9.bk
data/$(YEAR)/sn-assets-round-9/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-9/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 9
Rmd/$(YEAR)/.round9.bk: Rmd/$(YEAR)/round9.Rmd \
	data/$(YEAR)/sn-assets-round-9/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round9.md ~/github/website/content/post/$(YEAR)-07-06-round9.md \
	&& touch .round9.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round9/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-9/*.png ~/github/website/static/sn-assets/$(YEAR)/round9/

round10: data/$(YEAR)/sn-assets-round-10/stan_data.rds \
	data/$(YEAR)/sn-assets-round-10/plot-grid.png \
	data/$(YEAR)/sn-assets-round-10/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-10/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 10 comp_id 11665 \
		home "4 8 1 3" away "5 7 6 2"
data/$(YEAR)/sn-assets-round-10/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-10/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 10 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-10/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-10/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 10 mname abilities_model_no_hga.stan
# Make blog for round 10
round10-blog: data/$(YEAR)/sn-assets-round-10/plot-grid-current.png \
	Rmd/$(YEAR)/.round10.bk
data/$(YEAR)/sn-assets-round-10/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-10/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 10
Rmd/$(YEAR)/.round10.bk: Rmd/$(YEAR)/round10.Rmd \
	data/$(YEAR)/sn-assets-round-10/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round10.md ~/github/website/content/post/$(YEAR)-07-07-round10.md \
	&& touch .round10.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round10/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-10/*.png ~/github/website/static/sn-assets/$(YEAR)/round10/

round11: data/$(YEAR)/sn-assets-round-11/stan_data.rds \
	data/$(YEAR)/sn-assets-round-11/plot-grid.png \
	data/$(YEAR)/sn-assets-round-11/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-11/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 11 comp_id 11665 \
		home "4 5 8 6" away "3 2 1 7"
data/$(YEAR)/sn-assets-round-11/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-11/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 11 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-11/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-11/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 11 mname abilities_model_no_hga.stan
# Make blog for round 11
round11-blog: data/$(YEAR)/sn-assets-round-11/plot-grid-current.png \
	Rmd/$(YEAR)/.round11.bk
data/$(YEAR)/sn-assets-round-11/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-11/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 11
Rmd/$(YEAR)/.round11.bk: Rmd/$(YEAR)/round11.Rmd \
	data/$(YEAR)/sn-assets-round-11/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round11.md ~/github/website/content/post/$(YEAR)-07-16-round11.md \
	&& touch .round11.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round11/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-11/*.png ~/github/website/static/sn-assets/$(YEAR)/round11/

round12: data/$(YEAR)/sn-assets-round-12/stan_data.rds \
	data/$(YEAR)/sn-assets-round-12/plot-grid.png \
	data/$(YEAR)/sn-assets-round-12/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-12/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 12 comp_id 11665 \
		home "3 8 2 7" away "5 6 4 1"
data/$(YEAR)/sn-assets-round-12/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-12/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 12 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-12/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-12/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 12 mname abilities_model_no_hga.stan
# Make blog for round 12
round12-blog: data/$(YEAR)/sn-assets-round-12/plot-grid-current.png \
	Rmd/$(YEAR)/.round12.bk
data/$(YEAR)/sn-assets-round-12/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-12/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 12
Rmd/$(YEAR)/.round12.bk: Rmd/$(YEAR)/round12.Rmd \
	data/$(YEAR)/sn-assets-round-12/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round12.md ~/github/website/content/post/$(YEAR)-07-25-round12.md \
	&& touch .round12.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round12/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-12/*.png ~/github/website/static/sn-assets/$(YEAR)/round12/

round13: data/$(YEAR)/sn-assets-round-13/stan_data.rds \
	data/$(YEAR)/sn-assets-round-13/plot-grid.png \
	data/$(YEAR)/sn-assets-round-13/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-13/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 13 comp_id 11665 \
		home "6 1 7 8" away "3 4 2 3"
data/$(YEAR)/sn-assets-round-13/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-13/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 13 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-13/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-13/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 13 mname abilities_model_no_hga.stan
# Make blog for round 13
round13-blog: data/$(YEAR)/sn-assets-round-13/plot-grid-current.png \
	Rmd/$(YEAR)/.round13.bk
data/$(YEAR)/sn-assets-round-13/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-13/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 13
Rmd/$(YEAR)/.round13.bk: Rmd/$(YEAR)/round13.Rmd \
	data/$(YEAR)/sn-assets-round-13/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round13.md ~/github/website/content/post/$(YEAR)-07-28-round13.md \
	&& touch .round13.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round13/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-13/*.png ~/github/website/static/sn-assets/$(YEAR)/round13/

round14: data/$(YEAR)/sn-assets-round-14/stan_data.rds \
	data/$(YEAR)/sn-assets-round-14/plot-grid.png \
	data/$(YEAR)/sn-assets-round-14/plot-grid-no-hga.png
data/$(YEAR)/sn-assets-round-14/stan_data.rds: R/in-season-data-prep.R
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 14 comp_id 11665 \
		home "5 4 5 8" away "1 6 7 2"
data/$(YEAR)/sn-assets-round-14/plot-grid.png: \
	R/in-season-model.R data/$(YEAR)/sn-assets-round-14/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 14 mname abilities_model.stan
data/$(YEAR)/sn-assets-round-14/plot-grid-no-hga.png: \
	R/in-season-model-no-hga.R data/$(YEAR)/sn-assets-round-14/stan_data.rds
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 14 mname abilities_model_no_hga.stan
# Make blog for round 14
round14-blog: data/$(YEAR)/sn-assets-round-14/plot-grid-current.png \
	Rmd/$(YEAR)/.round14.bk
data/$(YEAR)/sn-assets-round-14/plot-grid-current.png: \
	R/in-season-comparison.R data/$(YEAR)/sn-assets-round-14/plot-grid.png
	cd $(<D) \
	&& Rscript $(<F) year $(YEAR) round 14
Rmd/$(YEAR)/.round14.bk: Rmd/$(YEAR)/round14.Rmd \
	data/$(YEAR)/sn-assets-round-14/plot-grid.png
	cd $(<D) \
	&& Rscript -e "knitr::knit('$(<F)')" \
	&& mv round14.md ~/github/website/content/post/$(YEAR)-08-03-round14.md \
	&& touch .round14.bk \
  && mkdir -p ~/github/website/static/sn-assets/$(YEAR)/round14/ \
	&& cd $(ROOT_DIR) \
	&& cp data/$(YEAR)/sn-assets-round-14/*.png ~/github/website/static/sn-assets/$(YEAR)/round14/
