#!/usr/bin/env bash
set -euo pipefail

AUTH_URL="https://x-access-token:${GH_TOKEN}@github.com/${SYNC_REPOSITORY}.git"

# Trailing slashes mean contents of that folder
rsync -a "$SYNC_SRC_DIR/" "./"

# Commit & push if needed
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Changes detected. Creating commit..."

  git config user.email "nimbus-deploy@nimbus.co"
  git config user.name "Nimbus Deploy"

  git add --all
  git commit -m "Update extension"

  echo "Pushing to extension repository..."
  git push "$AUTH_URL" main
  echo "✅ Sync complete."
else
  echo "No changes to sync. ✅"
fi