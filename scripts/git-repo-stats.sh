#!/bin/bash
# Script to display statistics about a git repository

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Repository name
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

echo "====================================="
echo "Git Repository Statistics"
echo "====================================="
echo "Repository: $REPO_NAME"
echo ""

# Total number of commits
TOTAL_COMMITS=$(git rev-list --all --count)
echo "Total commits: $TOTAL_COMMITS"

# Number of branches
BRANCH_COUNT=$(git branch -a | grep -v HEAD | wc -l)
echo "Total branches: $BRANCH_COUNT"

# Number of contributors
CONTRIBUTOR_COUNT=$(git log --format='%an' | sort -u | wc -l)
echo "Total contributors: $CONTRIBUTOR_COUNT"

# Top 5 contributors
echo ""
echo "Top 5 contributors:"
git log --format='%an' | sort | uniq -c | sort -nr | head -5 | awk '{print "  " $2, $3, $4, "(" $1, "commits)"}'

# Most recent commit
echo ""
echo "Most recent commit:"
git log -1 --pretty=format:"  %h - %an, %ar : %s" 
echo ""

# File statistics
TOTAL_FILES=$(git ls-files | wc -l)
echo ""
echo "Total files tracked: $TOTAL_FILES"

# Lines of code by file type
echo ""
echo "Lines of code by file type:"
git ls-files | grep -E '\.(sh|bash)$' | xargs wc -l 2>/dev/null | tail -1 | awk '{print "  Shell scripts: " $1 " lines"}'
git ls-files | grep -E '\.(py)$' | xargs wc -l 2>/dev/null | tail -1 | awk '{print "  Python: " $1 " lines"}'
git ls-files | grep -E '\.(js|jsx)$' | xargs wc -l 2>/dev/null | tail -1 | awk '{print "  JavaScript: " $1 " lines"}'

echo ""
echo "====================================="
