# Weekly Presentation Workflow

This guide explains how to update your presentation weekly with new videos.

## Quick Update (Recommended)

The easiest way to update your presentation weekly:

```bash
./update_presentation.sh --push
```

This will:
1. Extract frames from videos in the `videos/` directory
2. Generate new slides
3. Commit changes to git
4. Push to GitHub (which updates GitHub Pages)

## Step-by-Step Weekly Workflow

### 1. Add New Videos

Place your new MP4 video files in the `videos/` directory:
```bash
cp /path/to/new/video.mp4 videos/
```

### 2. Update Presentation

Run the update script:
```bash
./update_presentation.sh -t "Week 1 Presentation" --push
```

Or with custom settings:
```bash
./update_presentation.sh -t "Week 1" --threshold 25.0 --push
```

### 3. Verify Locally (Optional)

Before pushing, you can preview locally:
```bash
python3 -m http.server 8000
# Open http://localhost:8000/index.html
```

### 4. Push to GitHub

If you didn't use `--push` flag:
```bash
git push
```

Your presentation will be automatically updated on GitHub Pages within a few minutes.

## Options

### Update Script Options

- `-t, --title TITLE`: Set presentation title
- `--threshold FLOAT`: Adjust frame extraction sensitivity (lower = more frames)
- `--hist-threshold FLOAT`: Adjust histogram sensitivity
- `--no-commit`: Don't automatically commit (manual commit)
- `--push`: Automatically push to GitHub after committing

### Examples

**Basic update:**
```bash
./update_presentation.sh --push
```

**Update with custom title:**
```bash
./update_presentation.sh -t "Week 2: Advanced Topics" --push
```

**Update without auto-commit (manual control):**
```bash
./update_presentation.sh --no-commit
git add frames/ slides.md
git commit -m "Week 3 presentation"
git push
```

**More sensitive frame extraction (more slides):**
```bash
./update_presentation.sh --threshold 20.0 --hist-threshold 0.97 --push
```

## Organizing Multiple Presentations

### Option 1: Overwrite Current Presentation (Recommended)

Simply update the videos and run the script. The presentation will show the latest videos.

**Pros:**
- Simple workflow
- One URL to share
- Always shows current content

**Cons:**
- Loses previous presentations (unless you check git history)

### Option 2: Keep Historical Presentations

Create branches or directories for each week:

```bash
# Create a branch for this week
git checkout -b week-1
./update_presentation.sh --push

# Next week
git checkout main
git checkout -b week-2
./update_presentation.sh --push
```

Or create separate directories:
- `presentations/week-1/`
- `presentations/week-2/`
- etc.

### Option 3: Archive Old Presentations

Before updating, create an archive:

```bash
# Archive current presentation
mkdir -p archive/$(date +%Y-%m-%d)
cp slides.md archive/$(date +%Y-%m-%d)/
cp -r frames archive/$(date +%Y-%m-%d)/
git add archive/
git commit -m "Archive presentation for $(date +%Y-%m-%d)"

# Update with new videos
./update_presentation.sh --push
```

## Cleaning Up Old Videos

After processing, you can remove videos from the `videos/` directory to save space:

```bash
# Remove processed videos (they're not needed after frames are extracted)
rm videos/*.mp4
```

**Note:** Videos are excluded from git by default (in `.gitignore`), so they won't be pushed to GitHub anyway.

## Troubleshooting

### Videos Not Processing

- Check that videos are in the `videos/` directory
- Verify video format is supported (.mp4, .avi, .mov)
- Check file permissions

### Frames Not Extracting

- Lower the threshold: `--threshold 20.0`
- Check video file integrity
- Verify OpenCV is installed: `pip install opencv-python`

### GitHub Pages Not Updating

- Wait a few minutes (GitHub Pages can take 1-5 minutes to update)
- Check repository Settings > Pages to verify it's enabled
- Verify the push was successful: `git log --oneline`

### Too Many/Few Slides

- Adjust threshold: Lower = more slides, Higher = fewer slides
- Default: `--threshold 30.0`
- Try: `--threshold 20.0` for more slides, `--threshold 40.0` for fewer

## Best Practices

1. **Test locally first**: Run without `--push` to preview
2. **Use descriptive titles**: Include week number or date in title
3. **Commit regularly**: Each week should be a separate commit
4. **Keep videos organized**: Consider organizing videos by week in subdirectories
5. **Monitor GitHub Pages**: Check that updates are live after pushing

## Automation (Advanced)

You can automate the weekly update with a cron job:

```bash
# Edit crontab
crontab -e

# Add line to run every Monday at 9 AM
0 9 * * 1 cd /path/to/presentationSlides && ./update_presentation.sh --push
```

Or use GitHub Actions to automatically process videos when they're added to the repository (requires additional setup).

