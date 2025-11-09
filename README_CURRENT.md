# Processing Videos from videos/current/

This workflow automatically processes videos from `videos/current/` and creates/updates presentations.

## Directory Structure

```
videos/
  current/
    AI/                    # Presentation name: "AI"
      video1.mp4
      video2.mp4
    Week1/                 # Presentation name: "Week1"
      video1.mp4
      video2.mp4
```

## Usage

### Basic Usage

Simply run:
```bash
./process_current.sh
```

This will:
1. Find all subdirectories in `videos/current/` (e.g., `AI`, `Week1`)
2. Process videos in each directory (in alphabetical order)
3. Create/update presentations with those names
4. Commit and push to GitHub automatically

### Options

```bash
# Don't push to GitHub automatically
./process_current.sh --no-push

# Adjust frame extraction sensitivity
./process_current.sh --threshold 25.0 --hist-threshold 0.97
```

## Workflow

1. **Place videos**: Put videos in `videos/current/PRESENTATION_NAME/`
   ```bash
   mkdir -p videos/current/AI
   cp your_videos/*.mp4 videos/current/AI/
   ```

2. **Process**: Run the script
   ```bash
   ./process_current.sh
   ```

3. **Access**: Your presentation will be available at:
   ```
   https://aykutfirat.github.io/presentations/AI/
   ```

## Video Processing

- Videos are processed in **alphabetical order** by filename
- Only frames that are **different** are extracted (scene changes)
- Videos are **not committed to git** (they're excluded via .gitignore)
- If a presentation with the same name exists, it will be **overwritten**

## Examples

### Single Presentation

```bash
# Create directory and add videos
mkdir -p videos/current/AI
cp video1.mp4 video2.mp4 videos/current/AI/

# Process
./process_current.sh
```

### Multiple Presentations

```bash
# Create multiple presentation directories
mkdir -p videos/current/AI
mkdir -p videos/current/Week1
mkdir -p videos/current/MachineLearning

# Add videos to each
cp ai_videos/*.mp4 videos/current/AI/
cp week1_videos/*.mp4 videos/current/Week1/
cp ml_videos/*.mp4 videos/current/MachineLearning/

# Process all at once
./process_current.sh
```

All presentations will be created/updated and pushed to GitHub.

## Notes

- **Videos are not committed**: Videos in `videos/current/` are excluded from git
- **Overwrites existing**: If a presentation with the same name exists, it will be replaced
- **Alphabetical order**: Videos are processed in alphabetical order by filename
- **Automatic push**: By default, changes are pushed to GitHub automatically

## Troubleshooting

### Videos Not Processing

- Check that videos are in `videos/current/PRESENTATION_NAME/`
- Verify video format is supported (.mp4, .avi, .mov, .mkv)
- Check file permissions

### Too Many/Few Slides

- Adjust threshold: `--threshold 20.0` (lower = more slides)
- Adjust histogram: `--hist-threshold 0.97` (lower = more slides)

### Git Push Fails

- Check SSH key is set up: `ssh -T git@github.com`
- Or use `--no-push` and push manually: `git push`

