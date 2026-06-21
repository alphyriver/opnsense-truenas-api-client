# os-truenas-api-client

An OPNsense plugin that vendors the **TrueNAS WebSocket API client** —
`midclt` and the pure-Python `truenas_api_client` package (plus its
`websocket-client` dependency) — onto the firewall, so the stock
[`os-acme-client`](https://github.com/opnsense/plugins/tree/master/security/acme-client)
**`truenas_ws`** deploy hook can push ACME/Let's Encrypt certificates to a
TrueNAS server over its WebSocket API.

## Why this exists

`os-acme-client`'s "Upload certificate to TrueNAS Server (Websocket API)"
action runs the upstream acme.sh `truenas_ws` deploy hook, which shells out to
`midclt` and imports `truenas_api_client` in Python. Those ship with TrueNAS but
are **absent on OPNsense** and are **not in the OPNsense/FreeBSD pkg repo**. The
hook also calls `/usr/bin/env python`, but OPNsense provides only `python3`.

This plugin closes all three gaps:

| Provides | Path |
|----------|------|
| `truenas_api_client` (pure Python) | `/usr/local/lib/python3.13/site-packages/truenas_api_client/` |
| `websocket-client` (its only dependency, pure Python) | `/usr/local/lib/python3.13/site-packages/websocket/` |
| `midclt` console wrapper | `/usr/local/bin/midclt` |
| guarded `python` → `python3` shim | `/usr/local/bin/python` (created in post-install only if absent) |

Everything is pure Python — no compiled or Linux-only components.

## Install

This repo publishes a **signed FreeBSD pkg feed via GitHub Pages**. On the
firewall (as root):

```sh
fetch -o /usr/local/etc/pkg/repos/truenas-api-client.conf \
  https://alphyriver.github.io/opnsense-truenas-api-client/truenas-api-client.conf
fetch -o /usr/local/etc/pkg/keys/truenas-api-client.pub \
  https://alphyriver.github.io/opnsense-truenas-api-client/pkg-repo.pub
pkg update
pkg install os-truenas-api-client
```

Then point the `os-acme-client` TrueNAS action at `type: acme_truenas_ws`,
hostname = the TrueNAS IP, protocol = `wss`, and a valid TrueNAS API key.

Verify:

```sh
command -v midclt
python3 -c "import truenas_api_client, websocket; print('ok')"
midclt --uri wss://<truenas-ip>/websocket -K <api-key> call system.ready
```

## Provenance & updates

The vendored sources are **byte-exact** copies pinned in
[`vendor-lock.json`](vendor-lock.json) with per-file sha256 sums, matching the
copies shipping on **TrueNAS SCALE 25.10.4**:

- `truenas_api_client` — [truenas/api_client](https://github.com/truenas/api_client) `release/25.10.4`
- `websocket-client` — [websocket-client](https://github.com/websocket-client/websocket-client) `v1.8.0`

`scripts/vendor-update.sh` (run weekly by `.github/workflows/vendor-update.yml`)
re-vendors within the safe series and opens a PR for review. Upstream licenses
are kept under [`docs/vendor-licenses/`](docs/vendor-licenses/).

## Releases

Fully automated via **release-please** → tag → **build + sign + publish**. See
[`deploy/repo/README.md`](deploy/repo/README.md) for the release flow, signing
key setup, and GitHub Pages configuration.

## Build locally

```sh
git clone --depth 1 https://github.com/opnsense/plugins.git
cp -r . plugins/devel/truenas-api-client
cd plugins/devel/truenas-api-client
make package      # -> work/pkg/os-truenas-api-client-*.pkg
```

## License

Plugin scaffolding is MIT (see [`LICENSE`](LICENSE)). Vendored third-party code
retains its upstream license: `truenas_api_client` (LGPL-3.0) and
`websocket-client` (Apache-2.0); copies under `docs/vendor-licenses/`.
