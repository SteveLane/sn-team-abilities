# Time-stamp: <2017-07-10 21:39:39 (slane)>
.PHONY: data outputs figures

DATA= data/sn-ladder.json data/sn-scores-teams.json
data: $(DATA)

OUTPUTS= data/predDiffs.rds data/abilities.rds
outputs: $(OUTPUTS)

FIGURES= graphics/abilities-vixens-lightning.png \
	graphics/score-diff-vixens.png \
	graphics/score-diff-all.png
figures: $(FIGURES)

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
