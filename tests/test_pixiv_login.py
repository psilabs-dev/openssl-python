import os
import sys
from typing import Dict, Optional

import requests


PIXIV_BASE = "https://www.pixiv.net"


def parse_pixiv_cookie(env_value: str) -> Dict[str, str]:
    """
    Parse PIXIV_COOKIE into a cookie dict suitable for requests.
    Accepts either:
    - raw PHPSESSID value
    - "PHPSESSID=xxxxx"
    - a semicolon-separated cookie header line (e.g., "PHPSESSID=...; device_token=...")
    - a "Cookie: ..." header string (prefix will be stripped)
    """
    value = env_value.strip()
    if not value:
        return {}

    # Strip optional "Cookie:" prefix
    if value.lower().startswith("cookie:"):
        value = value.split(":", 1)[1].strip()

    # If value contains '=' then treat as header-form; else assume it's raw PHPSESSID value
    if "=" in value:
        cookie_pairs = [segment.strip() for segment in value.split(";") if segment.strip()]
        cookies: Dict[str, str] = {}
        for pair in cookie_pairs:
            # Ignore attributes like "Path=/" or "HttpOnly" if present (unlikely in env)
            if "=" not in pair:
                continue
            name, val = pair.split("=", 1)
            name = name.strip()
            val = val.strip()
            if not name:
                continue
            cookies[name] = val
        # If only a single key is given but not PHPSESSID, still return it
        return cookies

    # Raw PHPSESSID value
    return {"PHPSESSID": value}


def build_session(cookies: Dict[str, str]) -> requests.Session:
    # Mirror LRR defaults
    session = requests.Session()
    session.headers.clear()
    session.headers.update({
        "User-Agent": "Mozilla/5.0",
        "Accept-Encoding": "gzip",
    })
    # Attach cookies
    for name, val in cookies.items():
        cookie = requests.cookies.create_cookie(name=name, value=val, domain="pixiv.net", path="/")
        session.cookies.set_cookie(cookie)
    return session


def get_self_user_id(session: requests.Session) -> Optional[str]:
    # Returns userId if logged in, otherwise None
    url = PIXIV_BASE + "/ajax/user/self/status"
    resp = session.get(url, headers={"Referer": PIXIV_BASE}, timeout=10, allow_redirects=False)
    resp.raise_for_status()
    data = resp.json()
    if data.get("error"):
        return None
    body = data.get("body") or {}
    user_id = body.get("userId") or body.get("id")
    if user_id:
        return str(user_id)
    return None


def get_username_by_user_id(session: requests.Session, user_id: str) -> Optional[str]:
    # Fetch public user info; name is under body.name
    url = PIXIV_BASE + f"/ajax/user/{user_id}"
    resp = session.get(url, headers={"Referer": PIXIV_BASE}, timeout=10, allow_redirects=False)
    resp.raise_for_status()
    data = resp.json()
    if data.get("error"):
        return None
    body = data.get("body") or {}
    # Some responses use body['name'], others nest under body['user']['name']
    name = body.get("name")
    if not name:
        user_obj = body.get("user") or {}
        name = user_obj.get("name")
    return name


def main() -> int:
    cookie_env = os.getenv("PIXIV_COOKIE", "").strip()
    if not cookie_env:
        print("PIXIV_COOKIE is not set.", file=sys.stderr)
        print("Provide your Pixiv PHPSESSID, e.g.:", file=sys.stderr)
        print('  export PIXIV_COOKIE="PHPSESSID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"', file=sys.stderr)
        return 2

    cookies = parse_pixiv_cookie(cookie_env)
    if not cookies.get("PHPSESSID"):
        print("Warning: PHPSESSID not found in PIXIV_COOKIE. Proceeding with provided cookies.", file=sys.stderr)

    session = build_session(cookies)

    # First request to establish session; let exceptions raise for full tracebacks
    home = session.get(PIXIV_BASE + "/", timeout=10, allow_redirects=False)
    home.raise_for_status()

    user_id = get_self_user_id(session)
    if not user_id:
        print("Failed to obtain userId from /ajax/user/self/status.", file=sys.stderr)
        print("This usually means the cookie is invalid or not logged in.", file=sys.stderr)
        print(f"Home status: {home.status_code}", file=sys.stderr)
        return 6

    username = get_username_by_user_id(session, user_id)
    if not username:
        print(f"Logged in as userId={user_id}, but failed to obtain username.", file=sys.stderr)
        return 7

    print(f"Pixiv login successful. userId={user_id}, username={username}")
    return 0


if __name__ == "__main__":
    sys.exit(main())


