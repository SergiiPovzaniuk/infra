import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.request import Request, urlopen


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["Content-Length"])
        payload = json.loads(self.rfile.read(length))
        alerts = payload.get("alerts", [])
        lines = [
            f"[{alert.get('status', 'unknown').upper()}] {alert['labels'].get('alertname')}: {alert['annotations'].get('summary', '')}"
            for alert in alerts
        ]
        webhook = os.environ.get("DISCORD_WEBHOOK_URL", "")
        if webhook and "replace-me" not in webhook:
            request = Request(
                webhook,
                data=json.dumps({"content": "\n".join(lines)}).encode(),
                headers={"Content-Type": "application/json"},
            )
            urlopen(request, timeout=10)
        self.send_response(204)
        self.end_headers()


HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
