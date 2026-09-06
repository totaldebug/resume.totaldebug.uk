#!/usr/bin/env bash
# Regenerate Steven-Marks-Resume.pdf locally, mirroring the CI render step in
# .github/workflows/deploy.yml. Builds the site, serves it, renders print.html
# to a PDF via headless Chrome, and writes the result to both _site/ and the
# repo root (the committed copy Jekyll serves as a static asset).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

port=8000
pdf_rel="Steven-Marks-Resume.pdf"

# Locate a Chrome/Chromium binary across macOS and Linux.
chrome=""
for candidate in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "$(command -v google-chrome || true)" \
  "$(command -v google-chrome-stable || true)" \
  "$(command -v chromium || true)" \
  "$(command -v chromium-browser || true)"; do
  if [ -n "$candidate" ] && [ -x "$candidate" ]; then
    chrome="$candidate"
    break
  fi
done

if [ -z "$chrome" ]; then
  echo "error: no Chrome/Chromium binary found" >&2
  exit 1
fi

echo "Building site with Jekyll..."
bundle exec jekyll build

echo "Serving _site on :$port..."
python3 -m http.server "$port" --directory _site >/dev/null 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT

for _ in $(seq 1 10); do
  if curl -sf "http://localhost:$port/print.html" >/dev/null; then
    break
  fi
  sleep 1
done

echo "Rendering print.html to PDF..."
"$chrome" --headless=new --disable-gpu --no-sandbox \
  --no-pdf-header-footer \
  --print-to-pdf="_site/$pdf_rel" \
  "http://localhost:$port/print.html" 2>/dev/null

test -s "_site/$pdf_rel"
cp "_site/$pdf_rel" "$pdf_rel"

echo "Done. Regenerated $pdf_rel ($(wc -c <"$pdf_rel" | tr -d ' ') bytes)."
