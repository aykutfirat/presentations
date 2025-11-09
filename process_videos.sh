#!/bin/bash
# Process videos and generate reveal.js slides

set -e

# Default values
VIDEOS_DIR="videos"
OUTPUT_DIR="frames"
SLIDES_FILE="slides.md"
TITLE="Presentation"
INTERVAL=5
NUM_FRAMES=""
EXTRACT_DIFFERENT=true
THRESHOLD=30.0
HIST_THRESHOLD=0.95

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--videos)
            VIDEOS_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s|--slides)
            SLIDES_FILE="$2"
            shift 2
            ;;
        -t|--title)
            TITLE="$2"
            shift 2
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -n|--num-frames)
            NUM_FRAMES="$2"
            EXTRACT_DIFFERENT=false
            shift 2
            ;;
        --different)
            EXTRACT_DIFFERENT=true
            shift
            ;;
        --no-different)
            EXTRACT_DIFFERENT=false
            shift
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --hist-threshold)
            HIST_THRESHOLD="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --videos DIR      Directory containing video files (default: videos)"
            echo "  -o, --output DIR      Output directory for frames (default: frames)"
            echo "  -s, --slides FILE     Output slides markdown file (default: slides.md)"
            echo "  -t, --title TITLE     Presentation title (default: Presentation)"
            echo "  -i, --interval SEC    Extract frame every N seconds (default: 5)"
            echo "  -n, --num-frames N    Extract N key frames (overrides different mode)"
            echo "  --different           Extract only different frames (default: true)"
            echo "  --no-different        Disable different frame extraction"
            echo "  --threshold FLOAT     MSE threshold for different frames (default: 30.0)"
            echo "  --hist-threshold FLOAT Histogram threshold (default: 0.95)"
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
echo "Video to Reveal.js Slides Converter"
echo "=========================================="
echo ""

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python3"
fi

# Step 1: Extract frames
echo "Step 1: Extracting frames from videos..."
if [ "$EXTRACT_DIFFERENT" = true ] && [ -z "$NUM_FRAMES" ]; then
    $PYTHON_CMD extract_frames.py "$VIDEOS_DIR" -o "$OUTPUT_DIR" -d --threshold "$THRESHOLD" --hist-threshold "$HIST_THRESHOLD"
elif [ -n "$NUM_FRAMES" ]; then
    $PYTHON_CMD extract_frames.py "$VIDEOS_DIR" -o "$OUTPUT_DIR" -n "$NUM_FRAMES"
else
    $PYTHON_CMD extract_frames.py "$VIDEOS_DIR" -o "$OUTPUT_DIR" -i "$INTERVAL"
fi

echo ""

# Step 2: Generate slides
echo "Step 2: Generating reveal.js markdown..."
$PYTHON_CMD generate_slides.py "$OUTPUT_DIR" -o "$SLIDES_FILE" -t "$TITLE"

echo ""
echo "=========================================="
echo "Done!"
echo "=========================================="
echo "Frames extracted to: $OUTPUT_DIR"
echo "Slides generated: $SLIDES_FILE"
echo "Open index.html in a web browser to view your presentation."
echo ""

