#!/usr/bin/env bash

export LANG="C.UTF-8"

export dirs="src bin website/app website/src"

# shellcheck disable=SC2046,SC2086
ormolu -m inplace $(find $dirs -type f -name "*.hs" -o -name "*.hs-boot")

cabal-fmt --inplace ideal.cabal website/website.cabal
