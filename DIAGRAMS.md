# Adding Diagrams to the Graphwright Books

## Source formats

**Raster images (PNG/JPG):** Use directly -- they work in both PDF and mkdocs
with no conversion step.

**SVG diagrams:** Preferred for line art. The Makefile already auto-converts
every `*.svg` in the book directory to a same-named `.pdf` via Inkscape before
the LaTeX build. In `text.md`, reference the `.pdf` version:

```markdown
![](my-diagram.pdf)
```

The SVG is the source of truth; the PDF is a build artifact. The `make clean`
target already removes generated PDFs, so there is no need to add them to
`.gitignore` separately.

## Placement in text.md

Put the image tag on its own line, preceded and followed by a blank line. Put
the caption on the very next line after the image tag (no blank line between
image and caption):

```markdown
![](my-diagram.pdf)

The caption goes here, describing what the figure shows.
```

This is exactly the pattern already used throughout `kg-book/text.md` (for
example at the `ExampleGraph.png`, `link_without_metadata.pdf`,
`link_with_metadata.pdf`, `GraphVisualization.png`, and `MetadataView.png`
figures).

## PDF build

The `IMAGES` variable in each book's `Makefile` picks up everything
automatically:

```makefile
SVG_PDFS := $(patsubst %.svg,%.pdf,$(wildcard *.svg))
IMAGES := $(wildcard *.png *.jpg *.jpeg) $(SVG_PDFS)
```

Any PNG/JPG dropped in the book directory, or any SVG whose `.pdf` has been
generated, is automatically listed as a dependency of the PDF target. No
Makefile edits are needed.

## mkdocs build

`scripts/split_for_mkdocs.py` writes chapter `.md` files into a `docs/`
subdirectory tree. Because image paths in `text.md` are bare filenames (e.g.,
`ExampleGraph.png`, not `./images/ExampleGraph.png`), those paths will be
broken unless the image files are also copied into `docs/`. The script
currently does not copy images -- that is a gap to handle. The two practical
options are:

1. **Copy images alongside the docs output.** After running
   `split_for_mkdocs.py`, copy all `*.png`, `*.jpg`, and `*.jpeg` files into
   each `docs/` subdirectory that references them (or into a shared
   `docs/images/` directory and update the references). This can be done as a
   shell step or by extending the script.

2. **Keep images in an `images/` subdirectory** from the start. Place all
   diagram files in e.g. `kg-book/images/` and reference them as
   `images/my-diagram.pdf` in `text.md`. Then for mkdocs output you only need
   to copy that one folder. The downside is that the PDF build currently globs
   `*.png *.jpg *.jpeg` in the book root, so the Makefile would also need
   updating to pick up `images/*.png` etc.

The current books use the flat layout (images in the book root) but the mkdocs
copy step is manual. If you want mkdocs to work cleanly out of the box,
extending the script to copy image files is the cleanest fix.

## Step-by-step workflow

1. **Create** your diagram as SVG (for line art) or PNG/JPG (for
   screenshots/photos). Place the file in the book directory (e.g.,
   `kg-book/my-diagram.svg`).

2. **Reference** it in `text.md` using the `.pdf` extension for SVGs, or the
   original extension for raster images:

   ```markdown
   ![](my-diagram.pdf)

   Caption describing what the figure shows.
   ```

3. **Build** with `make kg-book` -- Inkscape converts the SVG to PDF
   automatically, then pandoc and xelatex include it in the final PDF.

4. **For mkdocs:** after running `split_for_mkdocs.py`, copy the image files
   next to the generated `.md` files (or extend the script to do it
   automatically).
