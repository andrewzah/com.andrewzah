#!/usr/bin/env bash

set -e

words_str=$(rg -N --no-filename tags: "./content/posts" |
  sort |
  sed 's#^tags:##' |
  tr -d '[,"]' |
  paste -s -d' ')

declare -A words
IFS=" "
for w in $words_str; do
  words+=([$w]="")
done

echo "${!words[@]}"
