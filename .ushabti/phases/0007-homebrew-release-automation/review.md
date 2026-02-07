# Review

Status: **REQUIRES FOLLOW-UP**

Phase returned to Builder for follow-up work. Four critical defects identified.

---

## Summary

Phase 0007 implements automated Homebrew binary distribution via GitHub Actions. The workflow structure, formula template, and documentation are well-designed and correctly implemented. However, review revealed four critical issues that prevent acceptance:

1. **L27 Violation**: CHANGELOG.md does not exist, but L27 requires it for all releases
2. **Incomplete Step 8**: End-to-end testing not performed, acceptance criteria unverified
3. **Process Gap**: Formula template must be committed to tap repo before workflow can function
4. **Internal Inconsistency**: Workflow references CHANGELOG.md but phase scope explicitly excluded it

The implementation work (steps 1-7, 9-10) is solid. The follow-up work is straightforward and well-defined.

---

## Verified

### Workflow Implementation (Steps 1-6)
- ✓ `.github/workflows/release.yml` exists and is correctly structured
- ✓ Triggers on `v*` tags as specified in acceptance criterion 1
- ✓ Uses macOS runner (required for Swift + macOS frameworks)
- ✓ Universal binary build command correct: `swift build -c release --arch arm64 --arch x86_64`
- ✓ Binary path verified: `.build/apple/Products/Release/spotlight-mcp`
- ✓ Tag extraction implemented correctly using GITHUB_OUTPUT
- ✓ Tarball naming follows specified pattern: `spotlight-mcp-${TAG}-universal.tar.gz`
- ✓ SHA256 computation implemented and captured to GITHUB_OUTPUT
- ✓ GitHub Release creation uses `gh` CLI with tarball attachment (AC 3)
- ✓ Tap repository clone uses correct secret: `HOMEBREW_SPOTLIGHT_MCP_PAT`
- ✓ Formula update uses sed for URL replacement (AC 4)
- ✓ Formula update uses sed for SHA256 replacement (AC 4)
- ✓ Git configuration uses GitHub Actions bot identity
- ✓ Commit message follows pattern: "Update spotlight-mcp to ${TAG}"
- ✓ Push authentication uses PAT correctly

### Formula Template (Step 7)
- ✓ Formula template exists at `FORMULA_TEMPLATE.rb`
- ✓ Class name is correct: `SpotlightMcp`
- ✓ Description and homepage present
- ✓ Placeholder URL and SHA256 present for workflow updates
- ✓ `depends_on :macos` constraint included
- ✓ Install step: `bin.install "spotlight-mcp"` is correct
- ✓ Test block uses `assert_predicate bin/"spotlight-mcp", :executable?` (AC 8)
- ✓ Formula follows Homebrew conventions

### Documentation (Steps 9-10, L28, L29)
- ✓ README.md updated with Homebrew installation section (AC 7, L28)
- ✓ README.md documents `brew tap adamrdrew/spotlight-mcp`
- ✓ README.md documents `brew install spotlight-mcp`
- ✓ README.md includes note about no code signing / first-run prompt
- ✓ README.md shows correct binary paths for Apple Silicon and Intel
- ✓ README.md updated MCP client configuration examples for Homebrew paths
- ✓ `.ushabti/docs/release-automation.md` created and comprehensive
- ✓ `.ushabti/docs/index.md` updated to reference release automation
- ✓ Documentation reconciliation complete (L29 satisfied)

### Constraints and Laws
- ✓ L25 (Single Binary Output): Satisfied by existing build configuration
- ✓ L26 (Semantic Versioning): Workflow correctly expects semver tags
- ✓ L28 (README Completeness): README updated with installation instructions
- ✓ L29 (Documentation Reconciliation): Docs updated and reconciled
- ✓ Uses only macOS system frameworks (L02 - No Private APIs)
- ✓ No elevated privileges required (L03)

---

## Issues

