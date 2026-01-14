#!/usr/bin/env bash
set -euo pipefail

# Trailing slashes mean contents of that folder. 
# 'P .git/' protects .git/ from modifications as the main repo doesn't have it.
rsync -a --delete --filter='P .git/' "$SYNC_SRC_DIR/" "./"

# Commit & push if needed
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Changes detected. Creating commit..."

  git config user.email "nimbus-deploy@nimbus.co"
  git config user.name "Nimbus Deploy"

  git add --all
  git commit -m "Update extension"

  echo "Pushing to extension repository..."
  git push origin HEAD
  echo "✅ Sync complete."
else
  echo "✅ No changes to sync."
fi