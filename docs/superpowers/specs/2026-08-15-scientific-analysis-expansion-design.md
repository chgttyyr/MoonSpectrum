# Scientific Analysis Expansion Design

**Date:** 2026-08-15

**Goal:** Extend MoonSpectrum into a more useful reusable signal-analysis toolkit while repairing the acceptance and documentation weaknesses found during the OSC2026 audit.

## Scope

The existing root package remains the public facade. New capabilities are split into focused files rather than new public subpackages so Mooncakes users can continue importing one module and discover the API from one generated interface file.

The implementation adds:

- signal statistics and preprocessing: descriptive statistics, centering, linear detrending, and peak normalization;
- lag-domain analysis: autocorrelation, cross-correlation, normalized correlation, and lag-aware peak search;
- Welch power spectral density estimation with explicit segment and overlap validation;
- reusable amplitude peak detection for spectral and time-domain signals;
- CLI commands and deterministic fixtures for the new workflows;
- numerical tests for normal signals, degenerate signals, invalid arguments, and boundary behavior.

The target is approximately 2,800–3,200 lines of actual project MoonBit source, achieved through useful algorithms and tests rather than duplicated or generated code.

## Public API

The root package will expose focused value types and functions:

- `SignalStats` with mean, variance, standard deviation, RMS, minimum, maximum, peak-to-peak, and sample count;
- `signal_stats`, `center`, `detrend_linear`, and `normalize_peak`;
- `autocorrelation`, `cross_correlation`, and `normalized_correlation`;
- `WelchConfig`/`WelchResult`-style public data with `welch_psd` and frequency output;
- `find_peaks` with explicit minimum amplitude, minimum spacing, and optional limit behavior.

All public error cases use the existing `SpectrumError` hierarchy. Empty input, invalid sample rates, invalid segment lengths, invalid overlap, and invalid lag ranges are rejected deterministically instead of producing NaN-heavy output.

## CLI

The command-line tool gains:

- `stats <file>` for descriptive statistics;
- `correlate <file> [other-file]` for auto/cross-correlation summaries;
- `welch <file> --sample-rate <hz> --segment-length <n> --overlap <fraction>`;
- `peaks <file> --sample-rate <hz> --threshold <value>`.

Commands use the existing one-value-per-line fixture format and emit compact JSON-like output consistent with the current CLI.

## Acceptance repairs

- `scripts/verify_acceptance.ps1` will wrap external commands and fail immediately when `$LASTEXITCODE` is non-zero, so a native build failure cannot be reported as a pass.
- README installation instructions will document the Windows native compiler prerequisite and the complete CLI surface.
- README boundaries and roadmap will describe only genuinely future capabilities.
- CI will use an explicit toolchain selection mechanism or clearly report why the selected version is intentionally floating; the workflow will validate generated public interfaces through a normalized comparison rather than silently excluding `.mbti` files.

## Testing strategy

Every new behavior starts with a failing MoonBit test. Tests cover:

- exact statistics for constant, impulse, and signed signals;
- detrending a known affine sequence to near-zero residual slope;
- correlation symmetry, lag direction, normalization, and invalid inputs;
- Welch PSD dimensions, dominant-bin stability, and segment/overlap validation;
- peak ordering, thresholding, spacing, and empty results;
- CLI smoke commands on deterministic fixtures.

Validation is performed with `moon fmt --check`, `moon info`, `moon check --target all`, `moon build --target all`, `moon test --target all`, the acceptance script, all documented CLI commands, and the public GitHub/GitLink/Mooncakes checks.
