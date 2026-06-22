# Security

`midclt` and the vendored `truenas_api_client` run **as root on the firewall**
and talk to TrueNAS over the network, so the trust surface is treated
conservatively. This note records the posture and the one operator-facing
requirement (how to pass credentials).

## Threat model

The client is invoked by the `os-acme-client` `truenas_ws` deploy hook to push
certificates to TrueNAS over `wss://`. The relevant adversaries are:

- a **network peer / MITM** on the path to TrueNAS (mitigated by TLS + no
  network-reachable deserialization), and
- an **unprivileged local process** on the firewall that can read other
  processes' command lines via `ps`/`procstat` (mitigated by keeping secrets out
  of argv).

## TLS verification is always on

Both the modern (`__init__.py`) and legacy (`legacy.py`) clients default to
`verify_ssl=True`, and only relax to `ssl.CERT_NONE` when explicitly constructed
with `verify_ssl=False`. The `midclt` entrypoint **never** sets `verify_ssl=False`
and exposes **no** CLI flag to disable it, so every `midclt` connection verifies
the server certificate.

**Operator requirement:** the TrueNAS endpoint must present a certificate your
firewall trusts (a CA in the system trust store, or a pinned/trusted cert). A
self-signed TrueNAS cert that isn't trusted will (correctly) fail the connection
rather than silently downgrading. This ties into the `acme_truenas_ws` setup.

## No pickle deserialization over the network

The client can deserialize a server-supplied `py_exception` via
`pickle.loads` — but only when `py_exceptions=True`. That path is unreachable
over `wss://` here, by two independent controls:

1. **Upstream guard (`uri_check`).** `Client.uri_check()` raises if
   `py_exceptions=True` is requested for any URI that is not a `ws+unix://`
   unix-domain socket — so a remote `wss://` connection can never enable pickle.
2. **Entrypoint default.** `midclt`/`main()` construct the client with the
   default `py_exceptions=False` and expose **no** flag to turn it on. A network
   peer therefore cannot induce a `pickle.loads` on the firewall.

The vendored package is kept **byte-for-byte upstream** (verified by
`vendor-lock.json`); the protections above are upstream's own guard plus our
entrypoint's safe defaults, not a fork.

## Credentials: environment, not argv

A secret passed on the command line (`-K/--api-key`, `-P/--password`) is visible
to any local user through `ps`/`procstat`, because the kernel retains the argv a
process was exec'd with.

`midclt` therefore reads credentials from the environment and splices them into
argv **in-process** (mutating `sys.argv` does not rewrite the saved kernel
cmdline), so the secret reaches the parser without appearing in `ps`:

| Env var | Equivalent flag |
|---------|-----------------|
| `MIDCLT_API_KEY` | `-K` / `--api-key` |
| `MIDCLT_PASSWORD` | `-P` / `--password` |

If a secret is *also* given on the command line, the argv value is left in place
and `midclt` warns on stderr that it is exposed.

**Recommended invocation** (e.g. from the deploy hook / a manual test):

```sh
MIDCLT_API_KEY="<api-key>" midclt --uri wss://<truenas-ip>/websocket call system.ready
```

**Caveat — upstream acme.sh hook.** The stock acme.sh `truenas_ws` deploy hook
constructs its own `midclt` command line and may place the API key on argv. On a
single-tenant firewall the residual exposure is to local root only; to eliminate
it, invoke the hook with `MIDCLT_API_KEY` set in its environment and a key value
omitted from argv, so `midclt`'s env path is used. Track this with the
os-acme-client integration.
