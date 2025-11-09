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


def are_frames_similar(img1_path, img2_path, similarity_threshold=0.92, mse_threshold=200):
    """
    Check if two images are very similar (potential duplicates).
    Also filters out black/dark frames.
    
    Args:
        img1_path: Path to first image
        img2_path: Path to second image
        similarity_threshold: Histogram correlation threshold (default: 0.95)
                            Higher = more strict (fewer duplicates detected)
        mse_threshold: Maximum MSE for considering frames similar (default: 150)
    
    Returns:
        True if images are similar or if either is black, False otherwise
    """
    try:
        img1 = cv2.imread(str(img1_path))
        img2 = cv2.imread(str(img2_path))
        
        if img1 is None or img2 is None:
            return False
        
        # Resize to same size for comparison (use smaller size for speed)
        height = min(img1.shape[0], img2.shape[0], 480)
        width = min(img1.shape[1], img2.shape[1], 640)
        img1_resized = cv2.resize(img1, (width, height))
        img2_resized = cv2.resize(img2, (width, height))
        
        # Convert to grayscale
        gray1 = cv2.cvtColor(img1_resized, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(img2_resized, cv2.COLOR_BGR2GRAY)
        
        # Check if either frame is too dark/black
        avg_bright1 = np.mean(gray1)
        avg_bright2 = np.mean(gray2)
        std_bright1 = np.std(gray1)
        std_bright2 = np.std(gray2)
        
        # If either frame is very dark and low contrast, consider it a duplicate to filter out
        is_black1 = avg_bright1 < 50 and std_bright1 < 20
        is_black2 = avg_bright2 < 50 and std_bright2 < 20
        
        # If both are black/dark, they're similar
        if is_black1 and is_black2:
            return True
        
        # If one is black and the other is not very different (also dark), filter it
        if (is_black1 or is_black2) and (avg_bright1 < 80 or avg_bright2 < 80):
            return True
        
        # Calculate histogram correlation
        hist1 = cv2.calcHist([gray1], [0], None, [256], [0, 256])
        hist2 = cv2.calcHist([gray2], [0], None, [256], [0, 256])
        hist_corr = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
        
        # Calculate MSE (mean squared error)
        mse = np.mean((gray1 - gray2) ** 2)
        
        # Calculate absolute difference
        abs_diff = np.mean(np.abs(gray1.astype(float) - gray2.astype(float)))
        
        # Consider frames similar if:
        # 1. High histogram correlation AND low MSE (similar color distribution and pixel values)
        # 2. Low absolute difference (very similar pixel-wise)
        # 3. Very high histogram correlation (almost identical images)
        is_similar_hist_mse = hist_corr > similarity_threshold and mse < mse_threshold
        is_similar_abs_diff = abs_diff < 15  # Very low absolute difference
        is_very_similar_hist = hist_corr > 0.98  # Almost identical histogram
        
        return is_similar_hist_mse or is_similar_abs_diff or is_very_similar_hist
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
    
    # Filter out consecutive duplicates and black/dark frames
    filtered_images = []
    previous_image = None
    duplicate_count = 0
    black_frame_count = 0
    
    def is_black_frame(img_path):
        """Check if a frame is too dark/black to be useful."""
        try:
            img = cv2.imread(str(img_path))
            if img is None:
                return True
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            avg_brightness = np.mean(gray)
            std_brightness = np.std(gray)
            # Consider dark/black if:
            # 1. Very dark and low contrast (black screen)
            # 2. Moderately dark with very low contrast (fade to black)
            # 3. Very low average brightness (mostly black)
            is_very_dark = avg_brightness < 50 and std_brightness < 20
            is_dark_low_contrast = avg_brightness < 80 and std_brightness < 25
            is_mostly_black = avg_brightness < 60
            return is_very_dark or is_dark_low_contrast or is_mostly_black
        except:
            return False
    
    for img_path in all_images:
        # First, check if this frame is too dark/black
        if is_black_frame(img_path):
            black_frame_count += 1
            continue
        
        if previous_image is None:
            # First image - include it (already checked it's not black)
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
    
    if duplicate_count > 0 or black_frame_count > 0:
        msg_parts = []
        if black_frame_count > 0:
            msg_parts.append(f"{black_frame_count} black/dark frames")
        if duplicate_count > 0:
            msg_parts.append(f"{duplicate_count} duplicate frames")
        print(f"  Filtered out: {', '.join(msg_parts)}")
    
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
    
    total_original = sum(len(images) for _, images in image_files)
    total_filtered = len(filtered_images)
    
    print(f"Generated reveal.js markdown: {output_file}")
    print(f"Total slides: {total_filtered} (from {total_original} frames)")


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

