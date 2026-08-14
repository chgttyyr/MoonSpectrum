# Design notes

MoonSpectrum is a reusable scientific signal-processing layer, not an audio engine and not a plotting application.

## Package boundary

The root package owns all public types and functions:

- `Complex`
- `WindowKind`
- `Peak`
- `SpectrumError`
- `SignalStats`, `SignalPeak`, `WelchResult`, and `SpectralSummary`
- FFT, spectrum, windows, convolution, filters, signal generators, statistics,
  correlation, framing, and spectral descriptors

The CLI package imports the root package and does not reimplement algorithms. This keeps command-line behavior testable through the same public API that library users call.

## Numeric choices

- Use `Double` because it is available in MoonBit core and keeps scientific examples readable.
- Use tolerance-based assertions in tests for trigonometric and FFT output.
- Keep deterministic pseudo-random white noise, so tests and examples do not depend on platform entropy.

## FFT scope

The first FFT implementation supports radix-2 input lengths. Non-power-of-two input returns `SpectrumError::NonPowerOfTwo`. A future version can add Bluestein or mixed-radix support without changing the existing DFT/FFT API.

## CLI scope

The CLI accepts simple single-column CSV fixture files. It is meant for smoke tests and demonstrations, not as a full data-cleaning tool.

## Implemented extensions

- STFT is implemented on top of `window`, `fft`, and `magnitude_spectrum`.
- Periodogram PSD, single-sided PSD, linear/sinc resampling, and IIR biquad
  filters are implemented without changing the original FFT/FIR APIs.
- Welch PSD, spectral descriptors, signal statistics, correlation, peak
  detection, framing, overlap-add, and FFT convolution are implemented as
  reusable root-package APIs.

## Future extensions

- Cross-channel streaming processing and timestamp-aware ingestion.
- WebAssembly visualization can consume CLI-style JSON output or call the root package directly.

