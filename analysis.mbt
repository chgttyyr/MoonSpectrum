///|
pub fn magnitude_spectrum(spectrum : ArrayView[Complex]) -> Array[Double] {
  spectrum.map(item => item.magnitude())
}

///|
pub fn power_spectrum(spectrum : ArrayView[Complex]) -> Array[Double] {
  spectrum.map(item => item.re * item.re + item.im * item.im)
}

///|
pub fn frequency_bins(
  length : Int,
  sample_rate : Double,
) -> Array[Double] raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  let bins : Array[Double] = []
  for i in 0..<length {
    bins.push(Double::from_int(i) * sample_rate / Double::from_int(length))
  }
  bins
}

///|
pub fn dominant_peak(
  spectrum : ArrayView[Complex],
  sample_rate : Double,
) -> Peak raise SpectrumError {
  let n = spectrum.length()
  if n == 0 {
    raise EmptySignal
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  let half = n / 2
  let mut best_index = 0
  let mut best_magnitude = -1.0
  for i in 1..<=half {
    let magnitude = spectrum[i].magnitude()
    if magnitude > best_magnitude {
      best_index = i
      best_magnitude = magnitude
    }
  }
  {
    index: best_index,
    frequency: Double::from_int(best_index) * sample_rate / Double::from_int(n),
    magnitude: best_magnitude,
  }
}
