# Makefile for grant components. Compiles individual documents or everything.
#
# NIH R01 "BiVRepair" (PI: Chabiniok, UTSW; Yale subaward: Pfaller). The
# Research Strategy lives in the shared Overleaf project; grant_application.tex
# and the shared style files mirror its current state. This repository also
# holds the supporting documents and the Yale subaward documents. Files keep
# their Overleaf names so they round-trip with the shared project.
#
#   make               build all documents below
#   make application   grant_application.pdf          (full application)
#   make summary       R01_summary.pdf                (Project Summary)
#   make narrative     R01_narrative.pdf              (Project Narrative)
#   make facilities    R01_facilities.pdf             (Facilities and Other Resources)
#   make equipment     R01_equipment.pdf              (Equipment)
#   make dms           R01_data.pdf                   (Data Management and Sharing Plan)
#   make budget        Yale_budget_justification.pdf  (Yale subaward)
#   make sow           Yale_statement_of_work.pdf     (Yale subaward)
#   make dated         copy each document PDF to <name>_YYYYMMDD.pdf
#   make clean         remove LaTeX auxiliary files
#   make distclean     also remove generated PDFs

# ---------------------------------------------------------------- CONFIG ----

# Documents that cite the bibliography (get a bibtex pass when they cite)
BIB_DOCS   = grant_application

# Documents without citations
PLAIN_DOCS = R01_summary R01_narrative R01_facilities R01_equipment R01_data \
             Yale_budget_justification Yale_statement_of_work

# Files shared by every document (rebuild when these change)
COMMON_DEPS = preamble.tex definitions.sty abbreviations.tex abbreviations_martin.tex

# Extra files the bibliography needs
BIB_DEPS    = references.bib martin_highlighted.bib mrp.bst

# ------------------------------------------------------------- MACHINERY ----

PDFLATEX = pdflatex -interaction=nonstopmode -halt-on-error
BIBTEX   = bibtex

ALL_DOCS = $(BIB_DOCS) $(PLAIN_DOCS)
ALL_PDFS = $(addsuffix .pdf,$(ALL_DOCS))

# Date suffix for the `dated` target (format: YYYYMMDD)
DATE = $(shell date +%Y%m%d)

.PHONY: all application summary narrative facilities equipment dms budget sow dated clean distclean

all: $(ALL_PDFS)

# Convenience aliases
application: grant_application.pdf
summary:     R01_summary.pdf
narrative:   R01_narrative.pdf
facilities:  R01_facilities.pdf
equipment:   R01_equipment.pdf
dms:         R01_data.pdf
budget:      Yale_budget_justification.pdf
sow:         Yale_statement_of_work.pdf

# Documents with bibliography: pdflatex -> bibtex (only if the document
# actually cites something) -> pdflatex -> pdflatex
$(addsuffix .pdf,$(BIB_DOCS)): %.pdf: %.tex $(COMMON_DEPS) $(BIB_DEPS)
	$(PDFLATEX) $<
	@if grep -q citation $*.aux; then $(BIBTEX) $*; else echo "no citations in $* -- skipping bibtex"; fi
	$(PDFLATEX) $<
	$(PDFLATEX) $<

# Documents without bibliography: pdflatex -> pdflatex (resolve cross-references)
$(addsuffix .pdf,$(PLAIN_DOCS)): %.pdf: %.tex $(COMMON_DEPS)
	$(PDFLATEX) $<
	$(PDFLATEX) $<

# Build everything and copy each document PDF to <name>_YYYYMMDD.pdf
dated: $(ALL_PDFS)
	@for pdf in $(ALL_PDFS); do \
		cp $$pdf $${pdf%.pdf}_$(DATE).pdf; \
		echo "wrote $${pdf%.pdf}_$(DATE).pdf"; \
	done

clean:
	rm -f *.aux *.log *.out *.bbl *.blg *.bcf *.run.xml *.toc *.fls *.fdb_latexmk *.synctex.gz *.dvi *.glo *.gls *.glg *.ist *.acn *.acr *.alg

distclean: clean
	rm -f $(ALL_PDFS) *_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].pdf
