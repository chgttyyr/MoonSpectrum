///|
pub fn signal_stats(
  signal : ArrayView[Double],
) -> SignalStats raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise EmptySignal
  }
  let mut total = 0.0
  let mut sum_squares = 0.0
  let mut minimum = signal[0]
  let mut maximum = signal[0]
  for value in signal {
    total = total + value
    sum_squares = sum_squares + value * value
    if value < minimum {
      minimum = value
    }
    if value > maximum {
      maximum = value
    }
  }
  let count = Double::from_int(n)
  let mean = total / count
  let mut centered_squares = 0.0
  for value in signal {
    let delta = value - mean
    centered_squares = centered_squares + delta * delta
  }
  let variance = centered_squares / count
  {
    count: n,
    mean,
    variance,
    stddev: variance.sqrt(),
    rms: (sum_squares / count).sqrt(),
    minimum,
    maximum,
    peak_to_peak: maximum - minimum,
  }
}

///|
pub fn center(signal : ArrayView[Double]) -> Array[Double] raise SpectrumError {
  let stats = signal_stats(signal)
  signal.map(value => value - stats.mean)
}

///|
pub fn detrend_linear(
  signal : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  let stats = signal_stats(signal)
  let n = signal.length()
  if n == 1 {
    return [0.0]
  }
  let x_mean = Double::from_int(n - 1) / 2.0
  let mut denominator = 0.0
  let mut numerator = 0.0
  for i in 0..<n {
    let x = Double::from_int(i) - x_mean
    denominator = denominator + x * x
    numerator = numerator + x * (signal[i] - stats.mean)
  }
  let slope = numerator / denominator
  let intercept = stats.mean - slope * x_mean
  let out = Array::make(n, 0.0)
  for i in 0..<n {
    let x = Double::from_int(i)
    out[i] = signal[i] - (intercept + slope * x)
  }
  out
}

///|
pub fn normalize_peak(
  signal : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  let stats = signal_stats(signal)
  let mut scale = stats.minimum.abs()
  if stats.maximum.abs() > scale {
    scale = stats.maximum.abs()
  }
  if scale == 0.0 {
    return Array::make(stats.count, 0.0)
  }
  signal.map(value => value / scale)
}
