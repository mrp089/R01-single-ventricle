# Makefile for grant components. Compiles individual documents or everything.
#
# NIH R01 "BiVRepair" (PI: Chabiniok, UTSW). This repository develops only the
# Yale (Pfaller) part: Aim 3 research strategy content and the Yale subaward
# documents. The research strategy itself lives in the shared Overleaf project;
# grant_application.tex and the shared style files mirror its current state so
# Yale fragments can be previewed in context. Files keep their Overleaf names
# so they round-trip with the shared project without renaming.
#
#   make               build all PDFs below
#   make budget        Yale_budget_justification.pdf
#   make sow           Yale_statement_of_work.pdf
#   make figure        figures/aim3_figure.pdf  (Aim 3 preliminary-results figure)
#   make aim3          aim3_preview.pdf         (Yale strategy content, rendered
#                                                with the shared preamble)
#   make application   grant_application.pdf    (full application, current
#                                                Overleaf state)
#   make dated         copy each document PDF to <name>_YYYYMMDD.pdf
#   make clean         remove LaTeX auxiliary files
#   make distclean     also remove generated PDFs

# ---------------------------------------------------------------- CONFIG ----

# Documents that cite the bibliography (get a bibtex pass when they cite)
BIB_DOCS   = grant_application aim3_preview

# Documents without citations
PLAIN_DOCS = Yale_budget_justification Yale_statement_of_work

# Files shared by every document (rebuild when these change)
COMMON_DEPS = preamble.tex definitions.sty abbreviations.tex abbreviations_martin.tex

# Extra files the bibliography needs
BIB_DEPS    = references.bib martin_highlighted.bib mrp.bst

# Aim 3 figure: standalone TikZ source and its panels, built in figures/aim3/
FIG_DIR  = figures/aim3
FIG_SRCS = $(FIG_DIR)/aim3_figure.tex $(wildcard $(FIG_DIR)/*.png)

# ------------------------------------------------------------- MACHINERY ----

PDFLATEX = pdflatex -interaction=nonstopmode -halt-on-error
BIBTEX   = bibtex

ALL_DOCS = $(BIB_DOCS) $(PLAIN_DOCS)
ALL_PDFS = $(addsuffix .pdf,$(ALL_DOCS)) figures/aim3_figure.pdf

# Date suffix for the `dated` target (format: YYYYMMDD)
DATE = $(shell date +%Y%m%d)

.PHONY: all budget sow aim3 application figure dated clean distclean

all: $(ALL_PDFS)

# Convenience aliases
budget:      Yale_budget_justification.pdf
sow:         Yale_statement_of_work.pdf
aim3:        aim3_preview.pdf
application: grant_application.pdf
figure:      figures/aim3_figure.pdf

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

# Aim 3 preliminary figure: compiled in its own directory, then copied to
# figures/ where grant_application.tex and aim3_preview.tex expect it
figures/aim3_figure.pdf: $(FIG_SRCS)
	cd $(FIG_DIR) && $(PDFLATEX) aim3_figure.tex
	cp $(FIG_DIR)/aim3_figure.pdf $@

# The preview embeds the figure and the innovation fragment
aim3_preview.pdf: figures/aim3_figure.pdf innovation_gr.tex

# Build everything and copy each document PDF to <name>_YYYYMMDD.pdf
dated: $(ALL_PDFS)
	@for pdf in $(addsuffix .pdf,$(ALL_DOCS)); do \
		cp $$pdf $${pdf%.pdf}_$(DATE).pdf; \
		echo "wrote $${pdf%.pdf}_$(DATE).pdf"; \
	done

clean:
	rm -f *.aux *.log *.out *.bbl *.blg *.bcf *.run.xml *.toc *.fls *.fdb_latexmk *.synctex.gz *.dvi *.glo *.gls *.glg *.ist *.acn *.acr *.alg
	rm -f $(FIG_DIR)/*.aux $(FIG_DIR)/*.log

distclean: clean
	rm -f $(addsuffix .pdf,$(ALL_DOCS)) figures/aim3_figure.pdf $(FIG_DIR)/aim3_figure.pdf *_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].pdf
