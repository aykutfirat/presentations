#!/bin/bash
# Script to update presentation for weekly videos
# This extracts frames, generates slides, commits, and pushes to GitHub

set -e

# Default values
VIDEOS_DIR="videos"
OUTPUT_DIR="frames"
SLIDES_FILE="slides.md"
TITLE="Presentation"
THRESHOLD=30.0
HIST_THRESHOLD=0.95
AUTO_COMMIT=true
AUTO_PUSH=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--videos)
            VIDEOS_DIR="$2"
            shift 2
            ;;
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
        --no-commit)
            AUTO_COMMIT=false
            shift
            ;;
        --push)
            AUTO_PUSH=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --videos DIR      Directory containing video files (default: videos)"
            echo "  -t, --title TITLE     Presentation title (default: Presentation)"
            echo "  --threshold FLOAT     MSE threshold for different frames (default: 30.0)"
            echo "  --hist-threshold FLOAT Histogram threshold (default: 0.95)"
            echo "  --no-commit           Don't automatically commit changes"
            echo "  --push                Push to GitHub after committing"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "Weekly Presentation Update"
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

# Step 3: Git operations
if [ "$AUTO_COMMIT" = true ]; then
    echo "Step 3: Committing changes to git..."
    
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
            git add frames/ slides.md
            git commit -m "Update presentation: $DATE - $TITLE"
            echo "✓ Changes committed"
            
            # Push if requested
            if [ "$AUTO_PUSH" = true ]; then
                echo ""
                echo "Step 4: Pushing to GitHub..."
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
echo "To view your presentation locally:"
echo "  python3 -m http.server 8000"
echo "  Then open http://localhost:8000/index.html"
echo ""
if [ "$AUTO_PUSH" = true ]; then
    echo "Your presentation will be available on GitHub Pages in a few minutes."
else
    echo "Remember to push to GitHub to update GitHub Pages:"
    echo "  git push"
fi
echo ""