### Issue 1: CHANGELOG.md Missing (L27 Violation) — CRITICAL

**Law violated**: L27 — CHANGELOG Maintenance

**Finding**: The workflow's GitHub Release step (line 39 of `release.yml`) includes:
```yaml
--notes "See [CHANGELOG.md](https://github.com/adamrdrew/spotlight-mcp/blob/master/CHANGELOG.md) for details."
```

However, CHANGELOG.md does not exist in the repository. This violates L27: "CHANGELOG.md MUST be updated for every release, documenting all user-facing changes."

**Impact**:
- Workflow will create releases with broken CHANGELOG.md links
- L27 violation prevents phase completion
- Users cannot see release history

**Root cause**: Phase scope (line 52 of phase.md) states "CHANGELOG validation: Out of scope for this phase. No CHANGELOG step in the workflow." This is inconsistent with the workflow implementation and violates L27.

**Required correction**: Create CHANGELOG.md with initial release content. Follow-up step 11 addresses this.

---

### Issue 2: Step 8 Not Implemented — CRITICAL

**Acceptance criteria affected**: AC 2, 4, 5, 6

**Finding**: Step 8 ("Test Workflow End-to-End") is marked `implemented: false` in progress.yaml. The "done when" condition is explicit: "Full workflow executes successfully and binary installs via Homebrew."

This step is essential because it verifies:
- AC 1: Tag triggers workflow
- AC 2: Universal binary builds successfully
- AC 3: GitHub Release created with tarball
- AC 4: Tap formula updated with correct URL and SHA256
- AC 5: `brew install` works correctly
- AC 6: Installed binary runs correctly

**Impact**: Acceptance criteria 1-6 cannot be verified without execution. The phase cannot be green without confirming the workflow actually works.

**Required correction**: Execute the workflow with a test tag and verify all acceptance criteria. Follow-up step 14 addresses this.

---

### Issue 3: Formula Template Not in Tap Repository — CRITICAL

**Acceptance criteria affected**: AC 4, 5

**Finding**: The formula template exists at:
```
.ushabti/phases/0007-homebrew-release-automation/FORMULA_TEMPLATE.rb
```

But progress.yaml step 7 notes state: "Must be manually committed to tap repo at Formula/spotlight-mcp.rb before first release."

The workflow's sed commands (steps 5-6) assume `Formula/spotlight-mcp.rb` exists in the tap repository. If it doesn't exist, the workflow will fail.

**Impact**:
- Workflow cannot update a non-existent formula
- AC 4 (formula update) will fail
- AC 5 (brew install) impossible without formula in tap

**Required correction**: Manually commit FORMULA_TEMPLATE.rb to the tap repository at `Formula/spotlight-mcp.rb`. Follow-up step 13 addresses this.

---

### Issue 4: Workflow-Phase Scope Inconsistency — MODERATE

**Finding**: phase.md explicitly excludes CHANGELOG validation ("Out of scope for this phase. No CHANGELOG step in the workflow"), but the implemented workflow includes a CHANGELOG.md reference in release notes.

This creates confusion about phase scope and reveals incomplete planning.

**Impact**:
- Internal inconsistency undermines phase clarity
- Creates broken link in releases (see Issue 1)

**Resolution**: The decision to create CHANGELOG.md (follow-up step 11) resolves this. The workflow implementation was actually correct; the phase scope exclusion was the error. L27 is non-negotiable.

**Required correction**: Create CHANGELOG.md (addresses both Issue 1 and Issue 4). Follow-up step 11.

---

## Required Follow-Ups

Four follow-up steps have been added to steps.md and progress.yaml:

### Step 11: Create CHANGELOG.md
- Create CHANGELOG.md at repository root
- Follow Keep a Changelog format
- Add initial v0.1.0 entry documenting features from phases 1-4
- Document release automation feature
- **Addresses**: Issue 1, Issue 4, L27 compliance

