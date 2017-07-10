# Time-stamp: <2017-07-10 20:37:23 (slane)>
.PHONY: data

DATA= data/sn-ladder.json data/sn-scores-teams.json

data: $(DATA)

OUTPUTS= data/predDiffs.rds data/abilities.rds

outputs: $(OUTPUTS)

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
.INTERMEDIATES: .data.im .outputs.im
