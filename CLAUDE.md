# Graphwright Series -- Book Formatting Conventions

This file documents formatting practices shared across all three books in the
Graphwright series. It applies to every `text.md` and `outline.md` in this repo.

---

## Series Overview

Three books, all by Will Ware, targeting Lulu 6×9 print (placeholder imprint:
"Graphwright Publications"):

1. **identity-book** -- *The Typed Graph: How Machine Knowledge Earns Trust*
   Canonical identity, typed graphs, the identity server, social implications.
2. **kg-book** -- *Knowledge Graphs from Unstructured Text*
   Extraction pipelines, schema design, ingestion, provenance tracking.
3. **bfs-ql-book** -- *BFS-QL: A Graph Query Protocol for Language Models*
   The five-tool BFS-QL protocol, backend implementation, LLM integration.

Cross-references between books use the full title italicized:
*The Typed Graph: How Machine Knowledge Earns Trust*, etc.

The Foreword is shared across all three volumes.

---

## Repo Layout

```
books/
  Makefile                 # top-level: make, make identity-book, make clean, etc.
  make_cover_wrap.sh       # shared cover wrap builder (reads cover.yaml)
  index-header.tex         # shared LaTeX header (TOC, index setup, fvextra)
  index-footer.tex         # shared LaTeX footer (\printindex)
  index.ist                # shared makeindex style
  scripts/
    split_for_mkdocs.py
    format_chat.py
  identity-book/
    text.md                # manuscript (source of truth)
    outline.md             # chapter-by-chapter bullet summary, not prose
    references.bib
    cover.yaml             # book-specific cover content
    Makefile               # delegates to shared infrastructure
    orion_and_taurus.png
  kg-book/
    text.md, outline.md, references.bib, cover.yaml, Makefile
    Cover6x9.jpg
  bfs-ql-book/
    text.md, outline.md, references.bib, cover.yaml, Makefile
    interference.png
    BFS-QL-SPEC.md, NOTES.md, epub.css
```

---

## Build

```bash
make                  # build all three books
make identity-book    # build one book
make kg-book
make bfs-ql-book
make clean            # clean all books
make -C kg-book clean # clean one book

# Cover wrap (run from books/ root):
./make_cover_wrap.sh kg-book 0.85
./make_cover_wrap.sh kg-book 0.85 kg-book/cover_wrap.jpg
```

Requires: `pandoc`, `xelatex`, `makeindex`, `inkscape` (for SVG diagrams),
`imagemagick` (for cover wrap), `uv` (for cover YAML parsing).

The PDF build pipeline is: `pandoc → <stem>.tex`, then `xelatex` (×2) with
`makeindex` between passes. SVG diagrams are pre-converted to PDF via Inkscape.

For Python scripting tasks, use `uv run python` -- not `python3`.

---

## Writing Style

Keep the writing as **clear** as possible -- do not make the reader work hard.
Avoid over-reliance on usages common in the AI/LLM/tech community or the
NLP/linguistics community in favor of standard English usage, as many readers
will be non-technical. Acronyms, even common ones like "LLM", should be spelled
out in parentheses on first usage.

Prefer active, direct prose. Technical precision and readability are not in
tension -- choose words that are both exact and plain.

---

## Markdown Formatting

### Dashes

- Use `--` (double hyphen) for em dashes, not `—` (Unicode em dash) and not `---`.
- Example: `The model doesn't know -- it just guesses.`

### Quotation Marks

- Use straight double quotes `"..."`, not curly/smart quotes `"..."`.

### Italics

- Use `*word*` for emphasis and book/paper titles in running text.
- Example: `*Gödel, Escher, Bach*`, `*Science*`, `*this is the key point*`

### Headings

All books use pandoc with `--top-level-division=part`:

- `#` → Part (also used for Appendix headings: `# Appendix A: ...`)
- `##` → Chapter
- `###` → Section
- `####` → Subsection

Chapter headings use title case: `## Chapter 2: A Brief History of Knowledge Representation`

Section headings use sentence case: `### The idea that wouldn't die`

(Exception: proper names or established phrases keep their capitalization.)

Appendix sections use `###` (not `##`), since the appendix is already at `#` level.

### YAML Frontmatter

Each `text.md` begins with YAML frontmatter delimited by `---` / `...`:

```yaml
---
title: "Book Title Here"
author: Will Ware
rights: © 2026 Will Ware, MIT License
language: en-US
description: "A practitioner's guide..."
...
```

---

## LaTeX Inline Markup

Raw LaTeX is passed through pandoc using the `{=latex}` attribute on inline spans.

### Chapter running headers

Every chapter needs a `\chaptermark` immediately after the `##` heading line:

