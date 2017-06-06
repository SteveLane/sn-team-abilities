# Time-stamp: <2017-06-07 08:03:37 (slane)>
.PHONY: data

DATA= data/sn-ladder.json data/sn-scores-teams.json

data: $(DATA)

################################################################################
# Grab and process data
data/sn-scores.rds: R/grab-data.R
	cd $(<D); \
	Rscript --no-save --no-restore $(<F)

$(DATA): R/data-prep.R data/sn-scores.rds
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
