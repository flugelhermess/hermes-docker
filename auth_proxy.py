#!/usr/bin/env python3
"""Simple auth proxy for Hermes dashboard on Railway.
Based on mazshakibaii/hermes-agent-railway approach."""
import os, sys, subprocess

PORT = int(os.environ.get("PORT", 8080))
DASH_PORT = 9119
HERMES_HOME = os.environ.get("HERMES_HOME", "/data/.hermes")

# Start dashboard in background
print(f"[proxy] Starting hermes dashboard on port {DASH_PORT}...")
dash = subprocess.Popen(
    ["hermes", "dashboard", "--host", "127.0.0.1", "--port", str(DASH_PORT), "--no-open"],
    stdout=subprocess.PIPE, stderr=subprocess.PIPE
)

# Wait for dashboard to start
import time
time.sleep(3)

print(f"[proxy] Dashboard started (pid {dash.pid})")

# Simple reverse proxy — no auth, just pass traffic
import http.server, http.client, urllib.parse

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self._proxy("GET")
    def do_POST(self):
        self._proxy("POST")
    def do_PUT(self):
        self._proxy("PUT")
    def do_DELETE(self):
        self._proxy("DELETE")
    def do_PATCH(self):
        self._proxy("PATCH")

    def _proxy(self, method):
        try:
            # Read body
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length) if content_length > 0 else None

            # Forward to dashboard
            conn = http.client.HTTPConnection("127.0.0.1", DASH_PORT, timeout=300)
            headers = {k: v for k, v in self.headers.items()
                       if k.lower() not in ("host", "transfer-encoding")}
            conn.request(method, self.path, body=body, headers=headers)
            resp = conn.getresponse()

            data = resp.read()
            self.send_response(resp.status)
            for k, v in resp.getheaders():
                if k.lower() not in ("transfer-encoding", "content-encoding", "content-length"):
                    self.send_header(k, v)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            conn.close()
        except Exception as e:
            print(f"[proxy] Error: {e}", file=sys.stderr)
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"error":"proxy error"}')

    def log_message(self, format, *args):
        print(f"[proxy] {args[0]}")

server = http.server.HTTPServer(("0.0.0.0", PORT), ProxyHandler)
print(f"[proxy] Proxy listening on 0.0.0.0:{PORT} -> 127.0.0.1:{DASH_PORT}")
try:
    server.serve_forever()
except KeyboardInterrupt:
    print("[proxy] Shutting down...")
    dash.terminate()
