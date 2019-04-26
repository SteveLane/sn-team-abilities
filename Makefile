# Time-stamp: <2019-04-26 15:28:00 (slane)>
# Generate the shrunken priors from last season.
.PHONY: shrinking
shrinking: data/shrunken_abilities_2019.rds
data/shrunken_abilities_2019.rds: R/post-finals-model.R data-raw/season_2018.rds
	cd $(<D) \
	&& Rscript $(<F) year 2018 round 17 comp_id 10394

################################################################################
# Grab and process data
data/sn-scores.rds: R/grab-data.R
	cd $(<D); \
	Rscript --no-save --no-restore $(<F)

$(DATA): .data.im
	@
.data.im: R/data-prep.R data/sn-scores.rds
	cd $(<D); \
	Rscript --no-save --no-restore $(<F)

$(OUTPUTS): .outputs.im
	@
.outputs.im: R/fit-model.R R/functions.R \
	data/sn-scores.rds data/team-lookups.rds
	cd $(<D); \
	Rscript --no-save --no-restore $(<F)

$(FIGURES): .figures.im
	@
.figures.im: R/create-figures.R R/ggsteve.R $(OUTPUTS)
	cd $(<D); \
	Rscript --no-save --no-restore $(<F)

################################################################################
# Cleaning targets
clean-models:
	cd stan/; \
	rm -f *.rds

clean-manuscripts:
	cd manuscripts/; \
	rm -rf *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.lof *.log *.lot \
		*.code *.loe *.toc *.rec *.out *.run.xml *~ *.prv \
		censored-mle.tex _region_*

clobber: clean-data clean-manuscripts
	cd manuscripts/; \
	rm -rf auto/ cache/ figure/

################################################################################
# intermediates
.INTERMEDIATES: .data.im .outputs.im .figures.im
