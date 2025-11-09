#!/usr/bin/env python3
"""
Extract frames from MP4 video files to use as slide backgrounds.
This script extracts key frames or frames at regular intervals from video files.
"""

import os
import sys
import argparse
import cv2
import numpy as np
from pathlib import Path


def extract_frames(video_path, output_dir, interval=5, max_frames=None):
    """
    Extract frames from a video file.
    
    Args:
        video_path: Path to the input video file
        output_dir: Directory to save extracted frames
        interval: Extract every Nth second (default: 5)
        max_frames: Maximum number of frames to extract (None for all)
    """
    video_path = Path(video_path)
    output_dir = Path(output_dir)
    
    if not video_path.exists():
        print(f"Error: Video file not found: {video_path}")
        return []
    
    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Open video
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        print(f"Error: Could not open video file: {video_path}")
        return []
    
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / fps if fps > 0 else 0
    
    print(f"Video: {video_path.name}")
    print(f"  FPS: {fps:.2f}")
    print(f"  Duration: {duration:.2f} seconds")
    print(f"  Total frames: {total_frames}")
    
    # Calculate frame intervals
    frame_interval = int(fps * interval)
    
    extracted_frames = []
    frame_count = 0
    saved_count = 0
    
    # Create a subdirectory for this video
    video_output_dir = output_dir / video_path.stem
    video_output_dir.mkdir(exist_ok=True)
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Extract frame at intervals
        if frame_count % frame_interval == 0:
            if max_frames and saved_count >= max_frames:
                break
            
            # Save frame
            timestamp = frame_count / fps
            frame_filename = f"frame_{saved_count:04d}_t{timestamp:.2f}s.jpg"
            frame_path = video_output_dir / frame_filename
            
            # Resize if too large (optional, for optimization)
            height, width = frame.shape[:2]
            if width > 1920:
                scale = 1920 / width
                new_width = 1920
                new_height = int(height * scale)
                frame = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)
            
            cv2.imwrite(str(frame_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
            extracted_frames.append(frame_path)
            saved_count += 1
            print(f"  Extracted frame {saved_count}: {frame_filename}")
        
        frame_count += 1
    
    cap.release()
    print(f"  Total frames extracted: {saved_count}\n")
    return extracted_frames


def calculate_frame_difference(frame1, frame2):
    """
    Calculate the difference between two frames using multiple metrics.
    
    Returns:
        mse: Mean Squared Error
        ssim_like: Structural similarity approximation
    """
    # Convert to grayscale for comparison
    gray1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
    gray2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)
    
    # Calculate MSE
    mse = np.mean((gray1 - gray2) ** 2)
    
    # Calculate histogram difference
    hist1 = cv2.calcHist([gray1], [0], None, [256], [0, 256])
    hist2 = cv2.calcHist([gray2], [0], None, [256], [0, 256])
    hist_diff = cv2.compareHist(hist1, hist2, cv2.HISTCMP_CORREL)
    
    return mse, hist_diff


def extract_different_frames(video_path, output_dir, threshold=30.0, min_hist_diff=0.95, resize_width=640):
    """
    Extract only frames that are different from the previous frame.
    This captures all scene changes, transitions, and meaningful differences.
    
    Args:
        video_path: Path to the input video file
        output_dir: Directory to save extracted frames
        threshold: MSE threshold for considering frames different (default: 30.0)
                  Lower values = more sensitive (more frames)
        min_hist_diff: Minimum histogram correlation difference (default: 0.95)
                      Lower values = more sensitive (more frames)
        resize_width: Width to resize frames for comparison (default: 640)
                     Smaller = faster comparison but less accurate
    """
    video_path = Path(video_path)
    output_dir = Path(output_dir)
    
    if not video_path.exists():
        print(f"Error: Video file not found: {video_path}")
        return []
    
    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Open video
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        print(f"Error: Could not open video file: {video_path}")
        return []
    
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / fps if fps > 0 else 0
    
    print(f"Video: {video_path.name}")
    print(f"  FPS: {fps:.2f}")
    print(f"  Duration: {duration:.2f} seconds")
    print(f"  Total frames: {total_frames}")
    print(f"  Extracting frames with significant changes...")
    print(f"  Threshold: MSE > {threshold}, Histogram diff < {min_hist_diff}")
    
    extracted_frames = []
    frame_count = 0
    saved_count = 0
    last_saved_frame = None
    
    # Create a subdirectory for this video
    video_output_dir = output_dir / video_path.stem
    video_output_dir.mkdir(exist_ok=True)
    
    # Progress tracking
    last_progress = 0
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_count += 1
        timestamp = frame_count / fps
        
        # Resize for comparison (faster processing)
        height, width = frame.shape[:2]
        if width > resize_width:
            scale = resize_width / width
            comparison_width = resize_width
            comparison_height = int(height * scale)
            frame_resized = cv2.resize(frame, (comparison_width, comparison_height), interpolation=cv2.INTER_AREA)
        else:
            frame_resized = frame.copy()
        
        # Save first frame always
        if last_saved_frame is None:
            # Resize original frame for saving if needed
            if width > 1920:
                scale = 1920 / width
                new_width = 1920
                new_height = int(height * scale)
                frame_to_save = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)
            else:
                frame_to_save = frame.copy()
            
            frame_filename = f"frame_{saved_count:04d}_t{timestamp:.2f}s.jpg"
            frame_path = video_output_dir / frame_filename
            cv2.imwrite(str(frame_path), frame_to_save, [cv2.IMWRITE_JPEG_QUALITY, 95])
            extracted_frames.append(frame_path)
            last_saved_frame = frame_resized.copy()
            saved_count += 1
            print(f"  Saved frame {saved_count} (first frame): {frame_filename}")
        else:
            # Compare with last saved frame
            mse, hist_corr = calculate_frame_difference(last_saved_frame, frame_resized)
            
            # Check if frames are significantly different
            is_different = mse > threshold or hist_corr < min_hist_diff
            
            if is_different:
                # Resize original frame for saving if needed
                if width > 1920:
                    scale = 1920 / width
                    new_width = 1920
                    new_height = int(height * scale)
                    frame_to_save = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)
                else:
                    frame_to_save = frame.copy()
                
                frame_filename = f"frame_{saved_count:04d}_t{timestamp:.2f}s.jpg"
                frame_path = video_output_dir / frame_filename
                cv2.imwrite(str(frame_path), frame_to_save, [cv2.IMWRITE_JPEG_QUALITY, 95])
                extracted_frames.append(frame_path)
                last_saved_frame = frame_resized.copy()
                saved_count += 1
                
                if saved_count % 10 == 0 or saved_count == 1:
                    print(f"  Saved frame {saved_count}: {frame_filename} (MSE: {mse:.2f}, Hist: {hist_corr:.3f})")
        
        # Progress update every 10%
        progress = int((frame_count / total_frames) * 100)
        if progress >= last_progress + 10:
            print(f"  Progress: {progress}% ({frame_count}/{total_frames} frames processed, {saved_count} unique frames saved)")
            last_progress = progress
    
    cap.release()
    print(f"  Total frames processed: {frame_count}")
    print(f"  Unique frames extracted: {saved_count}")
    print(f"  Compression ratio: {saved_count/frame_count*100:.2f}%\n")
    return extracted_frames


