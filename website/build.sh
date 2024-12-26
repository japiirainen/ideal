#!/usr/bin/env bash
set -e
WDIR="$(mktemp -d)"
trap 'rm -rf -- "$WDIR"' EXIT

if [ $# -eq 0 ]; then
    echo "Building for dev"
    dev_mode=true
else
    echo "Building for prod"
    dev_mode=false
fi

git rev-parse HEAD > .commitrev

wasm32-wasi-cabal build
wasm32-wasi-cabal list-bin exe:website
WEBSITE_WASM="$(wasm32-wasi-cabal list-bin exe:website)"

"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs \
  --input "$WEBSITE_WASM" --output "www/ghc_wasm_jsffi.js"

if $dev_mode; then
    WEBSITE_WASM_FINAL="$WEBSITE_WASM"
else
    wizer \
        --allow-wasi --wasm-bulk-memory true --init-func _initialize \
        "$WEBSITE_WASM" -o "$WDIR/website-init.wasm"
    WEBSITE_WASM_FINAL="$WDIR/website-opt.wasm"
    wasm-opt "$WDIR/website-init.wasm" -o "$WEBSITE_WASM_FINAL" -Oz
    wasm-strip "$WEBSITE_WASM_FINAL"
fi

rm -rf dist
mkdir -p dist
cp "$WEBSITE_WASM_FINAL" dist/website.wasm

wasmedge --dir /:. "$(wasm32-wasi-cabal list-bin exe:pregen)" \
         www/jsaddle.js dist/index.html

esbuild_args=(--platform=node --format=esm)
[[ $dev_mode == false ]] && esbuild_args+=(--minify)
esbuild www/{index,worker}.js --outdir=dist --bundle "${esbuild_args[@]}"
esbuild www/jsaddle.js --outdir=dist "${esbuild_args[@]}"
