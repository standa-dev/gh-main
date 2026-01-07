#!/usr/bin/env bash
set -euo pipefail

CHECKPOINTS="subtree-checkpoints"
DEST_URL="https://x-access-token:${GH_TOKEN}@github.com/standa-dev/${REMOTE}.git"
MAIN_URL="https://x-access-token:${GH_TOKEN}@github.com/standa-dev/gh-main.git"

git config user.name "CI"
git config user.email "ci@nimbus.co"

git fetch origin

# checkout checkpoints (or create from main)
git checkout -B "$CHECKPOINTS" "origin/$CHECKPOINTS" 2>/dev/null \
  || git checkout -B "$CHECKPOINTS" origin/main

# merge latest main (checkpoints diverges by design)
old=$(git rev-parse HEAD)
git merge --no-edit origin/main
new=$(git rev-parse HEAD)

# only do subtree work if prefix changed in the newly-merged range
if git diff --quiet "$old..$new" -- "$SUBTREE/"; then
  echo "No changes in $SUBTREE"
  git push origin "$CHECKPOINTS" || true
  exit 0
fi

if split=$(git subtree split -P "$SUBTREE" --squash --rejoin HEAD "$DEST_URL" 2>/dev/null); then
  echo "subtree: used --rejoin checkpoints"

  git push "$DEST_URL" "$split:$DEST_BRANCH"
  git push "$MAIN_URL" "$CHECKPOINTS"
else
  echo "subtree: split failed OR no new revisions for $SUBTREE"
fi