def extract_key_frames(video_path, output_dir, num_frames=10):
    """
    Extract evenly distributed key frames from a video.
    
    Args:
        video_path: Path to the input video file
        output_dir: Directory to save extracted frames
        num_frames: Number of frames to extract (default: 10)
    """
    video_path = Path(video_path)
    output_dir = Path(output_dir)
    
    if not video_path.exists():
        print(f"Error: Video file not found: {video_path}")
        return []
    
    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Open video
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        print(f"Error: Could not open video file: {video_path}")
        return []
    
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    print(f"Video: {video_path.name}")
    print(f"  Total frames: {total_frames}")
    print(f"  Extracting {num_frames} key frames...")
    
    # Calculate frame indices to extract
    step = total_frames // (num_frames + 1)
    frame_indices = [step * (i + 1) for i in range(num_frames)]
    
    extracted_frames = []
    video_output_dir = output_dir / video_path.stem
    video_output_dir.mkdir(exist_ok=True)
    
    for i, frame_idx in enumerate(frame_indices):
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
        ret, frame = cap.read()
        
        if ret:
            timestamp = frame_idx / fps if fps > 0 else 0
            frame_filename = f"frame_{i:04d}_t{timestamp:.2f}s.jpg"
            frame_path = video_output_dir / frame_filename
            
            # Resize if too large
            height, width = frame.shape[:2]
            if width > 1920:
                scale = 1920 / width
                new_width = 1920
                new_height = int(height * scale)
                frame = cv2.resize(frame, (new_width, new_height), interpolation=cv2.INTER_AREA)
            
            cv2.imwrite(str(frame_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 95])
            extracted_frames.append(frame_path)
            print(f"  Extracted frame {i+1}/{num_frames}: {frame_filename}")
    
    cap.release()
    print(f"  Total frames extracted: {len(extracted_frames)}\n")
    return extracted_frames


