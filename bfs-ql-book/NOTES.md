# Production Notes

## File layout

| File | Purpose |
|------|---------|
| `outline.md` | High-level structure and chapter summaries. Edit this first. |
| `text.md` | Full book prose. Chapters added here as they are written. |
| `BFS-QL-SPEC.md` | The protocol spec — becomes the Appendix with minimal editing. |
| `references.bib` | BibTeX entries. Add entries here as citations appear in the outline. |
| `README.md` | Product description / back-cover copy. |

## Citations

Pandoc `--citeproc` with no `.csl` file specified defaults to **Chicago author-date**.
Inline citations render as `(Vaswani et al. 2017)`.

Syntax in Markdown:

```markdown
As shown by the transformer architecture [@vaswani2017attention], attention
is O(n²) in sequence length [@vaswani2017attention, p. 3].
```

To switch citation style later, drop a `.csl` file in the directory and add
`--csl=filename.csl` to the Pandoc command. The `.bib` file does not change.
CSL files for common styles (APA, IEEE, Chicago) are at citationstyles.org.

## Index entries

Raw LaTeX inline in Markdown. Requires `-f markdown+raw_tex` in the Pandoc
command and `makeindex` (or `xindy`) run on the generated `.idx` file.

```markdown
The context window\index{context window} is a scarce resource.

\index{context window!as working set}
\index{RISC|see{instruction set architecture}}
```

## Back-matter order

1. Appendix (BFS-QL Reference — migrated from `BFS-QL-SPEC.md`)
2. References / Bibliography
3. Index (always last)

## Build

Match the kgraph book Makefile: 6×9 geometry, xelatex, `--citeproc`,
`--bibliography=references.bib`, `-f markdown+raw_tex`.

See `/home/wware/kg-book/Makefile` and `/home/wware/kg-book/LULU_HOWTO.md`
for the reference build setup.

## Relationship to companion volume

*Knowledge Graphs from Unstructured Text* (`/home/wware/kg-book/outline.md`)
is the companion volume. Same series, same publisher (Lulu / Graphwright
Publications), same build toolchain.

The coupling point in code: `KGraphPostgresBackend` — kgraph writes,
BFS-QL reads.

Canonical identity argument appears in both books:
- kgraph: Ch 3 (definition), Ch 2 (cross-disciplinary machine), Ch 9 (diagnostics)
- BFS-QL: Preface (emergent interoperability layer), Ch 13 (identity bridging)
