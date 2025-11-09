#!/bin/bash
# Script to update an existing presentation in a named directory
# Usage: ./update_presentation_dir.sh AI

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 PRESENTATION_NAME [OPTIONS]"
    echo "Example: $0 AI --push"
    echo ""
    echo "Options:"
    echo "  -t, --title TITLE     Presentation title"
    echo "  --threshold FLOAT     MSE threshold (default: 30.0)"
    echo "  --hist-threshold FLOAT Histogram threshold (default: 0.95)"
    echo "  --push                Push to GitHub after committing"
    echo "  --no-commit           Don't automatically commit"
    exit 1
fi

PRESENTATION_NAME="$1"
shift
PRESENTATION_DIR="$PRESENTATION_NAME"
VIDEOS_DIR="videos"
OUTPUT_DIR="$PRESENTATION_DIR/frames"
SLIDES_FILE="$PRESENTATION_DIR/slides.md"
TITLE="$PRESENTATION_NAME Presentation"
THRESHOLD=30.0
HIST_THRESHOLD=0.95
AUTO_COMMIT=true
AUTO_PUSH=false

# Parse remaining arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--title)
            TITLE="$2"
            shift 2
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --hist-threshold)
            HIST_THRESHOLD="$2"
            shift 2
            ;;
        --push)
            AUTO_PUSH=true
            shift
            ;;
        --no-commit)
            AUTO_COMMIT=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if presentation directory exists
if [ ! -d "$PRESENTATION_DIR" ]; then
    echo "Error: Presentation '$PRESENTATION_NAME' does not exist."
    echo "Create it first with: ./create_presentation.sh $PRESENTATION_NAME"
    exit 1
fi

echo "=========================================="
echo "Updating Presentation: $PRESENTATION_NAME"
echo "=========================================="
echo ""

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python3"
fi

# Step 1: Extract frames from videos
echo "Step 1: Extracting frames from videos..."
$PYTHON_CMD extract_frames.py "$VIDEOS_DIR" -o "$OUTPUT_DIR" -d --threshold "$THRESHOLD" --hist-threshold "$HIST_THRESHOLD"

echo ""

# Step 2: Generate slides
echo "Step 2: Generating reveal.js markdown..."
$PYTHON_CMD generate_slides.py "$OUTPUT_DIR" -o "$SLIDES_FILE" -t "$TITLE"

echo ""

# Step 3: Update main index.html
echo "Step 3: Updating main index.html..."
python3 << PYTHON_SCRIPT
import os
from pathlib import Path

# Find all presentation directories (directories with index.html)
presentations = []
for item in Path('.').iterdir():
    if item.is_dir() and not item.name.startswith('.') and item.name not in ['venv', 'videos']:
        index_file = item / 'index.html'
        if index_file.exists():
            presentations.append(item.name)

presentations.sort()

# Generate main index.html
html = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Presentation Index</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .presentation-list {
            list-style: none;
            padding: 0;
        }
        .presentation-list li {
            margin: 15px 0;
        }
        .presentation-list a {
            display: block;
            padding: 15px 20px;
            background: white;
            border-radius: 8px;
            text-decoration: none;
            color: #333;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .presentation-list a:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            color: #4CAF50;
        }
        .presentation-list a::before {
            content: "📊 ";
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <h1>Presentations</h1>
    <ul class="presentation-list">
'''

for pres in presentations:
    html += f'        <li><a href="{pres}/">{pres}</a></li>\n'

html += '''    </ul>
</body>
</html>
'''

with open('index.html', 'w') as f:
    f.write(html)

print(f"✓ Updated main index.html with {len(presentations)} presentation(s)")
PYTHON_SCRIPT

echo ""

# Step 4: Git operations
if [ "$AUTO_COMMIT" = true ]; then
    echo "Step 4: Committing changes to git..."
    
    # Check if git is initialized
    if [ ! -d .git ]; then
        echo "Warning: Git repository not initialized. Run ./setup_github.sh first."
        AUTO_COMMIT=false
    else
        # Check if there are changes
        if git diff --quiet && git diff --cached --quiet; then
            echo "No changes to commit."
        else
            # Get current date for commit message
            DATE=$(date +"%Y-%m-%d")
            git add "$PRESENTATION_DIR/" index.html
            git commit -m "Update presentation $PRESENTATION_NAME: $DATE"
            echo "✓ Changes committed"
            
            # Push if requested
            if [ "$AUTO_PUSH" = true ]; then
                echo ""
                echo "Step 5: Pushing to GitHub..."
                git push
                echo "✓ Pushed to GitHub"
            else
                echo ""
                echo "To push to GitHub, run:"
                echo "  git push"
            fi
        fi
    fi
fi

echo ""
echo "=========================================="
echo "Done!"
echo "=========================================="
echo ""
echo "Presentation updated: $PRESENTATION_NAME"
echo "Access it at: https://aykutfirat.github.io/REPOSITORY_NAME/$PRESENTATION_NAME/"
echo ""

