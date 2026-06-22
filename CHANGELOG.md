# Changelog

## 0.1.0 (2026-06-22)


### Features

* vendor TrueNAS WebSocket API client for os-acme-client truenas_ws ([04f1c62](https://github.com/alphyriver/opnsense-truenas-api-client/commit/04f1c627c3760e2b2c52c1400e3722038ca37954))


### Bug Fixes

* support FreeBSD platform string in vendored truenas_api_client ([dbb7ea3](https://github.com/alphyriver/opnsense-truenas-api-client/commit/dbb7ea3aec5445076a9302dedf3b7129d052deae))


### Miscellaneous Chores

* release 0.1.0 ([825cbe7](https://github.com/alphyriver/opnsense-truenas-api-client/commit/825cbe79981d2350aab99765372e36c9b6848f7e))

## 0.1.0 (unreleased)

### Features

* Initial release. Vendors `truenas_api_client` (TrueNAS 25.10.4 build) and
  `websocket-client` v1.8.0, a `midclt` console wrapper, and a guarded
  `python` → `python3` shim, so the `os-acme-client` `truenas_ws` deploy hook
  works on OPNsense.
* Signed FreeBSD pkg feed published via GitHub Pages; automated releases via
  release-please.
