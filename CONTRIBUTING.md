# Contributing

## Commit messages

This repo uses [Conventional Commits](https://www.conventionalcommits.org/) so
that **release-please** can compute versions and the changelog automatically:

- `feat:` … a new capability (minor bump pre-1.0 → patch)
- `fix:` … a bug fix
- `chore(deps):` … vendored-dependency bumps
- `feat!:` / `BREAKING CHANGE:` … breaking change (major bump)

Do **not** edit `version.txt`, the `Makefile` `PLUGIN_VERSION`, or
`CHANGELOG.md` by hand — release-please owns them.

## Vendored code

`src/usr/local/lib/python3.13/site-packages/{truenas_api_client,websocket}` is
**vendored verbatim** from the upstreams pinned in `vendor-lock.json`. Don't
hand-edit it. To update, run `sh scripts/vendor-update.sh` (or let the weekly
`vendor-update` workflow open the PR), then review the diff and the regenerated
sha256 sums.

## Before opening a PR

```sh
# checksums + import smoke test (the build.yml `verify` job)
SP=src/usr/local/lib/python3.13/site-packages
python3 -m compileall -q "$SP"
PYTHONPATH="$SP" python3 -c "import truenas_api_client, websocket; print('ok')"
```

CI also builds the real `.pkg` on FreeBSD. See `deploy/repo/README.md` for the
release/signing process.
