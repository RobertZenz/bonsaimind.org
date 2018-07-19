#!/usr/bin/env sh

# Copyright (c) Robert 'Bobby' Zenz
# 
# Licensed under CC0 or Public Domain


# The out directory.
OUT="./out"

# Check if the out directory 
if [ ! -d "$OUT" ]; then
	mkdir "$OUT"
fi

# Run Pandoc.
./pandoc-linux-x64 \
	--from=markdown-smart+ascii_identifiers \
	--to=html \
	--output="$OUT/index.html" \
	--eol=lf \
	--template="index.template" \
	--lua-filter="filter.lua" \
	"index.markdown"

# Copy the resource files.
cp -f "avatar.png" "$OUT/"
cp -f "icons.svg" "$OUT/"
cp -f "logo.svg" "$OUT/"
