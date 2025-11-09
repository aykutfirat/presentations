#!/bin/bash
# Script to process videos from videos/current/ and create/update presentations
# Automatically detects presentation names from subdirectories in videos/current/
# Processes videos in alphabetical order and pushes to GitHub

set -e

CURRENT_VIDEOS_DIR="videos/current"
THRESHOLD=30.0
HIST_THRESHOLD=0.95
AUTO_PUSH=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --hist-threshold)
            HIST_THRESHOLD="$2"
            shift 2
            ;;
        --no-push)
            AUTO_PUSH=false
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Processes videos from videos/current/PRESENTATION_NAME/ and creates presentations"
            echo ""
            echo "Options:"
            echo "  --threshold FLOAT     MSE threshold for different frames (default: 30.0)"
            echo "  --hist-threshold FLOAT Histogram threshold (default: 0.95)"
            echo "  --no-push             Don't push to GitHub automatically"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Example structure:"
            echo "  videos/current/AI/video1.mp4"
            echo "  videos/current/AI/video2.mp4"
            echo "  → Creates/updates presentation 'AI'"
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
echo "Processing Current Videos"
echo "=========================================="
echo ""

# Check if current videos directory exists
if [ ! -d "$CURRENT_VIDEOS_DIR" ]; then
    echo "Error: Directory $CURRENT_VIDEOS_DIR not found"
    echo "Create it and add presentation subdirectories with videos"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python3"
fi

# Find all presentation directories in videos/current/
presentation_dirs=()
while IFS= read -r -d '' dir; do
    presentation_dirs+=("$(basename "$dir")")
done < <(find "$CURRENT_VIDEOS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [ ${#presentation_dirs[@]} -eq 0 ]; then
    echo "No presentation directories found in $CURRENT_VIDEOS_DIR"
    echo "Create subdirectories like: $CURRENT_VIDEOS_DIR/AI/"
    exit 1
fi

echo "Found ${#presentation_dirs[@]} presentation(s) to process:"
for dir in "${presentation_dirs[@]}"; do
    video_count=$(find "$CURRENT_VIDEOS_DIR/$dir" -type f \( -name "*.mp4" -o -name "*.avi" -o -name "*.mov" -o -name "*.mkv" \) 2>/dev/null | wc -l | tr -d ' ')
    echo "  - $dir ($video_count video(s))"
done
echo ""

# Process each presentation
for PRESENTATION_NAME in "${presentation_dirs[@]}"; do
    VIDEO_DIR="$CURRENT_VIDEOS_DIR/$PRESENTATION_NAME"
    PRESENTATION_DIR="$PRESENTATION_NAME"
    OUTPUT_DIR="$PRESENTATION_DIR/frames"
    SLIDES_FILE="$PRESENTATION_DIR/slides.md"
    INDEX_FILE="$PRESENTATION_DIR/index.html"
    TITLE="$PRESENTATION_NAME Presentation"
    
    echo "=========================================="
    echo "Processing: $PRESENTATION_NAME"
    echo "=========================================="
    
    # Check if videos exist
    video_files=$(find "$VIDEO_DIR" -type f \( -name "*.mp4" -o -name "*.avi" -o -name "*.mov" -o -name "*.mkv" \) 2>/dev/null | wc -l | tr -d ' ')
    if [ "$video_files" -eq 0 ]; then
        echo "Warning: No video files found in $VIDEO_DIR"
        echo "Skipping..."
        echo ""
        continue
    fi
    
    # Create presentation directory if it doesn't exist
    mkdir -p "$PRESENTATION_DIR"
    
    # Step 1: Extract frames from videos
    echo "Step 1: Extracting frames from videos in $VIDEO_DIR..."
    $PYTHON_CMD extract_frames.py "$VIDEO_DIR" -o "$OUTPUT_DIR" -d --threshold "$THRESHOLD" --hist-threshold "$HIST_THRESHOLD"
    
    echo ""
    
    # Step 2: Generate slides
    echo "Step 2: Generating reveal.js markdown..."
    $PYTHON_CMD generate_slides.py "$OUTPUT_DIR" -o "$SLIDES_FILE" -t "$TITLE"
    
    echo ""
    
    # Step 3: Create/update index.html for this presentation
    echo "Step 3: Creating/updating index.html..."
    cat > "$INDEX_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Presentation Slides</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/theme/white.css" id="theme">
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/highlight/monokai.css">
    
    <style>
        .reveal .slides section {
            text-align: center;
        }
        .reveal .slides section[data-background] {
            color: white;
        }
        .reveal .slides section[data-background] h1,
        .reveal .slides section[data-background] h2,
        .reveal .slides section[data-background] h3 {
            color: white;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
        }
    </style>
</head>
<body>
    <div class="reveal">
        <div class="slides">
            <section data-markdown="slides.md" data-separator="---" data-separator-vertical="^\n\n" data-separator-notes="^Note:">
            </section>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/markdown/markdown.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/highlight/highlight.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/notes/notes.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/plugin/zoom/zoom.js"></script>
    
    <script>
        Reveal.initialize({
            hash: true,
            controls: true,
            progress: true,
            center: true,
            touch: true,
            loop: false,
            mouseWheel: false,
            markdown: {
                separator: '---',
                verticalSeparator: '^\n\n',
                notesSeparator: '^Note:',
                highlightCode: true
            },
            plugins: [ RevealMarkdown, RevealHighlight, RevealNotes, RevealZoom ],
            transition: 'slide',
            backgroundTransition: 'fade'
        });
        
        Reveal.addEventListener('ready', function() {
            setTimeout(function() {
                var revealElement = document.querySelector('.reveal');
                revealElement.addEventListener('click', function(event) {
                    var target = event.target;
                    if (!target.closest('.controls') && 
                        !target.closest('a') && 
                        !target.closest('button') &&
                        !target.closest('.progress')) {
                        Reveal.next();
                    }
                });
                revealElement.addEventListener('contextmenu', function(event) {
                    event.preventDefault();
                    Reveal.prev();
                    return false;
                });
                console.log('Click navigation: Left = next, Right = previous');
            }, 800);
        });
    </script>
</body>
</html>
EOF
    echo "✓ Created/updated index.html"
    
    echo ""
done

# Step 4: Update main index.html to list all presentations
echo "=========================================="
echo "Updating main index.html"
echo "=========================================="
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
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #2196F3;
        }
    </style>
