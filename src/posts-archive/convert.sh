#!/usr/bin/env bash

set -e

f=${1:?Please specify a file path.}
f_noext="${f%.*}"

asciidoc \
  -b docbook \
  -a leveloffset=+1 \
  "$f"

iconv -t utf-8 "${f_noext}.xml" \
  | pandoc \
    -f docbook \
    -t markdown_strict \
    --wrap=none \
  | iconv -f utf-8 > "${f_noext}.md"

rm "${f_noext}.xml"
