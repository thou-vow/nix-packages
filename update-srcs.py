import json
import os
import re
import subprocess
import sys
from functools import partial
from typing import Any, Callable, Dict
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def fetch_json(url: str, headers: Dict[str, str] = {}) -> Any:
    with urlopen(Request(url, headers=headers)) as r:
        return json.load(r)


def reachable(url: str) -> bool:
    try:
        with urlopen(Request(url, method="HEAD")):
            return True
    except (HTTPError, URLError):
        return False


def nurl_args(url: str, fetcher: str | None = None) -> Dict[str, Any]:
    cmd = ["nurl", "-j", url] + (["--fetcher", fetcher] if fetcher else [])
    return json.loads(subprocess.check_output(cmd))["args"]


def github_latest_url(repo: str, template: str) -> str:
    headers = {}
    if token := os.getenv("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    tag = fetch_json(f"https://api.github.com/repos/{repo}/releases/latest", headers)[
        "tag_name"
    ]
    return template.format(version=tag.lstrip("v"))


def graalvm_bump_url(url: str) -> str:
    def inc_patch(m: re.Match) -> str:
        return f"{m.group(1)}{int(m.group(2)) + 1}{m.group(3)}"

    bumped = re.sub(
        r"(graalvm-jdk-\d+\.\d+\.)(\d+)(_linux-[a-z0-9]+_bin\.tar\.gz)", inc_patch, url
    )
    return bumped if bumped != url and reachable(bumped) else url


def main():
    try:
        current = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit("Error: Could not decode JSON from stdin.")

    fetchurl = partial(nurl_args, fetcher="fetchurl")

    def brave_url(template: str) -> str:
        base = "https://github.com/brave/brave-browser/releases/download/v{version}"
        return github_latest_url("brave/brave-browser", f"{base}/{template}")

    config: Dict[str, Dict[str, tuple[Callable, Callable]]] = {
        "brave": {
            "x86_64-linux": (
                lambda: brave_url("brave-browser_{version}_amd64.deb"),
                fetchurl,
            ),
        },
        "graalvm-oracle_21": {
            "x86_64-linux": (
                lambda: graalvm_bump_url(
                    current["graalvm-oracle_21"]["x86_64-linux"]["url"]
                ),
                nurl_args,
            ),
            "aarch64-linux": (
                lambda: graalvm_bump_url(
                    current["graalvm-oracle_21"]["aarch64-linux"]["url"]
                ),
                nurl_args,
            ),
        },
        "graalvm-oracle_25": {
            "x86_64-linux": (
                lambda: graalvm_bump_url(
                    current["graalvm-oracle_25"]["x86_64-linux"]["url"]
                ),
                nurl_args,
            ),
            "aarch64-linux": (
                lambda: graalvm_bump_url(
                    current["graalvm-oracle_25"]["aarch64-linux"]["url"]
                ),
                nurl_args,
            ),
        },
    }

    print("Generating nix fetcher specs. This might take a moment...", file=sys.stderr)
    out = {}
    for name, archs in config.items():
        out[name] = {}
        for arch, (resolve, fetch) in archs.items():
            url = resolve()
            src = current.get(name, {}).get(arch, {})
            if src.get("url") == url:
                print(f"[{name}:{arch}] unchanged, reusing hash.", file=sys.stderr)
                out[name][arch] = src
            else:
                print(f"[{name}:{arch}] updated, fetching hash...", file=sys.stderr)
                out[name][arch] = fetch(url)

    print(json.dumps(out, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
