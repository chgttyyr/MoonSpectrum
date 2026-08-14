# Acceptance Hardening and Scientific Analysis Expansion Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all known OSC2026 acceptance risks and expand the reusable signal-processing API beyond 3300 lines of practical MoonBit source.

**Architecture:** Keep the root package as the public facade. Add focused modules for robust descriptive statistics, event detection, filter response analysis, and spectrogram summaries; each public behavior gets deterministic black-box tests. Update documentation and CI configuration only after the code and tests are green.

**Tech Stack:** MoonBit 0.10.x, `moonbitlang/core`, GitHub Actions, GitLink `.gitlink-ci.yml`, PowerShell acceptance checks, Mooncakes.

---

### Task 1: Fix acceptance-document consistency

**Files:** `README.md`, `scripts/build_proposal_pdf.py`

- [ ] Replace the stale README release from `0.1.1` with `0.2.0`.
- [ ] State that Welch PSD, spectral descriptors, correlation, and peak detection are implemented; keep only streaming, timestamps, and visualization as future work.
- [ ] Update the proposal generator's scope, test-count, and roadmap text to describe the current implementation rather than the initial proposal.
- [ ] Review UTF-8 rendering with `Get-Content -Encoding utf8` and run `git diff --check`.

### Task 2: Add robust signal-quality and event APIs with tests first

**Files:** `signal_quality_test.mbt`, `signal_quality.mbt`

- [ ] Write failing tests for covariance/autocovariance, mean absolute deviation, interquartile range, clipping, threshold event indices, and zero-crossing indices.
- [ ] Run `moon test signal_quality_test.mbt` and confirm failure is due to missing APIs.
- [ ] Implement checked, deterministic functions that reject empty or invalid input and never mutate the caller's array.
- [ ] Run the targeted test until green, then run `moon fmt` and `moon check`.

### Task 3: Add filter-response analysis with tests first

**Files:** `filter_analysis_test.mbt`, `filter_analysis.mbt`, `types.mbt`

- [ ] Write failing tests for FIR zero-phase padding, impulse response length, frequency-response dimensions, DC gain, and Biquad response stability.
- [ ] Run the targeted test and confirm the expected missing-symbol failure.
- [ ] Implement `FrequencyResponse`, FIR impulse response, FIR frequency response, Biquad frequency response, and simple response summaries using existing FFT/complex primitives.
- [ ] Run targeted tests and full backend checks.

### Task 4: Add spectrogram utilities with tests first

**Files:** `spectrogram_tools_test.mbt`, `spectrogram_tools.mbt`

- [ ] Write failing tests for spectrogram dimensions, frame-energy aggregation, and dominant-bin tracking over deterministic sine frames.
- [ ] Run the targeted test and confirm RED.
- [ ] Implement a documented wrapper over existing STFT with explicit frame/hop validation and compact energy/peak summaries.
- [ ] Run targeted tests and full backend checks.

### Task 5: Add GitLink CI and update acceptance docs

**Files:** `.gitlink-ci.yml`, `.github/workflows/ci.yml`, `README.md`, `docs/fixtures.md`, `docs/competition/acceptance-checklist.md`, `docs/competition/final-report.md`, `docs/competition/release-checklist.md`

- [ ] Add a GitLink pipeline that installs MoonBit, refreshes dependencies, runs format/interface checks, `moon check --target all`, `moon build --target all`, `moon test --target all`, and CLI smoke tests.
- [ ] Make README toolchain wording explicit: the repository is validated by the current official stable installer; mention that old 0.10.3 installations must use the legacy package syntax or upgrade.
- [ ] Document the new fixtures and APIs and remove every stale version/roadmap statement.
- [ ] Keep GitHub CI's full matrix and normalized generated-interface comparison.

### Task 6: Verify, publish, and audit both remotes

- [ ] Count project MoonBit source excluding build/cache/generated artifacts and confirm it is at least 3300 lines.
- [ ] Run `moon fmt --check`, `moon info`, `moon check --target all --warn-list +73`, `moon build --target all`, `moon test --target all`, and all CLI smoke commands with the latest toolchain.
- [ ] Run `scripts/verify_acceptance.ps1` with strict external-command checking.
- [ ] Commit with only `chgttyyr`, merge to `main`, push GitHub and GitLink `main/master`, publish Mooncakes `0.2.0`, and verify remote SHAs, default branches, CI success, and Mooncakes build status.
