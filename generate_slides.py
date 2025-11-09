#!/usr/bin/env python3
"""
Generate reveal.js markdown presentation from extracted video frames.
"""

import os
import argparse
from pathlib import Path
from collections import defaultdict


def generate_reveal_markdown(frames_dir, output_file, title="Presentation", theme="white"):
    """
    Generate a reveal.js markdown file from extracted frames.
    
    Args:
        frames_dir: Directory containing extracted frames
        output_file: Output markdown file path
        title: Presentation title
        theme: Reveal.js theme (default, black, white, league, beige, sky, night, serif, simple, solarized)
    """
    frames_dir = Path(frames_dir)
    output_file = Path(output_file)
    
    if not frames_dir.exists():
        print(f"Error: Frames directory not found: {frames_dir}")
        return
    
    # Find all image files
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
    image_files = []
    
    # Group by video directory if frames are organized by video
    video_dirs = [d for d in frames_dir.iterdir() if d.is_dir()]
    
    if video_dirs:
        # Frames organized by video - sort alphabetically by video name
        for video_dir in sorted(video_dirs, key=lambda x: x.name.lower()):
            video_images = []
            for ext in image_extensions:
                video_images.extend(sorted(video_dir.glob(f"*{ext}")))
                video_images.extend(sorted(video_dir.glob(f"*{ext.upper()}")))
            if video_images:
                image_files.append((video_dir.name, video_images))
    else:
        # All frames in the root directory
        all_images = []
        for ext in image_extensions:
            all_images.extend(sorted(frames_dir.glob(f"*{ext}")))
            all_images.extend(sorted(frames_dir.glob(f"*{ext.upper()}")))
        if all_images:
            image_files.append(("All Videos", all_images))
    
    if not image_files:
        print(f"Error: No image files found in: {frames_dir}")
        return
    
    # Generate markdown content - start directly with frame slides, no intro/exit slides
    markdown_lines = []
    
    # Add slides for each image (no title or section headers)
    first_slide = True
    for video_name, images in image_files:
        for img_path in images:
            # Use relative path from output file to image
            # If output_file is in a subdirectory, paths should be relative to that directory
            relative_path = os.path.relpath(img_path, output_file.parent)
            # Replace backslashes with forward slashes for cross-platform compatibility
            relative_path = relative_path.replace('\\', '/')
            # Ensure path uses forward slashes for web compatibility
            if not relative_path.startswith('./') and not relative_path.startswith('../'):
                # If path doesn't start with ./ or ../, it might need adjustment
                pass
            
            # Don't add separator before first slide
            if not first_slide:
                markdown_lines.append("---\n")
                markdown_lines.append("\n")
            else:
                first_slide = False
            
            markdown_lines.append(f'<!-- .slide: data-background="{relative_path}" data-background-size="contain" data-background-color="black" -->\n')
            markdown_lines.append("\n")
            markdown_lines.append("<!-- Add your slide content here -->\n")
            markdown_lines.append("\n")
    
    # Write markdown file
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(''.join(markdown_lines))
    
    print(f"Generated reveal.js markdown: {output_file}")
    print(f"Total slides: {sum(len(images) for _, images in image_files)}")


def main():
    parser = argparse.ArgumentParser(description="Generate reveal.js markdown from extracted frames")
    parser.add_argument("frames_dir", help="Directory containing extracted frames")
    parser.add_argument("-o", "--output", default="slides.md", help="Output markdown file (default: slides.md)")
    parser.add_argument("-t", "--title", default="Presentation", help="Presentation title (default: Presentation)")
    parser.add_argument("--theme", default="white", help="Reveal.js theme (default: white)")
    
    args = parser.parse_args()
    
    generate_reveal_markdown(args.frames_dir, args.output, args.title, args.theme)


if __name__ == "__main__":
    main()

