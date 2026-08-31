# Changelog

## [0.1.2](https://github.com/alphyriver/opnsense-truenas-api-client/compare/v0.1.1...v0.1.2) (2026-08-31)


### Bug Fixes

* **ci:** build and publish the package for every supported pkg ABI ([2c336e5](https://github.com/alphyriver/opnsense-truenas-api-client/commit/2c336e54b912e9086b3640fe6092dff4ee4c2b98))
* **ci:** build and publish the package for every supported pkg ABI ([82fa90a](https://github.com/alphyriver/opnsense-truenas-api-client/commit/82fa90a44142a3cae62aed84a4f0a4592dfb76f0))
* **ci:** parse the package ABI on the first colon only ([5f00e60](https://github.com/alphyriver/opnsense-truenas-api-client/commit/5f00e607badedf76fbad9cac8fd08df97b5e3787))
* **ci:** parse the package ABI on the first colon only ([456357a](https://github.com/alphyriver/opnsense-truenas-api-client/commit/456357a809a105cfb2ee866e074c5b3a9af8d69c))
* **release-please:** set group-pull-request-title-pattern to include version ([851c428](https://github.com/alphyriver/opnsense-truenas-api-client/commit/851c4289881ee6f8b93a0ea2b86266636720c38a))
* **release-please:** set group-pull-request-title-pattern to include version ([95d5e5a](https://github.com/alphyriver/opnsense-truenas-api-client/commit/95d5e5ad6238063e549f73e2944782b0229998f9))


### Miscellaneous Chores

* release 0.1.2 ([5fa3c9f](https://github.com/alphyriver/opnsense-truenas-api-client/commit/5fa3c9f8e58bb47b7d4680a3ef4f6f0bbe1b5f4e))

## [0.1.1](https://github.com/alphyriver/opnsense-truenas-api-client/compare/v0.1.0...v0.1.1) (2026-07-11)


### Bug Fixes

* **vendor-update:** preserve release/ branch prefix when cloning target ref ([11c0d7d](https://github.com/alphyriver/opnsense-truenas-api-client/commit/11c0d7dd6ba97ce4124361dfc57f88a489a26dd9))
* **vendor-update:** preserve release/ branch prefix when cloning target ref ([5eaa6df](https://github.com/alphyriver/opnsense-truenas-api-client/commit/5eaa6df176892ec7b32ef2414f8f181c0d840676))

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
