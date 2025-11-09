#!/usr/bin/env python3
"""
Generate reveal.js markdown presentation from extracted video frames.
"""

import os
import argparse
import cv2
import numpy as np
from pathlib import Path
from collections import defaultdict


def are_frames_similar(img1_path, img2_path, similarity_threshold=0.98):
    """
    Check if two images are very similar (potential duplicates).
    
    Args:
        img1_path: Path to first image
        img2_path: Path to second image
        similarity_threshold: Histogram correlation threshold (default: 0.98)
                            Higher = more strict (fewer duplicates detected)
    
    Returns:
        True if images are similar, False otherwise
    """
    try:
        img1 = cv2.imread(str(img1_path))
        img2 = cv2.imread(str(img2_path))
        
        if img1 is None or img2 is None:
            return False
        
        # Resize to same size for comparison
        height = min(img1.shape[0], img2.shape[0])
        width = min(img1.shape[1], img2.shape[1])
        img1_resized = cv2.resize(img1, (width, height))
        img2_resized = cv2.resize(img2, (width, height))
        
        # Convert to grayscale
        gray1 = cv2.cvtColor(img1_resized, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(img2_resized, cv2.COLOR_BGR2GRAY)
        
        # Calculate histogram correlation
        hist1 = cv2.calcHist([gray1], [0], None, [256], [0, 256])
        hist2 = cv2.calcHist([gray2], [0], None, [256], [0, 256])
        hist_corr = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
        
        # Calculate MSE
        mse = np.mean((gray1 - gray2) ** 2)
        
        # Consider similar if high correlation AND low MSE
        is_similar = hist_corr > similarity_threshold and mse < 100
        
        return is_similar
    except Exception as e:
        # If comparison fails, assume not similar
        return False


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
    
    # Collect all images in order, filtering out duplicates
    all_images = []
    for video_name, images in image_files:
        all_images.extend(images)
    
    # Filter out consecutive duplicates
    filtered_images = []
    previous_image = None
    duplicate_count = 0
    
    for img_path in all_images:
        if previous_image is None:
            # First image - always include
            filtered_images.append(img_path)
            previous_image = img_path
        else:
            # Check if this image is similar to the previous one
            if are_frames_similar(previous_image, img_path):
                duplicate_count += 1
                # Skip this duplicate
                continue
            else:
                # Not a duplicate - include it
                filtered_images.append(img_path)
                previous_image = img_path
    
    if duplicate_count > 0:
        print(f"  Filtered out {duplicate_count} duplicate/consecutive similar frames")
    
    # Generate slides from filtered images
    first_slide = True
    for img_path in filtered_images:
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

