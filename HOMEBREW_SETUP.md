# Publishing Snappy to Homebrew

This guide explains how to make Snappy installable via Homebrew.

## Prerequisites

- A GitHub account
- Your Snappy repository is public on GitHub
- You have push access to create releases

## Step-by-Step Guide

### 1. Create a GitHub Release

First, tag and push a release:

```bash
# Make sure all changes are committed
git add .
git commit -m "Release v1.0.0"

# Create and push the tag
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

### 2. Get the Release Tarball SHA256

Calculate the SHA256 hash of your release tarball:

```bash
curl -L https://github.com/YOURUSERNAME/Snappy/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
```

Copy the resulting hash (it will be a long hexadecimal string).

### 3. Create a Homebrew Tap Repository

Create a new GitHub repository named `homebrew-snappy` (the name MUST start with `homebrew-`).

### 4. Update and Add the Formula

1. Edit `Formula/snappy.rb` in your Snappy repository:
   - Replace `yourusername` with your actual GitHub username
   - Add the SHA256 hash from step 2 to the formula

```ruby
class Snappy < Formula
  desc "macOS window snapping utility with global hotkeys"
  homepage "https://github.com/YOURUSERNAME/Snappy"
  url "https://github.com/YOURUSERNAME/Snappy/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "YOUR_SHA256_HASH_HERE"
  license "MIT"
  # ... rest of the formula
end
```

2. Copy the formula to your tap repository:

```bash
cd /path/to/homebrew-snappy
cp /path/to/Snappy/Formula/snappy.rb ./snappy.rb
git add snappy.rb
git commit -m "Add Snappy formula v1.0.0"
git push origin main
```

### 5. Test Your Formula

Test that users can install from your tap:

```bash
# Uninstall if already installed
brew uninstall snappy 2>/dev/null || true

# Add your tap
brew tap YOURUSERNAME/snappy

# Install from tap
brew install snappy

# Test the installation
snappy --version

# Start the service
brew services start snappy
```

### 6. Users Can Now Install

Share these instructions with users:

```bash
brew tap YOURUSERNAME/snappy
brew install snappy
brew services start snappy
```

## Updating the Formula for New Releases

When you release a new version:

1. Create a new Git tag and release:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

2. Get the new SHA256:
   ```bash
   curl -L https://github.com/YOURUSERNAME/Snappy/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
   ```

3. Update the formula in your `homebrew-snappy` repository:
   - Change the `url` to the new version
   - Update the `sha256` with the new hash
   - Commit and push

4. Users can update with:
   ```bash
   brew update
   brew upgrade snappy
   brew services restart snappy
   ```

## Optional: Submit to Homebrew Core

To make Snappy available in the main Homebrew repository (so users don't need to tap):

1. Your formula must meet [Homebrew's requirements](https://docs.brew.sh/Acceptable-Formulae)
2. The project should be stable and well-maintained
3. Submit a PR to [Homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core)

This is optional - most users are happy to use taps!

## Troubleshooting

### Formula fails to build

Make sure:
- The tarball URL is correct and accessible
- The SHA256 matches exactly
- Swift version requirements are met (`depends_on xcode: ["14.0", :build]`)

### Installation succeeds but binary doesn't work

Check:
- The binary is executable: `ls -l /usr/local/bin/snappy`
- Run manually to see errors: `snappy`
- Check logs: `tail -f /tmp/snappy.err.log`

### Service won't start

```bash
# Check service status
brew services info snappy

# Try starting manually to see errors
snappy

# Check if port 42424 is already in use
lsof -i :42424
```

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Acceptable Formulae](https://docs.brew.sh/Acceptable-Formulae)
- [How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)

