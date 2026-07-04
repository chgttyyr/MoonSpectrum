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

## Errors

Common errors:

- `EmptySignal`
- `LengthMismatch`
- `NonPowerOfTwo(length=...)`
- `InvalidArgument(message=...)`

The API uses checked errors so callers decide whether to propagate or handle invalid input.