```markdown
## Chapter 6: LLMs Make This Practical Now

`\chaptermark{LLMs Make This Practical Now}`{=latex}
```

For the Foreword:

```markdown
`\markboth{Foreword}{Foreword}`{=latex}
```

Use a shortened title if the full chapter title is long.

---

## Index Entries

Index entries use `\index{...}` inline, with no space before the tag:

```
word\index{entry}
Douglas Hofstadter's\index{Hofstadter, Douglas} argument...
```

### Index entry rules

1. **Do not start with "The"** -- invert it: `Automation of Science, The (King)`
2. **People**: `Lastname, Firstname` -- e.g., `\index{Hofstadter, Douglas}`
3. **Books and papers**: `Title (Author)`, omitting leading "The"
4. **Italicized titles** use a sort key:
   `\index{Godel Escher Bach@\textit{Gödel, Escher, Bach} (Hofstadter)}`
5. **Subtopics** use `!`: `\index{knowledge graph!definition}`
6. **Cross-references** use `|see{...}`: `\index{RAG|see{retrieval-augmented generation}}`
7. **Parenthetical qualifiers**: `\index{Adam (robot scientist)}`

### Placement

- Place `\index{...}` immediately after the word or phrase it marks.
- For people, index at first mention in each chapter.
- For concepts, index at the defining or most significant mention.

---

## Citations

Citations use pandoc-citeproc with BibTeX. Format: `[@citekey]` immediately after
the claim being cited.

BibTeX key convention: `lastnameYYYYkeyword` -- e.g., `hofstadter1979geb`.

In BibTeX entries:
- Page ranges use `--`: `pages = {1940--1951}`
- Author names: `Lastname, Firstname and Lastname2, Firstname2`

The References section is generated automatically by pandoc-citeproc via
`index-header.tex`.

---

## Images

- PNG and JPG images are included directly.
- SVG diagrams must be pre-converted to PDF by `make` (via Inkscape).
  Reference them as `.pdf` in the markdown: `![](diagram.pdf)`.
- Captions go on the line immediately after the image tag, as plain text.

---

## Code Blocks

Fenced code blocks with no language tag are used for ASCII diagrams and pipeline
illustrations. Use a language tag for syntax-highlighted code.

### Line length limit

The text block on a 6×9 page at 11pt is approximately **4.5 inches wide**,
fitting roughly **65 characters** of monospace text. Keep all code block lines
to 65 characters or fewer.

For long strings, break manually:

```json
"evidence": "Serum cortisol levels were elevated in
  all patients diagnosed with hypercortisolism."
```

For long shell commands, use `\` continuation:

```bash
uv run python -m medlit.scripts.extract \
    --input-dir pmc_xmls/ \
    --output-dir extracted/
```

### Pandoc verbatim pitfall

Plain ` ``` ` blocks become `\begin{verbatim}` in LaTeX. Pandoc **will not**
treat the closing ` ``` ` as a fence closer if the block content looks like a
markdown list (numbered items `1.` `2.` etc.).

**Rule**: Any plain ` ``` ` block whose content contains numbered items or other
markdown-looking syntax must use ` ```text ` instead.

After any significant edit, check the build log:
```bash
grep -c "Overfull" <stem>.log
```
A count above ~10 usually indicates a runaway verbatim block. Investigate with:
```bash
grep -n '\\begin{verbatim}\|\\end{verbatim}' <stem>.tex
```

---

## Document Structure Notes

- The Foreword appears before the Preface and Part I. Shared across all volumes.
- Parts: `# Part I: The Landscape` (Roman numerals)
- Chapters: `## Chapter 1: Why Do We Want to Build Knowledge Graphs?` (Arabic)
- Appendices: `# Appendix A: ...` at Part level
- Index appended via `index-footer.tex` (`\printindex`)
- References inserted before index by pandoc-citeproc

---

## Lulu Print Specs

- Paper: 6in × 9in
- Margins: top 0.75in, bottom 0.75in, inner 0.875in (binding), outer 0.625in
- Font size: 11pt
- `classoption=openright` (chapters start on right-hand pages)
- Cover is a separate PDF uploaded independently via `make_cover_wrap.sh`

---

## Cover Wrap

Book-specific cover content lives in `<book>/cover.yaml`:
- `title`, `author`, `spine_text` -- text for spine and front overlay
- `front_image` -- filename of front cover image
- `front_image_crop` -- `scale_and_center` (default) or `custom`
- `title_color` -- hex color for title/author text overlay
- `back_text` -- back cover blurb

Run `./make_cover_wrap.sh <book> <spine_inches>` from the `books/` root.
