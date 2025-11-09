# Video to Reveal.js Slides Converter

This project extracts frames from MP4 video files and creates a reveal.js presentation with those frames as slide backgrounds.

## Features

- Extract only frames that are different (captures all scene changes and transitions)
- Extract frames from MP4 videos at regular intervals or as key frames
- Automatically generate reveal.js markdown presentation
- Organize frames by video source
- Customizable frame extraction settings and sensitivity thresholds

## Prerequisites

- Python 3.7+
- OpenCV (installed via requirements.txt)

## Installation

1. Install Python dependencies:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. Place your MP4 video files in the `videos/` directory

## Usage

### Step 1: Extract Frames from Video(s)

Place your MP4 video files in the `videos/` directory, then extract frames:

**Extract only frames that are different (recommended):**
This captures all scene changes, transitions, and meaningful differences:
```bash
python extract_frames.py videos/ -o frames -d
```

Or with custom sensitivity (lower threshold = more frames):
```bash
python extract_frames.py videos/ -o frames -d --threshold 20.0 --hist-threshold 0.97
```

**Other extraction methods:**

Extract frames every 10 seconds:
```bash
python extract_frames.py videos/ -o frames -i 10
```

Extract 20 key frames evenly distributed:
```bash
python extract_frames.py videos/ -o frames -n 20
```

Extract frames with a maximum limit:
```bash
python extract_frames.py videos/ -o frames -i 5 -m 50
```

### Step 2: Generate Reveal.js Markdown

Generate the markdown presentation from extracted frames:
```bash
python generate_slides.py frames -o slides.md -t "My Presentation"
```

### Step 3: View the Presentation

Open `index.html` in a web browser to view your presentation. The HTML file loads `slides.md` and renders it using reveal.js.

**Note:** For local file access, you may need to use a local web server:
```bash
# Python 3
python3 -m http.server 8000

# Then open http://localhost:8000/index.html in your browser
```

### Quick Start (All Steps)

Use the automated script to process all videos at once (extracts different frames by default):
```bash
./process_videos.sh -t "My Presentation"
```

Or with custom settings:
```bash
./process_videos.sh -t "My Presentation" --threshold 20.0 --hist-threshold 0.97
```

## File Structure

```
.
├── extract_frames.py      # Script to extract frames from videos
├── generate_slides.py     # Script to generate reveal.js markdown
├── index.html             # Reveal.js HTML presentation
├── slides.md              # Generated markdown (created after step 2)
├── frames/                # Extracted frames directory (created after step 1)
│   ├── video1/
│   │   ├── frame_0000_t0.00s.jpg
│   │   ├── frame_0001_t5.00s.jpg
│   │   └── ...
│   └── video2/
│       └── ...
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## Options

### extract_frames.py

- `video`: Path to video file or directory containing videos
- `-o, --output`: Output directory for frames (default: `frames`)
- `-d, --different`: Extract only frames that are different (recommended)
- `-t, --threshold`: MSE threshold for different frames (default: 30.0, lower = more sensitive)
- `--hist-threshold`: Histogram correlation threshold (default: 0.95, lower = more sensitive)
- `-i, --interval`: Extract frame every N seconds (default: 5)
- `-n, --num-frames`: Number of key frames to extract (overrides different mode)
- `-m, --max-frames`: Maximum number of frames to extract

### generate_slides.py

- `frames_dir`: Directory containing extracted frames
- `-o, --output`: Output markdown file (default: `slides.md`)
- `-t, --title`: Presentation title (default: `Presentation`)
- `--theme`: Reveal.js theme (default: `white`)

## Reveal.js Controls

- **Arrow keys** or **Space**: Navigate slides
- **ESC**: Overview mode
- **S**: Speaker notes
- **B**: Pause/blackout
- **F**: Fullscreen
- **.**: Pause

## Customization

### Change Reveal.js Theme

Edit `index.html` and change the theme CSS link:
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.3.1/dist/theme/black.css" id="theme">
```

Available themes: `default`, `black`, `white`, `league`, `beige`, `sky`, `night`, `serif`, `simple`, `solarized`

### Modify Slide Transitions

Edit the `generate_slides.py` script to change transition types:
- `zoom`
- `slide`
- `fade`
- `convex`
- `concave`

### Add Content to Slides

Edit `slides.md` after generation to add text content to each slide. The markdown file contains comments indicating where you can add content.

## Troubleshooting

### OpenCV Installation Issues

If you encounter issues installing OpenCV:
```bash
pip install opencv-python-headless
```

### Images Not Displaying

Make sure the paths in `slides.md` are correct relative to the HTML file location. The `generate_slides.py` script should handle this automatically.

## GitHub Pages Deployment

To deploy your presentation to GitHub Pages:

1. **Run the setup script:**
   ```bash
   ./setup_github.sh
   ```

2. **Follow the instructions** or see `SETUP_GITHUB.md` for detailed steps.

3. **Your presentation will be available at:**
   ```
   https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
   ```

The `frames/` directory and `slides.md` are included in the repository so GitHub Pages can serve them. Video files in `videos/` are excluded by default (they're typically too large for git).

## Organizing Presentations in Directories

You can create multiple presentations, each in its own directory with its own URL.

### Create a New Presentation

```bash
# 1. Add videos to videos/ directory
cp your_video.mp4 videos/

# 2. Create presentation with a name
./create_presentation.sh AI

# 3. Access at: https://aykutfirat.github.io/REPOSITORY_NAME/AI/
```

### Update an Existing Presentation

```bash
# Add new videos, then update:
./update_presentation_dir.sh AI --push
```

See `PRESENTATION_DIRECTORIES.md` for detailed documentation on organizing multiple presentations.

## Weekly Updates

For updating your presentation weekly with new videos, see `WEEKLY_WORKFLOW.md` for a detailed guide.

**Quick update (single presentation):**
```bash
# Add new videos to videos/ directory, then:
./update_presentation.sh --push
```

**Quick update (named presentation):**
```bash
# Add new videos, then:
./update_presentation_dir.sh AI --push
```

## License

This project is provided as-is for personal use.

