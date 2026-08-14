# Changelog

## 0.2.1 - Acceptance hardening and analysis expansion

- Added GitLink CI and synchronized acceptance documentation.
- Added robust signal quality, sensor calibration, event detection, filter
  response, and spectrogram summary APIs with deterministic tests.
- Updated README, proposal-generator, fixture, and release metadata.

## 0.2.0 - Scientific analysis expansion

- Added descriptive statistics, centering, linear detrending, peak normalization, quantiles, and moving RMS.
- Added auto/cross/full correlation, normalized correlation, local peak detection, and spectral descriptors.
- Added Welch PSD, spectral summaries, window gain metrics, dynamic range, SNR, error metrics, and signal framing.
- Added FFT-based linear convolution, envelope following, triangle/sawtooth/pulse-train generators, notch and all-pass biquads.
- Added `stats`, `correlate`, `welch`, and `peaks` CLI commands with deterministic fixtures.
- Hardened acceptance exit-code handling, public interface drift checking, Windows native prerequisites, and documentation consistency.

## 0.1.1 - Mooncakes release

- Updated package metadata and release documentation for the Mooncakes publication.
- Preserved the validated FFT, spectrum, filtering, resampling, CLI, and cross-platform CI coverage.

## 0.1.0 - OSC2026 proposal build

- Added complex numbers, DFT, radix-2 FFT, inverse FFT, spectra, windows, convolution, moving average, and basic FIR tap design.
- Added MoonSpectrum CLI with `demo`, `fft`, `analyze`, `window`, and `convolve` commands.
- Added sample CSV fixtures and competition acceptance materials.
- Added STFT, periodogram PSD, sinc/linear resampling, IIR biquad filters, and CLI smoke coverage.
- Added fixture provenance and numerical invariants for PSD, STFT, resampling, IIR, and FIR tests.
- Expanded CI to format, interface, all-backend check/build/test, and cross-platform CLI validation.

