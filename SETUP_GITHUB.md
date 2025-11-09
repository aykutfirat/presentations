# Setting Up GitHub and GitHub Pages

## Step 1: Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: Video to Reveal.js slides converter"
```

## Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository (e.g., `presentation-slides`)
3. **Don't** initialize it with a README, .gitignore, or license (we already have these)

## Step 3: Connect Local Repository to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repository name.

## Step 4: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings** (top menu)
3. Scroll down to **Pages** (in the left sidebar)
4. Under **Source**, select:
   - Branch: `main` (or `master`)
   - Folder: `/ (root)`
5. Click **Save**

## Step 5: Access Your Presentation

After a few minutes, your presentation will be available at:
```
https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
```

For example:
```
https://githubusername.github.io/presentation-slides/
```

## Important Notes

- **Frames and slides.md are included**: The `.gitignore` has been updated to include `frames/` and `slides.md` so they're committed to the repository. This is necessary for GitHub Pages to serve the images and markdown.

- **Regenerating slides**: If you regenerate frames or slides, remember to commit and push:
  ```bash
  git add frames/ slides.md
  git commit -m "Update slides and frames"
  git push
  ```

- **Video files**: The `videos/` directory is included in the repository. If your videos are large, consider using Git LFS or storing them elsewhere.

- **Private repositories**: GitHub Pages works with both public and private repositories (private repos require GitHub Pro/Team/Enterprise).

## Alternative: Use GitHub Actions

If you want to automatically regenerate slides on push, you can set up GitHub Actions. See `.github/workflows/deploy.yml` for an example workflow.

