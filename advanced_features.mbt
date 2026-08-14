///|
pub fn signal_rms(signal : ArrayView[Double]) -> Double raise SpectrumError {
  signal_stats(signal).rms
}

///|
pub fn crest_factor(signal : ArrayView[Double]) -> Double raise SpectrumError {
  let stats = signal_stats(signal)
  if stats.rms == 0.0 {
    raise InvalidArgument(message="crest factor is undefined for zero signal")
  }
  let peak = if stats.minimum.abs() > stats.maximum.abs() {
    stats.minimum.abs()
  } else {
    stats.maximum.abs()
  }
  peak / stats.rms
}

///|
pub fn dynamic_range_db(
  signal : ArrayView[Double],
) -> Double raise SpectrumError {
  let stats = signal_stats(signal)
  let mut minimum = 0.0
  let mut maximum = 0.0
  for value in signal {
    let magnitude = value.abs()
    if magnitude > 0.0 && (minimum == 0.0 || magnitude < minimum) {
      minimum = magnitude
    }
    if magnitude > maximum {
      maximum = magnitude
    }
  }
  if stats.count == 0 || minimum == 0.0 || maximum == 0.0 {
    raise InvalidArgument(message="dynamic range needs non-zero samples")
  }
  20.0 * @math.log10(maximum / minimum)
}

///|
pub fn spectral_flux(
  previous : ArrayView[Double],
  current : ArrayView[Double],
) -> Double raise SpectrumError {
  if previous.length() == 0 || current.length() == 0 {
    raise EmptySignal
  }
  if previous.length() != current.length() {
    raise LengthMismatch
  }
  let mut denominator = 0.0
  let mut increase = 0.0
  for i in 0..<previous.length() {
    denominator = denominator + previous[i]
    let delta = current[i] - previous[i]
    if delta > 0.0 {
      increase = increase + delta
    }
  }
  if denominator == 0.0 {
    return 0.0
  }
  increase / denominator
}

///|
pub fn spectral_band_energy(
  magnitudes : ArrayView[Double],
  sample_rate : Double,
  low_hz : Double,
  high_hz : Double,
) -> Double raise SpectrumError {
  let half = positive_spectrum_length(magnitudes)
  if sample_rate <= 0.0 ||
    low_hz < 0.0 ||
    high_hz < low_hz ||
    high_hz > sample_rate / 2.0 {
    raise InvalidArgument(message="invalid spectral band")
  }
  let mut energy = 0.0
  for i in 0..<half {
    let frequency = Double::from_int(i) *
      sample_rate /
      Double::from_int(magnitudes.length())
    if frequency >= low_hz && frequency <= high_hz {
      energy = energy + magnitudes[i] * magnitudes[i]
    }
  }
  energy
}

///|
pub fn next_power_of_two(value : Int) -> Int raise SpectrumError {
  if value <= 0 {
    raise InvalidArgument(message="value must be positive")
  }
  let mut result = 1
  while result < value {
    result = result * 2
  }
  result
}

///|
pub fn pad_to_power_of_two(
  signal : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let length = next_power_of_two(signal.length())
  let output = Array::make(length, 0.0)
  for i in 0..<signal.length() {
    output[i] = signal[i]
  }
  output
}

///|
pub fn envelope_follow(
  signal : ArrayView[Double],
  attack~ : Double,
  release~ : Double,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if attack <= 0.0 || attack > 1.0 || release <= 0.0 || release > 1.0 {
    raise InvalidArgument(message="attack and release must be in (0, 1]")
  }
  let output = Array::make(signal.length(), 0.0)
  let mut previous = signal[0].abs()
  output[0] = previous
  for i in 1..<signal.length() {
    let target = signal[i].abs()
    let coefficient = if target > previous { attack } else { release }
    previous = previous + coefficient * (target - previous)
    output[i] = previous
  }
  output
}
