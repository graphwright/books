ROOT := ..
SVG_PDFS := $(patsubst %.svg,%.pdf,$(wildcard *.svg))
IMAGES := $(wildcard *.png *.jpg *.jpeg) $(SVG_PDFS)
PANDOC := pandoc
SRC := text.md
STEM := bfsql
GEOMETRY := paperwidth=6in,paperheight=9in,top=0.75in,bottom=0.75in,inner=0.875in,outer=0.625in

.PHONY: all clean cover-wrap

all: $(STEM).epub $(STEM).pdf

clean:
	rm -f $(STEM).epub $(STEM).pdf $(STEM).tex $(STEM).aux $(STEM).idx \
	      $(STEM).ind $(STEM).ilg $(STEM).log $(STEM).out $(STEM).toc \
	      cover.pdf $(SVG_PDFS)

%.pdf: %.svg
	inkscape --export-filename=$@ $<

$(STEM).epub: $(SRC) $(IMAGES)
	$(PANDOC) $(SRC) -o $@

$(STEM).pdf: $(STEM).tex $(IMAGES)
	xelatex -interaction=nonstopmode $(STEM).tex || true
	-makeindex -s $(ROOT)/index.ist $(STEM)
	xelatex -interaction=nonstopmode $(STEM).tex
	xelatex -interaction=nonstopmode $(STEM).tex

$(STEM).tex: $(SRC) $(ROOT)/index-header.tex $(ROOT)/index-footer.tex $(ROOT)/index.ist references.bib
	$(PANDOC) $(SRC) \
	  -f markdown+raw_tex \
	  --top-level-division=part \
	  --toc \
	  -V documentclass=book \
	  -V fontsize=11pt \
	  -V classoption=openright \
	  -V geometry:"$(GEOMETRY)" \
	  --include-in-header=$(ROOT)/index-header.tex \
	  --include-after-body=$(ROOT)/index-footer.tex \
	  --citeproc \
	  --bibliography=references.bib \
	  --metadata cover-image= \
	  -o $(STEM).tex

cover-wrap: cover.yaml
	$(ROOT)/make_cover_wrap.sh bfs-ql-book $(SPINE_INCHES)
