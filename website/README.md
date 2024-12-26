# interactive website for `ideal`

## Local development

```sh
pnpm i
```

```sh
wasm32-wasi-cabal update
```

```sh
watch
```

```sh
serve
```

and view the site at http://127.0.0.1:8080/index.html.

## Building for deployment

```sh
pnpm i
wasm32-wasi-cabal update
./build.sh prod
```
