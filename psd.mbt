///|
pub fn periodogram(
  signal : ArrayView[Double],
  sample_rate : Double,
  window_kind? : WindowKind = Rectangular,
) -> Array[Double] raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise EmptySignal
  }
  if !is_power_of_two(n) {
    raise NonPowerOfTwo(length=n)
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }

  let win = window(window_kind, n)
  let windowed = apply_window(signal, win)
  let complex_frame = real_signal(windowed)
  let spec = fft(complex_frame)

  // Periodogram formula: P(f) = |X(f)|^2 / (N * fs * S2)
  // where S2 is the window sum of squares: S2 = sum(w_i^2) / N
  let mut s2 = 0.0
  for i in 0..<n {
    s2 = s2 + win[i] * win[i]
  }
  s2 = s2 / Double::from_int(n)

  let norm = Double::from_int(n) * sample_rate * s2
  let psd = Array::make(n, 0.0)
  for i in 0..<n {
    let mag_sq = spec[i].re * spec[i].re + spec[i].im * spec[i].im
    psd[i] = mag_sq / norm
  }
  psd
}

///|
pub fn single_sided_psd(
  two_sided_psd : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  let n = two_sided_psd.length()
  if n == 0 {
    raise EmptySignal
  }
  let half = n / 2 + 1
  let out = Array::make(half, 0.0)
  out[0] = two_sided_psd[0]
  for i in 1..<(half - 1) {
    out[i] = two_sided_psd[i] * 2.0
  }
  if half - 1 < n {
    out[half - 1] = two_sided_psd[half - 1]
  }
  out
}
