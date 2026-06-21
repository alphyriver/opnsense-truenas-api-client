#!/bin/sh
# Re-vendor the pinned Python packages described in vendor-lock.json into
# src/usr/local/lib/python3.13/site-packages, tracking upstream within a safe
# series (truenas_api_client stays on the deployed TrueNAS minor, e.g. 25.10.*;
# websocket-client stays on its current major). Recomputes sha256 sums and
# rewrites vendor-lock.json. Leaves all changes in the working tree for review.
#
# Usage: sh scripts/vendor-update.sh
# Requires: git, python3, sha256sum.
set -eu

cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

python3 - <<'PY'
import json, os, re, shutil, subprocess, hashlib, tempfile, pathlib

ROOT = pathlib.Path.cwd()
LOCK = ROOT / "vendor-lock.json"
lock = json.loads(LOCK.read_text())
SP = ROOT / "src" / lock["python_site"]

def run(*a):
    return subprocess.run(a, check=True, capture_output=True, text=True).stdout

def ver_tuple(s):
    return tuple(int(x) for x in re.findall(r"\d+", s))

def ls_remote(repo, kind, pattern):
    # kind: 'heads' or 'tags'
    out = run("git", "ls-remote", f"--{kind}", repo, pattern)
    refs = {}
    for line in out.splitlines():
        sha, ref = line.split("\t")
        name = ref.rsplit("/", 1)[-1]
        refs[name] = sha
    return refs

def sha256(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

tnac_version = lock["version"]

for pkg, meta in lock["packages"].items():
    repo = meta["repo"]
    cur_ref = meta["ref"]
    subdir = meta["subdir"]
    excludes = set(meta.get("exclude", []))

    # Determine the newest ref within the safe series.
    if cur_ref.startswith("release/"):              # truenas_api_client
        series = cur_ref.rsplit(".", 1)[0] + ".*"   # release/25.10.*
        refs = ls_remote(repo, "heads", series)
        best = max(refs, key=lambda n: ver_tuple(n))
        target_ref, target_sha, kind = best, refs[best], "heads"
        tnac_version = best.split("/", 1)[-1]
    else:                                           # websocket-client (tag vX.*)
        major = cur_ref.split(".", 1)[0] + ".*"     # v1.*
        refs = ls_remote(repo, "tags", major)
        refs = {n: s for n, s in refs.items() if not n.endswith("^{}")}
        best = max(refs, key=lambda n: ver_tuple(n))
        target_ref, target_sha, kind = best, refs[best], "tags"

    print(f"[{pkg}] locked={cur_ref} target={target_ref}")

    with tempfile.TemporaryDirectory() as td:
        run("git", "clone", "--depth", "1", "--branch", target_ref, repo, td)
        head = run("git", "-C", td, "rev-parse", "HEAD").strip()
        srcdir = pathlib.Path(td) / subdir
        destdir = SP / pkg
        shutil.rmtree(destdir, ignore_errors=True)
        destdir.mkdir(parents=True, exist_ok=True)
        files = {}
        for p in sorted(srcdir.iterdir()):
            if p.name in excludes or p.name == "__pycache__":
                continue
            if p.is_dir():
                continue
            if p.suffix == ".py" or p.name == "py.typed":
                shutil.copy2(p, destdir / p.name)
        # checksums for .py files only (the lock's contract)
        for p in sorted(destdir.glob("*.py")):
            files[p.name] = sha256(p)
        meta["ref"] = target_ref
        meta["commit"] = head
        meta["files"] = files

lock["version"] = tnac_version
LOCK.write_text(json.dumps(lock, indent=2) + "\n")
print(f"vendor-lock.json updated; version={tnac_version}")
PY
