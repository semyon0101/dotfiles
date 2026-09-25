#!/usr/bin/env python3
import base64
import sys
import urllib.parse
import urllib.request

import yaml

RESERVED_NAMES = {"DIRECT", "REJECT", "GLOBAL", "COMPATIBLE", "PASS"}


def fetch_subscription(url: str) -> str:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
        },
    )
    with urllib.request.urlopen(req, timeout=15) as response:
        content = response.read().strip()

    padding = len(content) % 4
    if padding:
        content += b"=" * (4 - padding)

    try:
        return base64.b64decode(content).decode("utf-8", errors="ignore")
    except Exception:
        return content.decode("utf-8", errors="ignore")


def parse_vless(uri: str) -> dict:
    parsed = urllib.parse.urlparse(uri)
    query = urllib.parse.parse_qs(parsed.query)

    raw_name = (
        urllib.parse.unquote(parsed.fragment)
        if parsed.fragment
        else f"vless-{parsed.hostname}"
    )
    name = raw_name.strip()

    if name.upper() in RESERVED_NAMES:
        name = f"NODE-{name}"

    port = 8888
    if parsed.port:
        port = parsed.port

    proxy = {
        "name": name,
        "type": "vless",
        "server": parsed.hostname,
        "port": port,
        "uuid": parsed.username,
        "network": query.get("type", ["tcp"])[0],
        "tls": query.get("security", ["none"])[0] in ["tls", "reality"],
        "udp": True,
    }

    if proxy["tls"]:
        security = query.get("security", [""])[0]
        if security == "reality":
            proxy["reality-opts"] = {
                "public-key": query.get("pbk", [""])[0],
                "short-id": query.get("sid", [""])[0],
            }
        sni = query.get("sni", [""])[0]
        if sni:
            proxy["servername"] = sni

    flow = query.get("flow", [""])[0]
    if flow:
        proxy["flow"] = flow

    network = proxy["network"]
    if network == "ws":
        proxy["ws-opts"] = {
            "path": query.get("path", ["/"])[0],
            "headers": {"Host": query.get("host", [""])[0]},
        }
    elif network == "grpc":
        proxy["grpc-opts"] = {"grpc-service-name": query.get("serviceName", [""])[0]}

    return proxy


def build_clash_config(proxies: list) -> dict:
    proxy_names = [p["name"] for p in proxies]

    return {
        "mode": "rule",
        "dns": {
            "enable": True,
            "listen": "127.0.0.1:1053",
            "ipv6": False,
            "enhanced-mode": "fake-ip",
            "fake-ip-range": "198.18.0.1/16",
            "fake-ip-filter": [
                "+.ru",
                "+yandex.com",
                "+yandex.net",
                "+yastatic.net",
                "+.lan",
                "+.local",
            ],
            "nameserver-policy": {
                "+.ru": "77.88.8.8",
                "+yandex.com": "77.88.8.8",
                "+yandex.net": "77.88.8.8",
                "+yastatic.net": "77.88.8.8",
            },
            "nameserver": [
                "1.1.1.1",
            ],
            "default-nameserver": ["1.1.1.1"],
        },
        "proxies": proxies,
        "proxy-groups": [
            {
                "name": "PROXY",
                "type": "select",
                "proxies": ["AUTO"] + proxy_names,
            },
            {
                "name": "AUTO",
                "type": "url-test",
                "url": "http://www.gstatic.com/generate_204",
                "interval": 300,
                "tolerance": 50,
                "proxies": proxy_names,
            },
        ],
        "rules": [
            "DOMAIN-SUFFIX,ru,DIRECT",
            "DOMAIN-SUFFIX,yandex.com,DIRECT",
            "DOMAIN-SUFFIX,yandex.net,DIRECT",
            "DOMAIN-SUFFIX,yastatic.net,DIRECT",
            "MATCH,PROXY",
        ],
    }


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <subscription_url> <output_file.yaml>")
        sys.exit(1)

    url = sys.argv[1]
    output_path = sys.argv[2]

    raw_text = fetch_subscription(url)
    lines = [
        line.strip()
        for line in raw_text.splitlines()
        if line.strip().startswith("vless://")
    ]

    if not lines:
        print(
            "Error: No valid vless:// links found in decoded subscription payload.",
            file=sys.stderr,
        )
        sys.exit(1)

    seen_names = set()
    proxies = []

    for line in lines:
        try:
            proxy = parse_vless(line)
            orig_name = proxy["name"]
            counter = 1
            while proxy["name"] in seen_names:
                proxy["name"] = f"{orig_name}-{counter}"
                counter += 1
            seen_names.add(proxy["name"])
            proxies.append(proxy)
        except Exception as e:
            print(f"Warning: Failed to parse line '{line}': {e}", file=sys.stderr)

    config = build_clash_config(proxies)

    with open(output_path, "w", encoding="utf-8") as f:
        yaml.dump(config, f, allow_unicode=True, sort_keys=False)

    print(f"Successfully generated {output_path} with {len(proxies)} proxies.")


if __name__ == "__main__":
    main()
