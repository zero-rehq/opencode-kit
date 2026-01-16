#!/bin/bash

# generate-release-notes.sh - Generate release notes from commits
# Usage: ./generate-release-notes.sh [tag] [prev-tag]
# Output: Markdown release notes

set -e

TAG="${1:-HEAD}"
PREV_TAG="${2:-$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Release Notes Generator"
echo "=========================================="
echo "Current tag: $TAG"
echo "Previous tag: $PREV_TAG"
echo ""

# Get commits between tags
if [ -z "$PREV_TAG" ]; then
    echo -e "${YELLOW}WARNING:${NC} No previous tag found, showing all commits up to $TAG"
    commit_range="$TAG"
else
    commit_range="$PREV_TAG..$TAG"
fi

echo "Analyzing commits: $commit_range"
echo ""

# Get commit messages
commits=$(git log "$commit_range" --pretty=format:"%h|%s|%an|%ae" --no-merges 2>/dev/null)

if [ -z "$commits" ]; then
    echo -e "${RED}ERROR:${NC} No commits found"
    exit 1
fi

# Categorize commits
declare -A categories=(
    ["feat"]=""
    ["fix"]=""
    ["chore"]=""
    ["docs"]=""
    ["style"]=""
    ["refactor"]=""
    ["perf"]=""
    ["test"]=""
    ["build"]=""
    ["ci"]=""
    ["other"]=""
)

# Parse and categorize commits
while IFS='|' read -r hash message author email; do
    # Extract conventional commit type
    type=$(echo "$message" | grep -oE '^[a-z]+' | head -1)

    # Default to 'other' if no type found
    if [ -z "${categories[$type]+isset}" ]; then
        type="other"
    fi

    # Format entry
    entry="- [$hash] ${message} (${author})"

    # Add to category
    categories["$type"]="${categories[$type]}${entry}"$'\n'
done <<< "$commits"

# Generate release notes
cat << EOF
# Release ${TAG}

Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")

EOF

# Print each category
for category in feat fix docs refactor perf test ci; do
    if [ -n "${categories[$category]}" ]; then
        echo "### ${category^}"
        echo ""
        echo "${categories[$category]}"
        echo ""
    fi
done

# Print other categories at the end
for category in chore style build other; do
    if [ -n "${categories[$category]}" ]; then
        echo "### ${category^}"
        echo ""
        echo "${categories[$category]}"
        echo ""
    fi
done

# Statistics
total_commits=$(echo "$commits" | wc -l)
authors=$(echo "$commits" | cut -d'|' -f4 | sort -u | wc -l)

echo "## Statistics"
echo ""
echo "- **Commits**: $total_commits"
echo "- **Authors**: $authors"
echo "- **Contributors**:"
echo "$commits" | cut -d'|' -f4 | sort | uniq -c | sort -rn | sed 's/^/  - /'

echo ""
echo "=========================================="
echo "Generated successfully!"
echo "=========================================="
echo ""
echo "Usage:"
echo "  • Copy the output above to your release notes"
echo "  • Or redirect to a file: ./generate-release-notes.sh > RELEASE_NOTES.md"
