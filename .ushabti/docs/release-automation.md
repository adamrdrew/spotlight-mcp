# Release Automation

## Overview

Automated binary distribution via Homebrew using GitHub Actions. When a semver tag is pushed, the workflow builds a universal macOS binary and updates the Homebrew tap repository.

## Workflow

Location: `.github/workflows/release.yml`

Triggered by: `git push origin vX.Y.Z` (where X.Y.Z follows semantic versioning)

Steps:
1. Build universal binary (arm64 + x86_64) using Swift Package Manager
2. Create tarball: `spotlight-mcp-vX.Y.Z-universal.tar.gz`
3. Compute SHA256 hash
4. Create GitHub Release with tarball attachment
5. Clone tap repository using `HOMEBREW_SPOTLIGHT_MCP_PAT` secret
6. Update formula URL and SHA256 using sed
7. Commit and push formula changes

## Homebrew Tap

Repository: `github.com/adamrdrew/homebrew-spotlight-mcp`
Formula location: `Formula/spotlight-mcp.rb`

The formula installs the prebuilt universal binary (not a source build).

Test: `assert_predicate bin/"spotlight-mcp", :executable?`

## Dependencies

- macOS runner (requires Swift toolchain and macOS frameworks)
- GitHub secret `HOMEBREW_SPOTLIGHT_MCP_PAT` (fine-grained PAT with Contents read/write on tap repo)

## No Code Signing

The binary is not code-signed or notarized. Homebrew strips quarantine attributes, but users may see a macOS prompt on first run. This is standard for Homebrew binaries.

## Installation

Users install via:
```bash
brew tap adamrdrew/spotlight-mcp
brew install spotlight-mcp
```

Binary installed to `/opt/homebrew/bin/spotlight-mcp` (Apple Silicon) or `/usr/local/bin/spotlight-mcp` (Intel).
