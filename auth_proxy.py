#!/usr/bin/env python3
"""Simple reverse proxy for Hermes dashboard."""
import os, sys
import http.server, http.client

PORT = int(os.environ.get("PORT", 8080))
DASH_PORT = 9119

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self): self._proxy("GET")
    def do_POST(self): self._proxy("POST")
    def do_PUT(self): self._proxy("PUT")
    def do_DELETE(self): self._proxy("DELETE")
    def do_PATCH(self): self._proxy("PATCH")

    def _proxy(self, method):
        try:
            cl = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(cl) if cl > 0 else None
            conn = http.client.HTTPConnection("127.0.0.1", DASH_PORT, timeout=300)
            h = {k: v for k, v in self.headers.items() if k.lower() not in ("host", "transfer-encoding")}
            conn.request(method, self.path, body=body, headers=h)
            r = conn.getresponse()
            data = r.read()
            self.send_response(r.status)
            for k, v in r.getheaders():
                if k.lower() not in ("transfer-encoding", "content-encoding", "content-length"):
                    self.send_header(k, v)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            conn.close()
        except Exception as e:
            print(f"[proxy] Error: {e}", file=sys.stderr)
            self.send_response(502)
            self.end_headers()

    def log_message(self, *args): pass

server = http.server.HTTPServer(("0.0.0.0", PORT), ProxyHandler)
print(f"[proxy] Listening on 0.0.0.0:{PORT} -> 127.0.0.1:{DASH_PORT}")
server.serve_forever()
