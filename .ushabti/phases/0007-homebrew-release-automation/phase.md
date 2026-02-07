# Phase 0007: Homebrew Release Automation

## Intent

Implement automated binary distribution via Homebrew by creating a GitHub Actions workflow that builds universal macOS binaries and updates a Homebrew tap repository. This eliminates manual release steps and ensures consistent, reproducible releases.

## Scope

### In Scope

- GitHub Actions workflow that triggers on version tags (`v*`)
- Universal binary build (arm64 + x86_64) using Swift Package Manager
- Tarball creation and GitHub Release publishing
- Automated Homebrew tap repository updates (URL and SHA256)
- Homebrew formula for binary distribution (not source build)
- Formula test that verifies binary exists at installed path
- README update with Homebrew installation instructions

### Out of Scope

- Code signing or notarization (Homebrew strips quarantine attributes)
- Source-based Homebrew formula (binary distribution only)
- Release from non-tag commits
- Manual release process documentation
- CI for pull requests or non-release commits

## Constraints

- L25 — Single Binary Output: Already satisfied by current build configuration
- L26 — Semantic Versioning: Tags must follow semver (MAJOR.MINOR.PATCH)
- L28 — README Completeness: Must update README with Homebrew install instructions
- L29 — Documentation Reconciliation: Update docs if workflow adds new systems
- GitHub Actions must use macOS runner (Swift + macOS frameworks required)
- Universal binary path is `.build/apple/Products/Release/spotlight-mcp`
- Tap repository: `github.com/adamrdrew/homebrew-spotlight-mcp`
- GitHub secret `HOMEBREW_SPOTLIGHT_MCP_PAT` provides tap repo write access

## Acceptance Criteria

1. Pushing a semver tag like `v0.1.0` triggers GitHub Actions workflow
2. Workflow builds universal binary on macOS runner
3. Workflow creates GitHub Release with tarball attached
4. Workflow clones tap repo, updates formula URL and SHA256, commits and pushes
5. `brew tap adamrdrew/spotlight-mcp && brew install spotlight-mcp` installs the binary
6. Installed binary runs correctly (`spotlight-mcp` executes without error)
7. README includes Homebrew installation instructions
8. Formula includes test that verifies binary exists at installed path

## Resolved Questions

1. **CLI flags**: The binary accepts no flags (`--version`, `--help`, etc.). Formula test will verify the binary exists at the installed path using `assert_predicate`.
2. **CHANGELOG validation**: Out of scope for this phase. No CHANGELOG step in the workflow.
3. **Initial version tag**: `v0.1.0`.

## Risks / Notes

- The workflow uses `sed` to update the formula URL and SHA256 (Option B from analysis)
- No code signing means users will need to allow the binary on first run (standard for Homebrew binaries)
- Universal binary build command has been verified locally
- The binary has no runtime dependencies beyond macOS system frameworks
- Workflow requires manual tag push to trigger (intentional safety measure)
