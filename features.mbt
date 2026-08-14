///|
pub fn spectral_centroid(
  magnitudes : ArrayView[Double],
  sample_rate : Double,
) -> Double raise SpectrumError {
  let half = positive_spectrum_length(magnitudes)
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  let mut weighted = 0.0
  let mut total = 0.0
  for i in 0..<half {
    let value = magnitudes[i]
    let frequency = Double::from_int(i) *
      sample_rate /
      Double::from_int(magnitudes.length())
    weighted = weighted + frequency * value
    total = total + value
  }
  if total == 0.0 {
    return 0.0
  }
  weighted / total
}

///|
pub fn spectral_bandwidth(
  magnitudes : ArrayView[Double],
  sample_rate : Double,
) -> Double raise SpectrumError {
  let centroid = spectral_centroid(magnitudes, sample_rate)
  let half = positive_spectrum_length(magnitudes)
  let mut weighted = 0.0
  let mut total = 0.0
  for i in 0..<half {
    let value = magnitudes[i]
    let frequency = Double::from_int(i) *
      sample_rate /
      Double::from_int(magnitudes.length())
    let delta = frequency - centroid
    weighted = weighted + delta * delta * value
    total = total + value
  }
  if total == 0.0 {
    return 0.0
  }
  (weighted / total).sqrt()
}

///|
pub fn spectral_flatness(
  magnitudes : ArrayView[Double],
) -> Double raise SpectrumError {
  if magnitudes.length() == 0 {
    raise EmptySignal
  }
  let half = magnitudes.length()
  let mut logarithmic_sum = 0.0
  let mut arithmetic_sum = 0.0
  for i in 0..<half {
    let value = magnitudes[i]
    if value <= 0.0 {
      return 0.0
    }
    logarithmic_sum = logarithmic_sum + @math.log2(value)
    arithmetic_sum = arithmetic_sum + value
  }
  let count = Double::from_int(half)
  let geometric = @math.pow(2.0, logarithmic_sum / count)
  geometric / (arithmetic_sum / count)
}

///|
pub fn spectral_entropy(
  magnitudes : ArrayView[Double],
) -> Double raise SpectrumError {
  if magnitudes.length() == 0 {
    raise EmptySignal
  }
  let half = magnitudes.length()
  let mut total = 0.0
  for i in 0..<half {
    total = total + magnitudes[i]
  }
  if total == 0.0 {
    return 0.0
  }
  let mut entropy = 0.0
  for i in 0..<half {
    let probability = magnitudes[i] / total
    if probability > 0.0 {
      entropy = entropy - probability * @math.log2(probability)
    }
  }
  entropy
}

///|
pub fn spectral_rolloff(
  magnitudes : ArrayView[Double],
  sample_rate : Double,
  ratio? : Double = 0.85,
) -> Double raise SpectrumError {
  let half = positive_spectrum_length(magnitudes)
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  if ratio <= 0.0 || ratio > 1.0 {
    raise InvalidArgument(message="ratio must be in (0, 1]")
  }
  let mut total = 0.0
  for i in 0..<half {
    total = total + magnitudes[i]
  }
  if total == 0.0 {
    return 0.0
  }
  let target = total * ratio
  let mut cumulative = 0.0
  for i in 0..<half {
    cumulative = cumulative + magnitudes[i]
    if cumulative >= target {
      return Double::from_int(i) *
        sample_rate /
        Double::from_int(magnitudes.length())
    }
  }
  sample_rate / 2.0
}

///|
fn positive_spectrum_length(
  magnitudes : ArrayView[Double],
) -> Int raise SpectrumError {
  if magnitudes.length() == 0 {
    raise EmptySignal
  }
  magnitudes.length() / 2 + 1
}
