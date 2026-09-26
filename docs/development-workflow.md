# Fejlesztési és kiadási folyamat

## Napi fejlesztés

1. Indíts feature branch-et a friss `main` ágról: `git switch -c feature/rovid-leiras`.
2. Módosítsd a kódot, majd helyben futtasd: `npm ci && npm test`.
3. Push-old a branch-et és nyiss pull requestet a `main` felé.
4. A PR-ben a **TypeScript, container and health check** feladatnak zöldnek kell lennie.
5. Merge után a `main` pipeline tesztel, GHCR-be publikál, majd Pi2 stagingre telepít.

A `main` ágon közvetlen fejlesztői push helyett a PR az alapértelmezett tanulási munkamód. A branch-védelem kötelezővé teszi a szinkron, zöld CI állapotot; force push és branch-törlés tiltott.

## Staging megnyitása biztonságosan

A Pi2 szolgáltatás nem nyit LAN/public portot. A saját fejlesztői gépen futtasd:

```bash
./scripts/open-staging-tunnel.sh
```

Ezután a staging a `http://127.0.0.1:3010` címen érhető el, amíg a tunnel fut. Kilépés: `Ctrl+C`.

## Verziózott kiadás

A működő `main` commitból hozz létre annotált `vX.Y.Z` taget és push-old:

```bash
git tag -a v0.1.0 -m "First learning release"
git push origin v0.1.0
```

A tag GitHub Release-t hoz létre automatikus release note-okkal. A staging deploy továbbra is a commit SHA-hoz kötött immutable GHCR image-et használ.
