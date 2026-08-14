# Scientific Analysis Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add useful statistics, correlation, Welch PSD, and peak-detection capabilities while making the acceptance gate truthful and the public documentation consistent.

**Architecture:** Keep the root MoonBit package as the public facade and split new code by responsibility: `statistics.mbt`, `correlation.mbt`, `welch.mbt`, and `peaks.mbt`. Reuse `Complex`, `WindowKind`, `Peak`, `SpectrumError`, `fft`, `window`, and `apply_window`; add only small public result types where a structured result improves API clarity.

**Tech Stack:** MoonBit 0.10.x-compatible syntax, `moonbitlang/core/math`, existing MoonBit test/inspect assertions, PowerShell acceptance script, GitHub Actions.

---

### Task 1: Add failing tests for statistics and preprocessing

**Files:**
- Create: `statistics_test.mbt`
- Modify: `types.mbt` only if the test requires a public result type declaration

- [ ] **Step 1: Write tests for exact statistics**

Add tests asserting that `signal_stats([1, 2, 3, 4])` reports count 4, mean 2.5, variance 1.25, RMS `sqrt(7.5)`, minimum 1, maximum 4, and peak-to-peak 3; assert a constant signal has zero variance.

- [ ] **Step 2: Write tests for preprocessing**

Add tests asserting `center([2, 4, 6])` has mean zero, `detrend_linear([1, 3, 5, 7])` has near-zero mean and slope, and `normalize_peak([-2, 0, 1])` returns `[-1, 0, 0.5]`.

- [ ] **Step 3: Run the targeted test and verify RED**

Run `moon test statistics_test.mbt`. Expected result: failure because the new functions/types do not exist.

### Task 2: Implement statistics and preprocessing

**Files:**
- Create: `statistics.mbt`
- Modify: `types.mbt` to add the public `SignalStats` result type

- [ ] **Step 1: Implement the smallest passing API**

Implement `SignalStats`, `signal_stats`, `center`, `detrend_linear`, and `normalize_peak` with explicit `EmptySignal` and zero-range handling. Use one-pass or numerically stable accumulation where practical, preserve input arrays, and use `///|` blocks.

- [ ] **Step 2: Run the targeted tests and verify GREEN**

Run `moon test statistics_test.mbt`; expected result is all new tests passing.

- [ ] **Step 3: Refactor only after green**

Extract private helpers for mean and linear-regression sums only if duplication remains; rerun `moon fmt`, `moon check`, and `moon test statistics_test.mbt`.

### Task 3: Add and implement correlation and peak detection with TDD

**Files:**
- Create: `correlation_test.mbt`, `peaks_test.mbt`
- Create: `correlation.mbt`, `peaks.mbt`

- [ ] **Step 1: Write failing correlation tests**

Specify that `autocorrelation([1, 2, 3], 0..2)` is symmetric around lag zero, `cross_correlation([1, 2], [1, 2], 0)` is positive, normalized correlation of identical signals at lag zero is approximately 1, and mismatched/empty inputs raise `SpectrumError`.

- [ ] **Step 2: Write failing peak tests**

Specify threshold filtering, minimum-distance suppression, descending magnitude order, and an empty result when no sample exceeds the threshold.

- [ ] **Step 3: Run both targeted test files and verify RED**

Run `moon test correlation_test.mbt peaks_test.mbt`; expected result is failure due to missing functions.

- [ ] **Step 4: Implement correlation**

Implement lag-aware `autocorrelation`, `cross_correlation`, and `normalized_correlation`. Define positive lag consistently in the docstrings and validate `max_lag` against signal length.

- [ ] **Step 5: Implement peak detection**

Implement a deterministic `find_peaks` that scans local maxima, applies threshold and spacing, and returns the existing `Peak` type when a sample rate is supplied.

- [ ] **Step 6: Run targeted tests and refactor after GREEN**

Run `moon test correlation_test.mbt peaks_test.mbt`, then `moon fmt` and `moon check`.

### Task 4: Add Welch PSD with numerical tests

**Files:**
- Create: `welch_test.mbt`
- Create: `welch.mbt`

- [ ] **Step 1: Write failing Welch tests**