</head>
<body>
    <h1>Presentations</h1>
    <div class="info">
        Select a presentation to view.
    </div>
    <ul class="presentation-list">
'''

for pres in presentations:
    html += f'        <li><a href="{pres}/">{pres}</a></li>\n'

if not presentations:
    html += '        <li><em>No presentations yet.</em></li>\n'

html += '''    </ul>
</body>
</html>
'''

with open('index.html', 'w') as f:
    f.write(html)

print(f"✓ Updated main index.html with {len(presentations)} presentation(s)")
PYTHON_SCRIPT

echo ""

# Step 5: Git operations
echo "=========================================="
echo "Committing and pushing to GitHub"
echo "=========================================="

# Check if git is initialized
if [ ! -d .git ]; then
    echo "Warning: Git repository not initialized. Run ./setup_github.sh first."
    AUTO_PUSH=false
else
    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        echo "No changes to commit."
    else
        # Get current date for commit message
        DATE=$(date +"%Y-%m-%d %H:%M:%S")
        PRESENTATION_LIST=$(IFS=', '; echo "${presentation_dirs[*]}")
        
        git add .
        git commit -m "Update presentations: $PRESENTATION_LIST - $DATE" || echo "Nothing to commit"
        
        if [ "$AUTO_PUSH" = true ]; then
            echo ""
            echo "Pushing to GitHub..."
            git push
            echo "✓ Pushed to GitHub"
        else
            echo ""
            echo "To push to GitHub, run:"
            echo "  git push"
        fi
    fi
fi

echo ""
echo "=========================================="
echo "Done!"
echo "=========================================="
echo ""
echo "Processed ${#presentation_dirs[@]} presentation(s):"
for dir in "${presentation_dirs[@]}"; do
    echo "  - $dir → https://aykutfirat.github.io/presentations/$dir/"
done
echo ""
if [ "$AUTO_PUSH" = true ]; then
    echo "Presentations have been pushed to GitHub and will be available in a few minutes."
else
    echo "Remember to push to GitHub: git push"
fi
echo ""

