#!/bin/bash
# Script to create a new presentation in a named directory
# Usage: ./create_presentation.sh AI

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 PRESENTATION_NAME"
    echo "Example: $0 AI"
    echo "This will create a presentation at: https://aykutfirat.github.io/REPO_NAME/AI/"
    exit 1
fi

PRESENTATION_NAME="$1"
PRESENTATION_DIR="$PRESENTATION_NAME"
VIDEOS_DIR="videos"
OUTPUT_DIR="$PRESENTATION_DIR/frames"
SLIDES_FILE="$PRESENTATION_DIR/slides.md"
INDEX_FILE="$PRESENTATION_DIR/index.html"
TITLE="$PRESENTATION_NAME Presentation"
THRESHOLD=30.0
HIST_THRESHOLD=0.95

echo "=========================================="
echo "Creating Presentation: $PRESENTATION_NAME"
echo "=========================================="
echo ""

# Create presentation directory
mkdir -p "$PRESENTATION_DIR"
echo "✓ Created directory: $PRESENTATION_DIR"

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python3"
fi

# Step 1: Extract frames from videos
echo ""
echo "Step 1: Extracting frames from videos..."
$PYTHON_CMD extract_frames.py "$VIDEOS_DIR" -o "$OUTPUT_DIR" -d --threshold "$THRESHOLD" --hist-threshold "$HIST_THRESHOLD"

echo ""

# Step 2: Generate slides
echo "Step 2: Generating reveal.js markdown..."
$PYTHON_CMD generate_slides.py "$OUTPUT_DIR" -o "$SLIDES_FILE" -t "$TITLE"

echo ""

# Step 3: Create index.html for this presentation
echo "Step 3: Creating index.html..."
cat > "$INDEX_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Presentation Slides</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/reveal.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/theme/white.css" id="theme">
    
    <!-- Theme used for syntax highlighting of code -->
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
        // More info about initialization & config:
        // - https://revealjs.com/initialization/
        // - https://revealjs.com/config/
        Reveal.initialize({
            hash: true,
            controls: true,
            progress: true,
            center: true,
            touch: true,
            loop: false,
            mouseWheel: false,
            
            // Markdown configuration
            markdown: {
                separator: '---',
                verticalSeparator: '^\n\n',
                notesSeparator: '^Note:',
                highlightCode: true
            },
            
            // Learn about plugins: https://revealjs.com/plugins/
            plugins: [ RevealMarkdown, RevealHighlight, RevealNotes, RevealZoom ],
            
            // Transition settings
            transition: 'slide', // none/fade/slide/convex/concave/zoom
            backgroundTransition: 'fade'
        });
        
        // Click navigation: left click = next, right click = previous
        Reveal.addEventListener('ready', function() {
            // Wait for markdown to load and render
            setTimeout(function() {
                var revealElement = document.querySelector('.reveal');
                
                // Left click anywhere on slide = next
                revealElement.addEventListener('click', function(event) {
                    var target = event.target;
                    // Skip controls and interactive elements
                    if (!target.closest('.controls') && 
                        !target.closest('a') && 
                        !target.closest('button') &&
                        !target.closest('.progress')) {
                        Reveal.next();
                    }
                });
                
                // Right click = previous
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
echo "✓ Created index.html"

# Step 4: Update main index.html to list all presentations
echo ""
echo "Step 4: Updating main index.html..."
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
echo "=========================================="
echo "Done!"
echo "=========================================="
echo ""
echo "Presentation created: $PRESENTATION_NAME"
echo "Access it at: https://aykutfirat.github.io/REPOSITORY_NAME/$PRESENTATION_NAME/"
echo ""
echo "To commit and push:"
echo "  git add $PRESENTATION_DIR/"
echo "  git add index.html"
echo "  git commit -m \"Add presentation: $PRESENTATION_NAME\""
echo "  git push"
echo ""