Test a deterministic 2 Hz sine sampled at 8 Hz, asserting the returned frequency and PSD arrays have `segment_length / 2 + 1` entries, the dominant bin remains 2 Hz, and invalid segment length, overlap, sample rate, and too-short input raise errors.

- [ ] **Step 2: Run `moon test welch_test.mbt` and verify RED**

The test must fail because `welch_psd` and its result type are not present.

- [ ] **Step 3: Implement minimal Welch estimation**

Validate power-of-two segment length, use `window`, `apply_window`, and `periodogram`-compatible normalization, average overlapping segment periodograms, and return frequency bins plus single-sided PSD in a documented result type.

- [ ] **Step 4: Run the targeted tests and verify GREEN**

Run `moon test welch_test.mbt`; then run `moon test --filter 'welch*'` and review numeric tolerances.

### Task 5: Extend CLI, fixtures, and public documentation

**Files:**
- Modify: `cmd/main/main.mbt`
- Modify: `README.md`
- Modify: `docs/api.md`, `docs/fixtures.md`, `CHANGELOG.md`
- Create: `examples/offset.csv`, `examples/dual-tone.csv` for deterministic smoke tests

- [ ] **Step 1: Add CLI smoke expectations before implementation**

Add documented command examples for `stats`, `correlate`, `welch`, and `peaks`, including expected stable fields and exit behavior for invalid arguments.

- [ ] **Step 2: Implement CLI dispatch**

Parse the new commands using the existing argument conventions, load one-value-per-line fixtures, call public library functions, and print compact deterministic output.

- [ ] **Step 3: Run CLI commands and fix behavior**

Run all existing smoke commands plus `moon run cmd/main -- stats examples/sine.csv`, `correlate`, `welch`, and `peaks`; ensure each exits zero and invalid parameters exit non-zero.

- [ ] **Step 4: Repair documentation consistency**

Remove implemented STFT/IIR/resampling items from the future-work list, list all CLI commands, document Windows MSYS2/UCRT64 GCC for native validation, and describe the new APIs and fixture provenance.

### Task 6: Make acceptance and CI checks truthful

**Files:**
- Modify: `scripts/verify_acceptance.ps1`
- Modify: `.github/workflows/ci.yml`
- Modify: `docs/competition/acceptance-checklist.md`, `docs/competition/final-report.md`, `docs/competition/release-checklist.md`

- [ ] **Step 1: Add a failing acceptance-script regression probe**

Run the acceptance script with a deliberately unavailable native compiler or a controlled failing command and confirm the current script incorrectly continues; use that observation to define the regression.

- [ ] **Step 2: Add strict external-command checking**

Introduce a PowerShell helper that executes each external command and throws when `$LASTEXITCODE -ne 0`; use it for MoonBit, Git, and curl checks that determine acceptance status.

- [ ] **Step 3: Improve CI reproducibility and interface validation**

Replace the unused toolchain environment variable with the supported explicit installer/version mechanism, or document the intentional latest policy. Normalize generated `.mbti` trailing whitespace and compare the normalized files so public interface drift is still detected.

- [ ] **Step 4: Run the acceptance script**

Run `powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun`; expected behavior is failure when native prerequisites are absent and a true pass when all backends are available.

### Task 7: Full verification and release handoff

**Files:**
- No new source files; review all changed files and generated `.mbti` files.

- [ ] **Step 1: Run local verification**

Run `moon fmt --check`, `moon info`, `moon check --target all --warn-list +73`, `moon build --target all`, `moon test --target all`, all CLI smoke commands, and corrected acceptance script.

- [ ] **Step 2: Review generated interfaces and source size**

Confirm only intended public API changes exist in `pkg.generated.mbti` and `cmd/main/pkg.generated.mbti`; count project-only `.mbt` files and lines excluding `.build`, `.mooncakes`, `.git`, and generated `.mbti`, targeting approximately 2,800–3,200 lines.

- [ ] **Step 3: Update version and release notes**

Increment `moon.mod` to the next unused semantic version, add a changelog entry, run `moon publish --dry-run`, and review the package contents.

- [ ] **Step 4: Commit and synchronize**

Commit with the sole `chgttyyr` identity, push GitHub `main`, push GitLink `main` and `master`, publish Mooncakes, then verify API version, docs HTTP status, default branches, and CI success.