def main():
    parser = argparse.ArgumentParser(description="Extract frames from MP4 video files")
    parser.add_argument("video", help="Path to video file or directory containing videos")
    parser.add_argument("-o", "--output", default="frames", help="Output directory for frames (default: frames)")
    parser.add_argument("-i", "--interval", type=int, default=5, help="Extract frame every N seconds (default: 5)")
    parser.add_argument("-n", "--num-frames", type=int, help="Number of key frames to extract (overrides interval)")
    parser.add_argument("-m", "--max-frames", type=int, help="Maximum number of frames to extract")
    parser.add_argument("-d", "--different", action="store_true", help="Extract only frames that are different (default: False)")
    parser.add_argument("-t", "--threshold", type=float, default=30.0, help="MSE threshold for different frames (default: 30.0, lower = more sensitive)")
    parser.add_argument("--hist-threshold", type=float, default=0.95, help="Histogram correlation threshold (default: 0.95, lower = more sensitive)")
    
    args = parser.parse_args()
    
    video_path = Path(args.video)
    output_dir = Path(args.output)
    
    video_files = []
    if video_path.is_file():
        if video_path.suffix.lower() in ['.mp4', '.avi', '.mov', '.mkv']:
            video_files = [video_path]
        else:
            print(f"Error: Not a supported video file: {video_path}")
            sys.exit(1)
    elif video_path.is_dir():
        video_files = sorted(list(video_path.glob("*.mp4"))) + \
                      sorted(list(video_path.glob("*.MP4"))) + \
                      sorted(list(video_path.glob("*.avi"))) + \
                      sorted(list(video_path.glob("*.mov")))
        # Sort all video files alphabetically by filename
        video_files = sorted(video_files, key=lambda x: x.name.lower())
    else:
        print(f"Error: Path not found: {video_path}")
        sys.exit(1)
    
    if not video_files:
        print(f"Error: No video files found in: {video_path}")
        sys.exit(1)
    
    print(f"Found {len(video_files)} video file(s) (processing in alphabetical order)\n")
    
    all_frames = []
    for video_file in video_files:
        if args.different:
            frames = extract_different_frames(video_file, output_dir, args.threshold, args.hist_threshold)
        elif args.num_frames:
            frames = extract_key_frames(video_file, output_dir, args.num_frames)
        else:
            frames = extract_frames(video_file, output_dir, args.interval, args.max_frames)
        all_frames.extend(frames)
    
    print(f"\nExtraction complete! Total frames extracted: {len(all_frames)}")
    print(f"Frames saved to: {output_dir}")


if __name__ == "__main__":
    main()

