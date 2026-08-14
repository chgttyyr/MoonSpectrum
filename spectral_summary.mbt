///|
pub fn spectral_summary(
  spectrum : ArrayView[Complex],
  sample_rate : Double,
) -> SpectralSummary raise SpectrumError {
  let magnitudes = magnitude_spectrum(spectrum)
  {
    centroid: spectral_centroid(magnitudes, sample_rate),
    bandwidth: spectral_bandwidth(magnitudes, sample_rate),
    flatness: spectral_flatness(magnitudes),
    entropy: spectral_entropy(magnitudes),
    rolloff: spectral_rolloff(magnitudes, sample_rate),
  }
}

///|
pub fn spectral_slope(
  magnitudes : ArrayView[Double],
) -> Double raise SpectrumError {
  if magnitudes.length() < 2 {
    raise InvalidArgument(message="spectral slope needs two bins")
  }
  let x_mean = Double::from_int(magnitudes.length() - 1) / 2.0
  let mut numerator = 0.0
  let mut denominator = 0.0
  let mut y_total = 0.0
  for value in magnitudes {
    y_total = y_total + value
  }
  let y_mean = y_total / Double::from_int(magnitudes.length())
  for i in 0..<magnitudes.length() {
    let x = Double::from_int(i) - x_mean
    numerator = numerator + x * (magnitudes[i] - y_mean)
    denominator = denominator + x * x
  }
  numerator / denominator
}
