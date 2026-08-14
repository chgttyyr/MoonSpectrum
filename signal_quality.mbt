///|
/// Returns the population covariance of two equally sized signals.
///
/// Covariance is useful for comparing sensor channels without requiring a
/// frequency-domain representation. The divisor is `N`, matching the other
/// descriptive statistics in this package.
pub fn covariance(
  signal : ArrayView[Double],
  other : ArrayView[Double],
) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if signal.length() != other.length() {
    raise LengthMismatch
  }
  let mut mean_signal = 0.0
  let mut mean_other = 0.0
  for i in 0..<signal.length() {
    mean_signal = mean_signal + signal[i]
    mean_other = mean_other + other[i]
  }
  let count = Double::from_int(signal.length())
  mean_signal = mean_signal / count
  mean_other = mean_other / count
  let mut total = 0.0
  for i in 0..<signal.length() {
    total = total + (signal[i] - mean_signal) * (other[i] - mean_other)
  }
  total / count
}

///|
/// Returns the covariance between a signal and a lagged copy of itself.
pub fn autocovariance(
  signal : ArrayView[Double],
  lag : Int,
) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if lag < 0 || lag >= signal.length() {
    raise InvalidArgument(message="lag must be in [0, signal length)")
  }
  let mean = signal_stats(signal).mean
  let count = signal.length() - lag
  let mut total = 0.0
  for i in 0..<count {
    total = total + (signal[i] - mean) * (signal[i + lag] - mean)
  }
  total / Double::from_int(count)
}

///|
/// Returns the mean absolute deviation around the arithmetic mean.
pub fn mean_absolute_deviation(
  signal : ArrayView[Double],
) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let mean = signal_stats(signal).mean
  let mut total = 0.0
  for value in signal {
    total = total + (value - mean).abs()
  }
  total / Double::from_int(signal.length())
}

///|
/// Returns the interquartile range using the package's linear quantile rule.
pub fn interquartile_range(
  signal : ArrayView[Double],
) -> Double raise SpectrumError {
  quantile(signal, 0.75) - quantile(signal, 0.25)
}

///|
/// Clamps every sample to the inclusive interval `[lower, upper]`.
pub fn clip_signal(
  signal : ArrayView[Double],
  lower : Double,
  upper : Double,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if lower > upper {
    raise InvalidArgument(message="lower must not exceed upper")
  }
  let out : Array[Double] = []
  for value in signal {
    out.push(
      if value < lower {
        lower
      } else if value > upper {
        upper
      } else {
        value
      },
    )
  }
  out
}

///|
/// Returns sample indices where a signal crosses a threshold in either direction.
pub fn threshold_crossings(
  signal : ArrayView[Double],
  threshold : Double,
) -> Array[Int] raise SpectrumError {
  if signal.length() < 2 {
    raise InvalidArgument(message="threshold crossings need two samples")
  }
  let crossings : Array[Int] = []
  for i in 1..<signal.length() {
    let was_below = signal[i - 1] < threshold
    let is_below = signal[i] < threshold
    if was_below != is_below {
      crossings.push(i)
    }
  }
  crossings
}

///|
/// Returns the indices at which adjacent samples have strictly opposite signs.
pub fn zero_crossing_indices(
  signal : ArrayView[Double],
) -> Array[Int] raise SpectrumError {
  if signal.length() < 2 {
    raise InvalidArgument(message="zero crossing indices need two samples")
  }
  let crossings : Array[Int] = []
  for i in 1..<signal.length() {
    if (signal[i - 1] < 0.0 && signal[i] > 0.0) ||
      (signal[i - 1] > 0.0 && signal[i] < 0.0) {
      crossings.push(i)
    }
  }
  crossings
}
