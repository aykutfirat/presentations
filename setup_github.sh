#!/bin/bash
# Script to set up and push to GitHub

set -e

echo "=========================================="
echo "GitHub Setup for Presentation Slides"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    echo "✓ Git repository initialized"
else
    echo "✓ Git repository already initialized"
fi

# Add all files
echo ""
echo "Adding files to git..."
git add .
echo "✓ Files added"

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    echo ""
    echo "Committing changes..."
    git commit -m "Initial commit: Video to Reveal.js slides converter"
    echo "✓ Changes committed"
fi

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Create a new repository on GitHub: https://github.com/new"
echo "   (Don't initialize it with README, .gitignore, or license)"
echo ""
echo "2. Run these commands (replace YOUR_USERNAME and YOUR_REPO_NAME):"
echo ""
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages:"
echo "   - Go to repository Settings > Pages"
echo "   - Source: Branch 'main', folder '/ (root)'"
echo "   - Save"
echo ""
echo "4. Your presentation will be available at:"
echo "   https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/"
echo ""
echo "See SETUP_GITHUB.md for detailed instructions."
echo ""

