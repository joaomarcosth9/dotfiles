#!/usr/bin/env python3
import os
import shlex
import json
import subprocess
import sys
from typing import List, Tuple

HTTP_CMD = os.environ.get("CURL_PROXY_HTTP", "http")
REAL_CURL = os.environ.get("CURL_PROXY_REAL", "curl")
DRY_FLAG = "--curlproxy-dry-run"
LOG_PREFIX = "--curlproxy-log="


def q(x: str) -> str:
    return shlex.quote(x)


def maybe_json(text: str):
    try:
        return json.loads(text)
    except Exception:
        return None


def parse(argv: List[str]) -> Tuple[List[str], bool, str]:
    method = "GET"
    follow = False
    url = None
    headers: List[tuple[str, str]] = []
    data_chunks: List[str] = []
    form_fields: List[str] = []
    files_mode = False
    auth_basic = None
    cookies: List[str] = []
    verify = True
    compressed = False
    output_file = None

    i = 0
    while i < len(argv):
        arg = argv[i]

        if arg in ("-L", "--location"):
            follow = True
            i += 1; continue

        if arg in ("-X", "--request"):
            method = argv[i + 1].upper()
            i += 2; continue

        if arg.startswith("http://") or arg.startswith("https://"):
            url = arg; i += 1; continue
        if arg == "--url":
            url = argv[i + 1]; i += 2; continue

        if not arg.startswith("-") and url is None:
            url = "http://" + arg
            i += 1; continue

        if arg in ("-H", "--header"):
            k, _, v = argv[i + 1].partition(":")
            headers.append((k.strip(), v.strip()))
            i += 2; continue

        if arg in ("-d", "--data", "--data-raw", "--data-binary", "--data-ascii"):
            data_chunks.append(argv[i + 1])
            i += 2; continue

        if arg in ("-F", "--form"):
            files_mode = True
            form_fields.append(argv[i + 1])
            i += 2; continue

        if arg in ("-u", "--user"):
            auth_basic = argv[i + 1]
            i += 2; continue

        if arg in ("-b", "--cookie"):
            cookies.append(argv[i + 1])
            i += 2; continue

        if arg in ("-k", "--insecure"):
            verify = False; i += 1; continue

        if arg == "--compressed":
            compressed = True; i += 1; continue

        if arg in ("-o", "--output"):
            output_file = argv[i + 1]
            i += 2; continue

        if arg.startswith("-") and not arg.startswith(LOG_PREFIX) and arg != DRY_FLAG:
            return [], True, None

        i += 1

    if not url:
        return [], True, None

    if method == "GET" and (data_chunks or files_mode):
        method = "POST"

    cmd: List[str] = [HTTP_CMD]
    if not verify:
        cmd.append("--verify=no")

    if follow:
        cmd.append("--follow")

    cmd.append(method)
    cmd.append(url)

    for k, v in headers:
        cmd.append(f"{k}:{v}")
    if compressed:
        cmd.append("Accept-Encoding:gzip,deflate")

    if cookies:
        cmd.append(f"Cookie:{'; '.join(cookies)}")

    if auth_basic:
        cmd.extend(["--auth", auth_basic])

    if files_mode:
        cmd.extend(form_fields)
    elif data_chunks:
        body = "&".join(data_chunks) if len(data_chunks) > 1 else data_chunks[0]
        if body.startswith("@"):
            cmd.append(body)
        else:
            stripped = body.strip()
            parsed = maybe_json(stripped) if stripped.startswith("{") else None
            if parsed is not None:
                for k, v in parsed.items():
                    if isinstance(v, str):
                        cmd.append(f"{k}={v}")
                    else:
                        cmd.append(f"{k}:={json.dumps(v)}")
            else:
                cmd.extend(["--raw", body])

    return cmd, False, output_file


def launch_real_curl(args: List[str]):
    os.execvp(REAL_CURL, [REAL_CURL] + args)


def main():
    argv = sys.argv[1:]
    if argv and argv[0] == "curl":
        argv = argv[1:]

    dry = DRY_FLAG in argv
    if dry:
        argv.remove(DRY_FLAG)

    log_file = None
    for arg in argv:
        if arg.startswith(LOG_PREFIX):
            log_file = arg[len(LOG_PREFIX):]
            argv.remove(arg)
            break

    http_cmd, fallback, output_file = parse(argv)

    if fallback or not http_cmd:
        launch_real_curl(argv)
        return

    printable = " ".join(q(x) for x in http_cmd)
    print("[!] Interceptando curl → httpie\n→", printable)
    print()

    if log_file:
        with open(log_file, "a") as f:
            f.write(printable + "\n")

    if dry:
        return

    if output_file:
        with open(output_file, "w") as f:
            subprocess.run(http_cmd, stdout=f)
    else:
        subprocess.run(http_cmd)


if __name__ == "__main__":
    main()
