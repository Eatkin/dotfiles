#!/usr/bin/env python3
import json
import os
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer

CONFIG_DIR = os.path.expanduser("~/.config/youtube")
CLIENT_SECRET = f"{CONFIG_DIR}/client_secret.json"
REFRESH_TOKEN_FILE = f"{CONFIG_DIR}/refresh_token"
SCOPE = "https://www.googleapis.com/auth/youtube.readonly"
REDIRECT_URI = "http://localhost:8080"

with open(CLIENT_SECRET) as f:
    creds = json.load(f)["installed"]

client_id = creds["client_id"]
client_secret = creds["client_secret"]

auth_url = "https://accounts.google.com/o/oauth2/auth?" + urllib.parse.urlencode(
    {
        "client_id": client_id,
        "redirect_uri": REDIRECT_URI,
        "response_type": "code",
        "scope": SCOPE,
        "access_type": "offline",
        "prompt": "consent",
    }
)

auth_code = None


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        global auth_code
        auth_code = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)[
            "code"
        ][0]
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"auth done, you can close this tab")


print("opening browser for auth...")
webbrowser.open(auth_url)
HTTPServer(("localhost", 8080), Handler).handle_request()

token_data = urllib.parse.urlencode(
    {
        "code": auth_code,
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uri": REDIRECT_URI,
        "grant_type": "authorization_code",
    }
).encode()

req = urllib.request.urlopen(
    urllib.request.Request(
        "https://oauth2.googleapis.com/token", data=token_data, method="POST"
    )
)
tokens = json.load(req)

with open(REFRESH_TOKEN_FILE, "w") as f:
    f.write(tokens["refresh_token"])

print(f"refresh token saved to {REFRESH_TOKEN_FILE}")
