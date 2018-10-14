#!/usr/bin/env sh

# Copyright (c) Robert 'Bobby' Zenz
# 
# Licensed under CC0 or Public Domain


# The content directory.
CONTENT="./content"

# The out directory.
OUT="./out"

# The template directory.
TEMPLATES="./templates"

# The toolchain directory.
TOOLCHAIN="./toolchain"


# Check if the out directory 
if [ ! -d "$OUT" ]; then
	mkdir "$OUT"
fi

# Run Pandoc.
$TOOLCHAIN/pandoc-linux-x64 \
	--from=markdown-smart+ascii_identifiers \
	--to=html \
	--output="$OUT/index.html" \
	--eol=lf \
	--template="$TEMPLATES/index.template" \
	--lua-filter="$TOOLCHAIN/filter.lua" \
	--variable="DATE:$(date +%Y-%m-%d\ %H:%M:%S\ %::z)" \
	--variable="GIT_REPO:https://gitlab.com/RobertZenz/bonsaimind.org" \
	--variable="GIT_COMMIT:$(git rev-parse HEAD 2> /dev/null)" \
	"$CONTENT/index.markdown"

# Copy the resource files.
cp -f "$CONTENT/avatar.png" "$OUT/"
cp -f "$CONTENT/icons.svg" "$OUT/"
cp -f "$CONTENT/logo.svg" "$OUT/"
