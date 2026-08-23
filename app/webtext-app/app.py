import os
from http.server import BaseHTTPRequestHandler, HTTPServer


class WebTextHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = os.environ.get("WEBTEXT", "Hello World!").encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 80), WebTextHandler).serve_forever()