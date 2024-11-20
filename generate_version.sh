#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Fetch the latest tag from the current branch
LAST_TAG=$(git describe --tags --abbrev=0 --match "20[0-9]*" 2>/dev/null || echo "")

# Get the short SHA of the latest commit
SHORT_HASH=$(git rev-parse --short HEAD)

# Generate the current date in YYYYMMDD format
BUILD_DATE=$(date +"%Y%m%d")

# Check if there are any new commits on the main branch since the last tag
if [ -n "$LAST_TAG" ]; then
  # Compare the latest tag with the HEAD commit
  if git rev-list $LAST_TAG..HEAD --count | grep -q '^0$'; then
    echo "No new commits on the main branch since the last release ($LAST_TAG)." >&2
    exit 0
  fi
fi

# Construct the new version number
NEW_VERSION="$BUILD_DATE.$SHORT_HASH"

# Output the version (to stdout)
echo "$NEW_VERSION"