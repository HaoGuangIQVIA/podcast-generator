#!/bin/bash
set -euo pipefail

# The runner injects SSL_* variables pointing at host paths that are not mounted
# into this container; git then fails with "Problem with the SSL CA cert".
unset SSL_CERT_FILE REQUESTS_CA_BUNDLE CURL_CA_BUNDLE NODE_EXTRA_CA_CERTS GIT_SSL_CAINFO 2>/dev/null || true
export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt

echo "=========================="

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${INPUT_EMAIL}"
git config --global --add safe.directory /github/workspace

python3 /usr/bin/feed.py

git add -A
if git diff --staged --quiet; then
  echo "No feed changes to commit; skipping push."
else
  git commit -m "Update Feed [skip ci]"
  git push --set-upstream origin main
fi

echo "=========================="