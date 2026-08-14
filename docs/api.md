# API guide

## Complex numbers

```mbt
let a = complex(re=1.0, im=2.0)
let b = complex(re=3.0, im=-4.0)
let product = a.mul(b)
```

## FFT and spectra

```mbt
let signal = real_signal([1.0, 0.0, 0.0, 0.0])
let bins = fft(signal)
let magnitudes = magnitude_spectrum(bins)
```

Use `dft` for small reference calculations and `fft` for power-of-two signals.

## Frequency analysis

```mbt
let values = sine_wave(length=8, sample_rate=8.0, frequency=2.0)
let spectrum = fft(real_signal(values))
let peak = dominant_peak(spectrum, 8.0)
```

`Peak.frequency` is computed from the bin index and the provided sample rate.

## Windows and filtering

```mbt
let weights = window(Hann, 8)
let weighted = apply_window([1.0, 2.0, 3.0, 4.0, 3.0, 2.0, 1.0, 0.0], weights)
let taps = lowpass_taps(length=5, cutoff_hz=1.0, sample_rate=8.0)
let filtered = fir_filter(weighted, taps)
```

Low-pass and high-pass taps require odd tap length and a cutoff below Nyquist.

## Error handling

## Statistics and preprocessing

`signal_stats` returns count, mean, population variance, standard deviation,
RMS, minimum, maximum, and peak-to-peak range. `center` removes the mean,
`detrend_linear` removes the least-squares affine trend, and `normalize_peak`
scales the largest absolute sample to one.

## Correlation and peaks

`autocorrelation(signal, max_lag)` returns non-negative lag values. Positive
cross-correlation lag compares `signal[i]` with `other[i + lag]`.
`normalized_correlation` divides autocorrelation by the zero-lag energy.
`find_peaks` returns local maxima ordered by descending magnitude and can apply
an amplitude threshold and minimum index spacing.

## Welch PSD

`welch_psd` divides a signal into overlapping power-of-two segments, applies a
selected window, averages single-sided periodograms, and returns matching
frequency and PSD arrays. The overlap is a fraction in `[0, 1)` and short or
invalid segments raise `SpectrumError`.

Common errors:

- `EmptySignal`
- `LengthMismatch`
- `NonPowerOfTwo(length=...)`
- `InvalidArgument(message=...)`

The API uses checked errors so callers decide whether to propagate or handle invalid input.

