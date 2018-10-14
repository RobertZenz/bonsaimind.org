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

# Create the needed style file.
styleFile="$OUT/index.css"

# Create the css file to be included in the header.
echo -n "<style>" > "$OUT/index.css"
cat "$TEMPLATES/index.css" \
	| tr --delete "\n\t" \
	| sed --regexp-extended "s/ ?([:,>{]) ?/\1/g" \
	>> "$OUT/index.css"
echo -n "</style>" >> "$OUT/index.css"

# Run Pandoc.
$TOOLCHAIN/pandoc-linux-x64 \
	--from=markdown-smart+ascii_identifiers \
	--to=html \
	--output="$OUT/index.html" \
	--eol=lf \
	--template="$TEMPLATES/index.html" \
	--lua-filter="$TOOLCHAIN/filter.lua" \
	--include-in-header="$OUT/index.css" \
	--variable="DATE:$(date +%Y-%m-%d\ %H:%M:%S\ %::z)" \
	--variable="GIT_REPO:https://gitlab.com/RobertZenz/bonsaimind.org" \
	--variable="GIT_COMMIT:$(git rev-parse HEAD 2> /dev/null)" \
	"$CONTENT/index.markdown"

# Cleanup
rm "$OUT/index.css"

# Copy the resource files.
cp -f "$CONTENT/avatar.png" "$OUT/"
cp -f "$CONTENT/icons.svg" "$OUT/"
cp -f "$CONTENT/logo.svg" "$OUT/"
