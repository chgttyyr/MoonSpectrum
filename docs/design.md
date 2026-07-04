# Design notes

MoonSpectrum keeps the first version deliberately small. The project is a reusable algorithm layer, not an audio engine and not a plotting application.

## Package boundary

The root package owns all public types and functions:

- `Complex`
- `WindowKind`
- `Peak`
- `SpectrumError`
- FFT, spectrum, windows, convolution, filters, and signal generators

The CLI package imports the root package and does not reimplement algorithms. This keeps command-line behavior testable through the same public API that library users call.

## Numeric choices

- Use `Double` for v0.1.0 because it is available in MoonBit core and keeps scientific examples readable.
- Use tolerance-based assertions in tests for trigonometric and FFT output.
- Keep deterministic pseudo-random white noise, so tests and examples do not depend on platform entropy.

## FFT scope

The first FFT implementation supports radix-2 input lengths. Non-power-of-two input returns `SpectrumError::NonPowerOfTwo`. A future version can add Bluestein or mixed-radix support without changing the existing DFT/FFT API.

## CLI scope

The CLI accepts simple single-column CSV fixture files. It is meant for smoke tests and demonstrations, not as a full data-cleaning tool.

## Future extensions

- STFT and spectrogram export can be layered on `window`, `fft`, and `magnitude_spectrum`.
- IIR filters can be added next to the FIR functions without changing convolution.
- WebAssembly visualization can consume CLI-style JSON output or call the root package directly.

