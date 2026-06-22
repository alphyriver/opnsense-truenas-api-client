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

## Releasing

A push to `main` runs **release-please**, which maintains a single release PR
(`chore: release main`). Merging that PR creates the `vX.Y.Z` tag, which triggers
`release.yml` to build + sign the package, publish the GitHub Release, and update
the GitHub Pages feed.

**Merge the release PR with a merge commit, not squash.** Squash-merging causes a
known release-please deadlock: the squash lands the manifest/version bump on
`main` before release-please tags it, so the next run reads the new version as
"already released" and never cuts the tag — leaving a merged-but-untagged release
PR and no GitHub Release.

If it happens anyway (release PR merged, but no tag/release appears), recover by
tagging the merge commit yourself — `release.yml` does the rest:

```sh
# SHA = the merge commit of the release PR; X.Y.Z = the version it released
gh api -X POST repos/<owner>/<repo>/git/refs \
  -f ref=refs/tags/vX.Y.Z -f sha=<merge-commit-sha>

# reconcile release-please bookkeeping so future runs don't keep aborting
gh pr edit <pr-number> \
  --add-label "autorelease: tagged" --remove-label "autorelease: pending"
```
