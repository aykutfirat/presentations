# Organizing Presentations in Directories

You can organize multiple presentations in separate directories. Each presentation gets its own URL.

## Creating a New Presentation

### Step 1: Add Videos
Place your video files in the `videos/` directory:
```bash
cp your_video.mp4 videos/
```

### Step 2: Create Presentation
```bash
./create_presentation.sh AI
```

This creates a directory structure:
```
AI/
  ├── index.html
  ├── slides.md
  └── frames/
      ├── Video1/
      │   └── frame_*.jpg
      └── Video2/
          └── frame_*.jpg
```

### Step 3: Access Your Presentation
After pushing to GitHub, access it at:
```
https://aykutfirat.github.io/REPOSITORY_NAME/AI/
```

## Updating an Existing Presentation

To update a presentation with new videos:

```bash
# 1. Add new videos to videos/ directory
cp new_video.mp4 videos/

# 2. Update the presentation
./update_presentation_dir.sh AI --push
```

## Multiple Presentations

You can create as many presentations as you want:

```bash
./create_presentation.sh AI
./create_presentation.sh Week1
./create_presentation.sh Week2
./create_presentation.sh "Machine Learning"
```

Each will be accessible at:
- `https://aykutfirat.github.io/REPOSITORY_NAME/AI/`
- `https://aykutfirat.github.io/REPOSITORY_NAME/Week1/`
- `https://aykutfirat.github.io/REPOSITORY_NAME/Week2/`
- `https://aykutfirat.github.io/REPOSITORY_NAME/Machine%20Learning/`

## Main Index Page

The main `index.html` automatically lists all your presentations. Access it at:
```
https://aykutfirat.github.io/REPOSITORY_NAME/
```

## Workflow Example

### Weekly Presentations

```bash
# Week 1
./create_presentation.sh "Week1-Intro" --push

# Week 2
./create_presentation.sh "Week2-Advanced" --push

# Week 3 - Update Week 2 with new videos
./update_presentation_dir.sh "Week2-Advanced" --push
```

### Topic-Based Presentations

```bash
./create_presentation.sh AI
./create_presentation.sh "Computer Vision"
./create_presentation.sh "Natural Language Processing"
```

## Directory Structure

```
presentationSlides/
├── index.html              # Main index listing all presentations
├── videos/                 # Video files (not committed to git)
├── AI/                     # Presentation: AI
│   ├── index.html
│   ├── slides.md
│   └── frames/
├── Week1/                  # Presentation: Week1
│   ├── index.html
│   ├── slides.md
│   └── frames/
└── ...
```

## Notes

- **Video files**: Videos in `videos/` are excluded from git (too large)
- **Frames and slides**: Each presentation's frames and slides are committed to git
- **Automatic indexing**: The main `index.html` automatically lists all presentations
- **Independent updates**: Each presentation can be updated independently
- **Alphabetical ordering**: Slides within each presentation are ordered alphabetically by video name

## Scripts

- `create_presentation.sh NAME` - Create a new presentation
- `update_presentation_dir.sh NAME` - Update an existing presentation
- Both scripts support `--push` to automatically push to GitHub

## Customization

You can customize each presentation:
- Edit `PRESENTATION_NAME/slides.md` to add text content
- Edit `PRESENTATION_NAME/index.html` to change theme or settings
- Each presentation is independent

