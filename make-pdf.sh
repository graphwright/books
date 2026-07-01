#!/bin/sh

if [ "$#" -eq 0 ]; then
    set -- README
fi

TMPFILE=$(mktemp /tmp/unicode-chars.XXXXXX.tex)
cat > "$TMPFILE" << 'EOF'
\catcode`→=\active
\catcode`∈=\active
\catcode`≥=\active
{\catcode`→=\active \catcode`∈=\active \catcode`≥=\active
\gdef→{\ensuremath{\rightarrow}}%
\gdef∈{\ensuremath{\in}}%
\gdef≥{\ensuremath{\geq}}}
EOF
trap 'rm -f "$TMPFILE" "$MDTMP"' EXIT

STATUS=0
for ARG in "$@"; do
    NAME="${ARG%.md}"

    if [ ! -f "${NAME}.md" ]; then
        echo "make-pdf.sh: ${NAME}.md: No such file" >&2
        STATUS=1
        continue
    fi

    MDTMP=$(mktemp /tmp/pandoc-input.XXXXXX.md)
    # Strip remote-image lines (e.g. GitHub badges) that require svg.sty.
    # Also collapse GitHub-safe "\\_" (GFM's math renderer strips one level
    # of backslash-escaping, so literal underscores need doubling there) down
    # to the single "\_" that raw LaTeX/xelatex expects.
    sed -e '/^!\[.*\](https\{0,1\}:\/\//d' \
        -e 's/\\\\_/\\_/g' \
        "${NAME}.md" > "$MDTMP"

    pandoc "$MDTMP" \
        -o "${NAME}.pdf" \
        --pdf-engine="/Library/TeX/texbin/xelatex" \
        -H "$TMPFILE" \
        -V geometry:margin=0.75in \
        -V fontsize=11pt \
        -V mainfont="Georgia" \
        -V monofont="Menlo" \
        -V monofontoptions="Scale=0.85" \
        -V colorlinks=true \
        -V linkcolor=NavyBlue \
        --syntax-highlighting=tango || STATUS=1

    rm -f "$MDTMP"
done

exit $STATUS
