# Release & package feed

Releases are cut by [`.github/workflows/release.yml`](../../.github/workflows/release.yml)
when a `v*` tag is pushed. The workflow builds the OPNsense package on FreeBSD,
(re)generates an **RSA-signed pkg repository**, publishes it to **GitHub Pages**
(`gh-pages` branch), and creates a **GitHub Release** with the `.pkg` attached.

## Files here

| File | Purpose |
|------|---------|
| `truenas-api-client.pub` | Public half of the repo signing key. **Committed.** Pinned on nodes as `/usr/local/etc/pkg/keys/truenas-api-client.pub`. |
| `truenas-api-client.conf.in` | OPNsense repo conf template. CI substitutes `@PAGES_URL@` and publishes the result at `<pages-url>/truenas-api-client.conf`. |
| `index.html.in` | Landing page template for the Pages root. |

The private signing key is **never** committed — it lives only in the
`PKG_SIGNING_KEY` repository secret.

## One-time setup

1. **Signing key.** Generate an RSA keypair and keep the private key safe:
   ```sh
   openssl genrsa -out tnac-pkg-signing.key 4096
   openssl rsa -in tnac-pkg-signing.key -pubout -out deploy/repo/truenas-api-client.pub
   ```
   Commit `deploy/repo/truenas-api-client.pub`; add the **private** key as the
   `PKG_SIGNING_KEY` Actions secret (Settings → Secrets and variables → Actions).
   To rotate, replace both and re-publish the public key to every node.

2. **GitHub Pages.** Settings → Pages → Source: **Deploy from a branch** →
   `gh-pages` / `root`. (The branch is created by the first release.)

## Cutting a release

Versioning is automated by **release-please** (`.github/workflows/release-please.yml`).
You do not bump the version by hand.

1. **Merge feature PRs** to `main` using Conventional Commits (`feat:`, `fix:`,
   `feat!:` …). release-please keeps a **release PR** open that bumps
   `version.txt` + the `Makefile` `PLUGIN_VERSION` (via the
   `x-release-please-version` marker) and updates `CHANGELOG.md`.
2. **Merge the release PR** when ready. release-please creates the `vX.Y.Z` tag,
   which triggers `release.yml` to build + sign + publish (steps below).

> **Triggering the signed build.** A release tag created by release-please with
> the default `GITHUB_TOKEN` does **not** auto-trigger `release.yml` (GitHub
> loop-prevention). After merging the release PR, either set a
> `RELEASE_PLEASE_TOKEN` PAT (contents + PR write) for fully hands-off
> tag→build, or run it by hand against the tag:
> ```sh
> gh workflow run release.yml --ref vX.Y.Z
> ```

On a `vX.Y.Z` tag, `release.yml` verifies the tag matches `PLUGIN_VERSION`, then:

1. builds the clean `os-truenas-api-client-X.Y.Z.pkg` (`make PLUGIN_DEVEL=`),
2. adds it to `gh-pages:/<ABI>/` and re-signs the catalogue over **all** versions
   (older releases stay installable for upgrades),
3. publishes `truenas-api-client.conf` + `pkg-repo.pub` + a landing page at the
   Pages root,
4. attaches the `.pkg` to a GitHub Release with notes from `CHANGELOG.md`.

A prerelease tag (e.g. `v0.2.0-rc.1`) builds + signs + ships a **GitHub
pre-release** for firewall validation but does **not** touch the live feed.

## Notes

- The feed directory is keyed by pkg ABI (e.g. `FreeBSD:14:amd64`). Bump the
  `ABI`/`release` values in the workflow when targeting a new FreeBSD base.
- The repo conf uses `signature_type: pubkey`; a node only trusts packages whose
  catalogue verifies against the pinned `truenas-api-client.pub`.
