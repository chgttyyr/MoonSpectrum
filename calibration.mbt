///|
/// Linearly maps sensor values from an input range to an engineering range.
pub fn scale_signal(
  signal : ArrayView[Double],
  input_min~ : Double,
  input_max~ : Double,
  output_min~ : Double,
  output_max~ : Double,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if input_min >= input_max {
    raise InvalidArgument(message="input range must have positive width")
  }
  let width = input_max - input_min
  let output_width = output_max - output_min
  signal.map(value => output_min + (value - input_min) * output_width / width)
}

///|
/// Subtracts a known sensor baseline without changing the input array.
pub fn remove_baseline(
  signal : ArrayView[Double],
  baseline : Double,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  signal.map(value => value - baseline)
}

///|
/// Computes robust z-scores using median and median absolute deviation.
pub fn robust_z_scores(
  signal : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let center = median(signal)
  let deviations = signal.map(value => (value - center).abs())
  let mad = median(deviations)
  if mad == 0.0 {
    return Array::make(signal.length(), 0.0)
  }
  let scale = 1.4826 * mad
  signal.map(value => (value - center) / scale)
}

///|
/// Returns sample indices whose robust z-score exceeds the given magnitude.
pub fn detect_outliers(
  signal : ArrayView[Double],
  z_threshold~ : Double,
) -> Array[Int] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if z_threshold <= 0.0 {
    raise InvalidArgument(message="z_threshold must be positive")
  }
  let scores = robust_z_scores(signal)
  let outliers : Array[Int] = []
  for i in 0..<scores.length() {
    if scores[i].abs() > z_threshold {
      outliers.push(i)
    }
  }
  outliers
}

///|
/// Returns the baseline-corrected signal and its estimated offset.
pub fn baseline_corrected(
  signal : ArrayView[Double],
) -> (Double, Array[Double]) raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let baseline = median(signal)
  (baseline, remove_baseline(signal, baseline))
}
