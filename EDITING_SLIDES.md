# Editing Slide Content

To customize your presentation, edit the `slides.md` file in each presentation directory.

## File Location

For each presentation, edit:
- `AI/slides.md` - for the AI presentation
- `Week1/slides.md` - for the Week1 presentation
- etc.

## Slide Structure

Each slide in `slides.md` follows this format:

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

<!-- Add your slide content here -->
```

## Adding Content to Slides

You can add text, headings, lists, and more to any slide:

### Example 1: Add a Title

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

# My Slide Title

This is some content on the slide.
```

### Example 2: Add Multiple Elements

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

## Introduction

- Point 1
- Point 2
- Point 3

**Important note**: This is emphasized text
```

### Example 3: Add Text Overlay

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

<div style="background: rgba(0,0,0,0.7); padding: 20px; border-radius: 10px;">

# Slide Title

Content goes here with a semi-transparent dark background for readability.

</div>
```

## Styling Options

### Text Colors

Since slides have dark backgrounds, text is white by default. You can customize:

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

<span style="color: yellow;">Highlighted text</span>
<span style="color: #00ff00;">Green text</span>
```

### Text Background

Add a readable background to text:

```markdown
<div style="background: rgba(0,0,0,0.8); padding: 15px; border-radius: 5px;">

Your text here with dark background

</div>
```

### Positioning

```markdown
<div style="text-align: left; padding: 20px;">

Left-aligned content

</div>
```

## Markdown Support

You can use standard Markdown:

- **Bold text**: `**bold**`
- *Italic text*: `*italic*`
- Lists: `- item` or `1. item`
- Links: `[text](url)`
- Code: `` `code` ``

## Slide Transitions

You can customize transitions for individual slides:

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-transition="zoom" -->

Content here
```

Available transitions: `zoom`, `fade`, `slide`, `convex`, `concave`

## Background Options

### Cover (fill entire slide)

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="cover" -->
```

### Contain (fit within slide)

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-size="contain" -->
```

### Change Background Color

```markdown
<!-- .slide: data-background="frames/VideoName/frame_0000_t0.04s.jpg" data-background-color="white" -->
```

## After Editing

After editing `slides.md`:

1. **Save the file**
2. **Commit and push to GitHub**:
   ```bash
   git add AI/slides.md
   git commit -m "Update slide content"
   git push
   ```
3. **Or use the update script** (if you also want to regenerate frames):
   ```bash
   ./process_current.sh
   ```

## Tips

- **Text readability**: Use dark semi-transparent backgrounds for text over images
- **Consistency**: Keep styling consistent across slides
- **Content placement**: Text appears centered by default, use `<div>` for custom alignment
- **Testing**: Test locally with `python3 -m http.server 8000` before pushing

## Example: Complete Slide with Content

```markdown
<!-- .slide: data-background="frames/A_Fighting_Fire_with_Data/frame_0000_t0.04s.jpg" data-background-size="contain" data-background-color="black" -->

<div style="background: rgba(0,0,0,0.75); padding: 30px; border-radius: 10px; max-width: 80%; margin: 0 auto;">

# Fighting Fire with Data

## Key Points

- Data-driven decision making
- Real-time analytics
- Predictive modeling

**Result**: Improved response times

</div>
```

## Regenerating Slides

If you regenerate slides (run `./process_current.sh`), your custom content will be overwritten. To preserve custom content:

1. **Edit after regeneration**: Run the script, then edit `slides.md`
2. **Use a separate content file**: Create your own markdown with custom content and merge manually
3. **Backup your edits**: Before regenerating, commit your custom changes

## Best Practice

1. Process videos and generate slides first
2. Then edit `slides.md` to add your custom content
3. Commit the customized slides
4. When updating videos, regenerate and re-add your custom content

