#!/bin/bash

set -eo pipefail

git fetch origin

# 1) Start from checkpoints branch (create it if it doesn't exist)
git checkout -B subtree-checkpoints origin/subtree-checkpoints 2>/dev/null \
  || git checkout -B subtree-checkpoints origin/main

# 2) Bring in latest main (must be clean fast-forward)
git merge --ff-only origin/main

# 3) Split + rejoin (this creates commits, but only on subtree-checkpoints)
splitResult=$(git subtree split -P extensions/LiveRamp --squash --rejoin)

if [ ! -z "$splitResult" ]; then
    # 4) Push to the dedicated remote for that subtree
    git push gh-liveramp "$splitResult:main"

    # 5) Persist checkpoints updates
    git push origin subtree-checkpoints
else
    echo "No changes in LiveRamp detected"
fi
