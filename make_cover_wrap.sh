#!/bin/bash
# make_cover_wrap.sh -- build a full cover wrap for a 6x9 book
#
# Usage: ./make_cover_wrap.sh <book_dir> <spine_width_inches> [output_file]
#
# Reads cover.yaml from <book_dir> for book-specific content.
#
# Example:
#   ./make_cover_wrap.sh kg-book 0.85
#   ./make_cover_wrap.sh kg-book 0.85 kg-book/cover_wrap.jpg
#
# Requirements: ImageMagick (convert), bc, python3 (for YAML parsing)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOK_DIR="${1:?Usage: $0 <book_dir> <spine_width_inches> [output_file]}"
SPINE_INCHES="${2:?Usage: $0 <book_dir> <spine_width_inches> [output_file]}"
OUTPUT="${3:-${BOOK_DIR}/cover_wrap.jpg}"

YAML="${SCRIPT_DIR}/${BOOK_DIR}/cover.yaml"
if [ ! -f "$YAML" ]; then
    echo "Error: $YAML not found" >&2
    exit 1
fi

# Parse cover.yaml fields
_yaml() {
    python3 -c "
import sys, yaml
with open('$YAML') as f:
    d = yaml.safe_load(f)
print(d.get('$1', ''))
"
}

SPINE_TEXT="$(_yaml spine_text)"
FRONT="$(_yaml front_image)"
FRONT="${SCRIPT_DIR}/${BOOK_DIR}/${FRONT}"
BACK_TEXT="$(_yaml back_text)"
TITLE_COLOR="$(_yaml title_color)"
CROP_MODE="$(_yaml front_image_crop)"
CROP_X_SOURCE="$(_yaml front_image_crop_x_source)"

DPI=300
HEIGHT=2700          # 9 inches * 300 DPI
COVER_W=1800         # 6 inches * 300 DPI
SPINE_W=$(echo "$SPINE_INCHES * $DPI" | bc | xargs printf "%.0f")
TOTAL_W=$(( COVER_W + SPINE_W + COVER_W ))

DARK_BLUE="#1a2a4a"
WHITE="#ffffff"
FONT="DejaVu-Sans-Bold"

# --- Back cover ---
BACK_FONT_SIZE=36
BACK_MARGIN=150
BACK_TEXT_W=$(( COVER_W - BACK_MARGIN * 2 ))
BACK_Y=$(( HEIGHT * 2 / 5 ))

convert \
    -size "${BACK_TEXT_W}x" \
    -background "${DARK_BLUE}" \
    pango:"<span font='DejaVu Sans Bold ${BACK_FONT_SIZE}' foreground='${WHITE}'>${BACK_TEXT}</span>" \
    /tmp/back_text.png

TEXT_H=$(identify -format "%h" /tmp/back_text.png)
COMPOSITE_Y=$(( BACK_Y - TEXT_H / 2 ))
if [ "${COMPOSITE_Y}" -lt "${BACK_MARGIN}" ]; then
    COMPOSITE_Y=${BACK_MARGIN}
fi

convert \
    -size "${COVER_W}x${HEIGHT}" xc:"${DARK_BLUE}" \
    /tmp/back_text.png \
    -geometry "+${BACK_MARGIN}+${COMPOSITE_Y}" \
    -composite \
    /tmp/back_cover.png

# --- Spine ---
SPINE_FONT_SIZE=60

convert \
    -size "${HEIGHT}x${SPINE_W}" xc:"${DARK_BLUE}" \
    -fill "${WHITE}" \
    -font "${FONT}" \
    -pointsize "${SPINE_FONT_SIZE}" \
    -gravity Center \
    -annotate 0 "${SPINE_TEXT}" \
    -rotate 90 \
    /tmp/spine.png

# --- Front cover ---
if [ "$CROP_MODE" = "custom" ] && [ -n "$CROP_X_SOURCE" ]; then
    # Custom crop: center a specific x coordinate from the source image
    SRC_H=$(identify -format "%h" "${FRONT}")
    SCALE=$(echo "scale=6; $HEIGHT / $SRC_H" | bc)
    SRC_MID_SCALED=$(echo "scale=0; $CROP_X_SOURCE * $SCALE / 1" | bc)
    CROP_X=$(( SRC_MID_SCALED - COVER_W / 2 ))
    if [ "$CROP_X" -lt 0 ]; then CROP_X=0; fi
    SCALED_W=$(echo "scale=0; $(identify -format "%w" "${FRONT}") * $HEIGHT / $SRC_H" | bc)
    convert \
        "${FRONT}" \
        -resize "x${HEIGHT}" \
        -gravity NorthWest \
        -extent "${SCALED_W}x${HEIGHT}" \
        -crop "${COVER_W}x${HEIGHT}+${CROP_X}+0" +repage \
        /tmp/front_cover_base.png
else
    # Default: scale to fill, center crop
    convert \
        "${FRONT}" \
        -resize "${COVER_W}x${HEIGHT}^" \
        -gravity Center \
        -extent "${COVER_W}x${HEIGHT}" \
        /tmp/front_cover_base.png
fi

# --- Title overlay ---
TITLE_TEXT="$(_yaml title)"
TITLE_FONT_SIZE=80
TITLE_MARGIN=120
TITLE_TEXT_W=$(( COVER_W - TITLE_MARGIN * 2 ))

convert \
    -size "${TITLE_TEXT_W}x" \
    -background none \
    pango:"<span font='DejaVu Sans Bold ${TITLE_FONT_SIZE}' foreground='${TITLE_COLOR}'>${TITLE_TEXT}</span>" \
    /tmp/front_title.png

TITLE_H=$(identify -format "%h" /tmp/front_title.png)
TITLE_Y=$(( TITLE_MARGIN + TITLE_H ))

# --- Author name at bottom ---
AUTHOR_TEXT="$(_yaml author)"
convert \
    -size "${TITLE_TEXT_W}x" \
    -background none \
    pango:"<span font='DejaVu Sans Bold 60' foreground='${TITLE_COLOR}'>${AUTHOR_TEXT}</span>" \
    /tmp/front_author.png

AUTHOR_H=$(identify -format "%h" /tmp/front_author.png)
AUTHOR_Y=$(( HEIGHT - TITLE_MARGIN - AUTHOR_H ))

convert \
    /tmp/front_cover_base.png \
    /tmp/front_title.png \
    -geometry "+${TITLE_MARGIN}+${TITLE_Y}" \
    -composite \
    /tmp/front_author.png \
    -geometry "+${TITLE_MARGIN}+${AUTHOR_Y}" \
    -composite \
    /tmp/front_cover.png

# --- Assemble wrap: back | spine | front ---
convert \
    /tmp/back_cover.png \
    /tmp/spine.png \
    /tmp/front_cover.png \
    +append \
    -density "${DPI}" \
    "${OUTPUT}"

echo "Written: ${OUTPUT}  (${TOTAL_W}x${HEIGHT} px, spine ${SPINE_W}px / ${SPINE_INCHES}\")"
