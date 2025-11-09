#!/bin/bash
# Script to push to GitHub
# Usage: ./push_to_github.sh REPOSITORY_NAME
# Example: ./push_to_github.sh presentation-slides

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 REPOSITORY_NAME"
    echo "Example: $0 presentation-slides"
    echo ""
    echo "First, create a repository on GitHub: https://github.com/new"
    echo "Then run this script with your repository name."
    exit 1
fi

REPO_NAME="$1"
USERNAME="aykutfirat"
REMOTE_URL="https://github.com/${USERNAME}/${REPO_NAME}.git"

echo "=========================================="
echo "Pushing to GitHub"
echo "=========================================="
echo ""
echo "Repository: ${USERNAME}/${REPO_NAME}"
echo "Remote URL: ${REMOTE_URL}"
echo ""

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    echo "Remote 'origin' already exists. Updating..."
    git remote set-url origin "$REMOTE_URL"
else
    echo "Adding remote 'origin'..."
    git remote add origin "$REMOTE_URL"
fi

# Rename branch to main if needed
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Renaming branch to 'main'..."
    git branch -M main
fi

echo ""
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "=========================================="
echo "Success!"
echo "=========================================="
echo ""
echo "Your presentation is now on GitHub!"
echo ""
echo "Next steps:"
echo "1. Enable GitHub Pages:"
echo "   - Go to: https://github.com/${USERNAME}/${REPO_NAME}/settings/pages"
echo "   - Source: Branch 'main', folder '/ (root)'"
echo "   - Save"
echo ""
echo "2. Access your presentation:"
echo "   - Main index: https://${USERNAME}.github.io/${REPO_NAME}/"
echo "   - AI presentation: https://${USERNAME}.github.io/${REPO_NAME}/AI/"
echo ""
echo "Note: GitHub Pages may take a few minutes to update."
echo ""