### Step 12: Fix Workflow CHANGELOG.md Reference
- Resolved by creating CHANGELOG.md in step 11
- No workflow changes needed
- **Addresses**: Issue 4

### Step 13: Commit Formula Template to Tap Repository
- Clone tap repo manually
- Copy FORMULA_TEMPLATE.rb to Formula/spotlight-mcp.rb
- Commit and push to tap repo
- **Addresses**: Issue 3

### Step 14: Execute End-to-End Test
- Push test tag: `v0.0.1-test`
- Monitor GitHub Actions execution
- Verify GitHub Release creation
- Verify formula update in tap repo
- Test Homebrew installation locally
- Verify binary runs
- **Addresses**: Issue 2, verifies AC 1-6

---

## Laws and Style Compliance

### Laws Verified
- ✓ L02 (No Private APIs): Workflow uses only public Swift/macOS APIs
- ✓ L03 (No Escalated Privileges): Binary runs as standard user
- ✓ L25 (Single Binary Output): Workflow produces single binary
- ✓ L26 (Semantic Versioning): Workflow expects semver tags
- ✓ L28 (README Completeness): Installation instructions added
- ✓ L29 (Documentation Reconciliation): Docs updated
- ✗ **L27 (CHANGELOG Maintenance)**: VIOLATED — CHANGELOG.md missing

### Style Compliance
- N/A: This phase involves workflow configuration and formula definition, not Swift code
- Documentation follows established format and clarity standards
- Workflow is well-commented and structured

---

## Security Review

### Secrets Handling
- ✓ Uses GitHub secret `HOMEBREW_SPOTLIGHT_MCP_PAT` correctly
- ✓ Token passed via environment variables, not command-line arguments
- ✓ Token scoped to tap repository only

### Workflow Security
- ✓ No code signing (explicitly documented as acceptable tradeoff)
- ✓ No security vulnerabilities in sed usage (fixed strings, no user input)
- ✓ Tap repository authentication uses fine-grained PAT

### Binary Distribution
- ✓ README documents lack of code signing and first-run prompt expectation
- ✓ Homebrew strips quarantine attributes (standard behavior)

No security issues identified.

---

## Recommendations

### For Immediate Follow-Up
1. Create CHANGELOG.md with comprehensive initial release entry
2. Manually commit formula to tap repository
3. Execute end-to-end test with `v0.0.1-test` tag
4. Verify Homebrew installation on both Apple Silicon and Intel Macs (if available)

### For Future Consideration (Out of Scope)
- Consider code signing for improved user experience (eliminates first-run prompt)
- Consider adding workflow validation step (e.g., `brew audit` on formula)
- Consider automated testing of tarball integrity before release creation
- Consider adding workflow dispatch for manual testing without tags

---

## Decision

**Phase Status**: BUILDING (returned to Builder)

**Rationale**: Four critical defects prevent completion:
1. L27 violation (CHANGELOG.md missing)
2. Step 8 incomplete (no end-to-end verification)
3. Formula not in tap repository (workflow will fail)
4. Internal scope inconsistency

The implementation work completed (steps 1-7, 9-10) is high quality. The workflow design is sound. The documentation is thorough. However, the phase cannot be marked complete without:
- Satisfying L27 (CHANGELOG.md)
- Verifying acceptance criteria (end-to-end test)
- Ensuring the workflow can actually function (formula in tap)

Follow-up steps 11-14 are concrete, minimal, and directly address the identified deficiencies. Once these steps are implemented and verified, the phase will be ready for re-review.

**Next Steps**:
1. Builder implements follow-up steps 11-14
2. Builder marks steps implemented and updates progress.yaml status to "review"
3. Overseer performs re-review to verify corrections

---

**Review Date**: 2026-02-07
**Reviewed By**: Ushabti Overseer
**Phase**: 0007-homebrew-release-automation
**Status After Review**: building (follow-up required)
