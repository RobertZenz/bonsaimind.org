#!/usr/bin/env sh

# Copyright (c) Robert 'Bobby' Zenz
# 
# Licensed under CC0 or Public Domain


# The content directory.
CONTENT="./content"

# The out directory.
OUT="./out"

# The processing directory.
PROCESSING="./processing"


# Check if the out directory 
if [ ! -d "$OUT" ]; then
	mkdir "$OUT"
fi

# Run Pandoc.
$PROCESSING/pandoc-linux-x64 \
	--from=markdown-smart+ascii_identifiers \
	--to=html \
	--output="$OUT/index.html" \
	--eol=lf \
	--template="$PROCESSING/index.template" \
	--lua-filter="$PROCESSING/filter.lua" \
	"$CONTENT/index.markdown"

# Copy the resource files.
cp -f "$CONTENT/avatar.png" "$OUT/"
cp -f "$CONTENT/icons.svg" "$OUT/"
cp -f "$CONTENT/logo.svg" "$OUT/"
