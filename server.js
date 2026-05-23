/**
 * server.js — Minimal static file server for the Flutter web release.
 *
 * Firebase App Hosting runs this via `node server.js` on Cloud Run.
 * It serves the contents of build/web with correct MIME types and
 * SPA fallback routing (all unknown paths → index.html).
 *
 * Zero external dependencies — uses Node.js built-ins only.
 */
"use strict";

const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT || 8080;
const WEB_DIR = path.join(__dirname, "build", "web");

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript",
  ".mjs": "application/javascript",
  ".css": "text/css",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".wasm": "application/wasm",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
};

const CACHE = {
  // Service worker and index must always revalidate
  "/flutter_service_worker.js": "no-cache, no-store, must-revalidate",
  "/index.html": "no-cache, no-store, must-revalidate",
};

const server = http.createServer((req, res) => {
  // Strip query strings and decode URI
  let urlPath;
  try {
    urlPath = decodeURIComponent(req.url.split("?")[0]);
  } catch {
    urlPath = req.url.split("?")[0];
  }

  if (urlPath === "/") urlPath = "/index.html";

  const filePath = path.join(WEB_DIR, urlPath);

  // Prevent path traversal outside WEB_DIR
  if (!filePath.startsWith(WEB_DIR + path.sep) && filePath !== WEB_DIR) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      // SPA fallback — serve index.html for all unknown paths
      fs.readFile(path.join(WEB_DIR, "index.html"), (err2, indexData) => {
        if (err2) {
          res.writeHead(404);
          res.end("Not found");
        } else {
          res.writeHead(200, {
            "Content-Type": "text/html; charset=utf-8",
            "Cache-Control": "no-cache, no-store, must-revalidate",
          });
          res.end(indexData);
        }
      });
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME[ext] || "application/octet-stream";
    const cacheControl =
      CACHE[urlPath] || "public, max-age=31536000, immutable";

    res.writeHead(200, {
      "Content-Type": contentType,
      "Cache-Control": cacheControl,
    });
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`4Directions Farm web serving from ${WEB_DIR} on port ${PORT}`);
});
