# Steps

## Step 1: Create GitHub Actions Workflow File

**Intent**: Establish the GitHub Actions workflow structure that triggers on version tags.

**Work**:
- Create `.github/workflows/release.yml`
- Define workflow trigger: `push: tags: v*`
- Configure macOS runner (`macos-latest`)
- Add checkout step

**Done when**: Workflow file exists with trigger and checkout configured.

---

## Step 2: Add Universal Binary Build Job

**Intent**: Build a universal (arm64 + x86_64) binary using Swift Package Manager.

**Work**:
- Add build step: `swift build -c release --arch arm64 --arch x86_64`
- Verify output path: `.build/apple/Products/Release/spotlight-mcp`
- Extract tag name for naming tarball

**Done when**: Workflow includes universal binary build step with correct output path.

---

## Step 3: Create Release Tarball

**Intent**: Package the binary into a tarball for distribution.

**Work**:
- Create tarball naming convention: `spotlight-mcp-${TAG}-universal.tar.gz`
- Add step to tar the binary: `tar -czf spotlight-mcp-${TAG}-universal.tar.gz -C .build/apple/Products/Release spotlight-mcp`
- Compute SHA256 of tarball for formula update

**Done when**: Workflow creates tarball and computes SHA256 hash.

---

## Step 4: Create GitHub Release

**Intent**: Publish a GitHub Release with the tarball as an asset.

**Work**:
- Add GitHub release creation step using `gh release create` or Actions
- Attach tarball as release asset
- Use tag name as release title
- Include basic release notes or link to CHANGELOG.md

**Done when**: Workflow creates GitHub Release with tarball attached.

---

## Step 5: Clone and Update Homebrew Tap Repository

**Intent**: Update the Homebrew formula with new release URL and SHA256.

**Work**:
- Add step to clone tap repo using `HOMEBREW_SPOTLIGHT_MCP_PAT`
- Use `sed` to find/replace `url` line in `Formula/spotlight-mcp.rb`
- Use `sed` to find/replace `sha256` line with computed hash
- Verify sed replacements work correctly

**Done when**: Workflow clones tap repo and updates formula fields.

---

## Step 6: Commit and Push Formula Update

**Intent**: Commit formula changes and push to tap repository.

**Work**:
- Configure git user for commit (GitHub Actions bot)
- Commit formula update with message: "Update spotlight-mcp to ${TAG}"
- Push to tap repository using PAT

**Done when**: Workflow commits and pushes formula update.

---

## Step 7: Create Initial Homebrew Formula

**Intent**: Define the Homebrew formula in the tap repository.

**Work**:
- Create `Formula/spotlight-mcp.rb` in tap repo
- Set formula class name: `SpotlightMcp`
- Add description and homepage
- Add placeholder `url` and `sha256` (workflow will update these)
- Add `depends_on :macos`
- Add install step: `bin.install "spotlight-mcp"`
- Add test block: `assert_predicate bin/"spotlight-mcp", :executable?`

**Done when**: Formula file exists in tap repo with all required fields.

---

## Step 8: Test Workflow End-to-End

**Intent**: Verify the entire workflow functions correctly with a test tag.

**Work**:
- Push a test tag (e.g., `v0.0.1-test`)
- Verify workflow triggers and completes successfully
- Verify GitHub Release is created with tarball
- Verify tap formula is updated correctly
- Test `brew tap` and `brew install` locally

**Done when**: Full workflow executes successfully and binary installs via Homebrew.

---

## Step 9: Update README with Installation Instructions

**Intent**: Document Homebrew installation for users (satisfies L28).

**Work**:
- Add "Installation" section to README.md
- Document `brew tap adamrdrew/spotlight-mcp`
- Document `brew install spotlight-mcp`
- Add note about allowing binary on first run (no code signing)

**Done when**: README includes clear Homebrew installation instructions.

---

## Step 10: Reconcile Documentation

**Intent**: Update project documentation to reflect new release automation system (satisfies L29).

**Work**:
- Create `.ushabti/docs/release-automation.md` documenting the GitHub Actions workflow
- Update `.ushabti/docs/index.md` to include release automation in table of contents
- Document workflow steps, dependencies, and Homebrew tap details

**Done when**: Documentation includes release automation system details and index is updated.

---

## Step 11: Create CHANGELOG.md

**Intent**: Establish required CHANGELOG.md to satisfy L27 and support workflow release notes link.

**Work**:
- Create `CHANGELOG.md` at repository root
- Follow Keep a Changelog format (https://keepachangelog.com/)
- Add initial entry for v0.1.0 release with all features implemented in phases 1-4
- Document the release automation feature from this phase

**Done when**: CHANGELOG.md exists with initial v0.1.0 entry and follows standard format.

---

## Step 12: Fix Workflow CHANGELOG.md Reference

**Intent**: Ensure workflow release notes reference is consistent with phase scope decision.

**Work**:
- Either: Update workflow to remove CHANGELOG.md reference (keep release notes generic)
- Or: Add CHANGELOG.md creation to this phase scope
- Decision: Create CHANGELOG.md (Step 11) so the reference works

**Done when**: Workflow release notes reference matches actual CHANGELOG.md file existence.

---

## Step 13: Commit Formula Template to Tap Repository

**Intent**: Initialize the tap repository with the formula file so the workflow can update it.

**Work**:
- Manually clone `github.com/adamrdrew/homebrew-spotlight-mcp`
- Copy `FORMULA_TEMPLATE.rb` to `Formula/spotlight-mcp.rb`
- Commit with message: "Initial spotlight-mcp formula"
- Push to tap repository

**Done when**: Formula file exists at `Formula/spotlight-mcp.rb` in tap repo on GitHub.

---

## Step 14: Execute End-to-End Test

**Intent**: Verify complete workflow operation (Step 8 completion).

**Work**:
- Push test tag: `git tag v0.0.1-test && git push origin v0.0.1-test`
- Monitor GitHub Actions workflow execution
- Verify GitHub Release created with tarball
- Verify tap formula updated with correct URL and SHA256
- Execute locally: `brew tap adamrdrew/spotlight-mcp && brew install spotlight-mcp`
- Verify binary exists: `which spotlight-mcp`
- Verify binary is executable and runs: Test that it starts and accepts JSON-RPC

**Done when**: Complete workflow executes successfully, formula updates correctly, and binary installs and runs via Homebrew.
