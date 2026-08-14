///|
pub fn autocorrelation(
  signal : ArrayView[Double],
  max_lag : Int,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if max_lag < 0 || max_lag >= signal.length() {
    raise InvalidArgument(message="max_lag must be within the signal length")
  }
  let result = Array::make(max_lag + 1, 0.0)
  for lag in 0..<=max_lag {
    let mut total = 0.0
    for i in 0..<(signal.length() - lag) {
      total = total + signal[i] * signal[i + lag]
    }
    result[lag] = total
  }
  result
}

///|
pub fn cross_correlation(
  signal : ArrayView[Double],
  other : ArrayView[Double],
  max_lag : Int,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 || other.length() == 0 {
    raise EmptySignal
  }
  if signal.length() != other.length() {
    raise LengthMismatch
  }
  if max_lag < 0 || max_lag >= signal.length() {
    raise InvalidArgument(message="max_lag must be within the signal length")
  }
  let result = Array::make(max_lag + 1, 0.0)
  for lag in 0..<=max_lag {
    let mut total = 0.0
    for i in 0..<(signal.length() - lag) {
      total = total + signal[i] * other[i + lag]
    }
    result[lag] = total
  }
  result
}

///|
pub fn normalized_correlation(
  signal : ArrayView[Double],
  max_lag : Int,
) -> Array[Double] raise SpectrumError {
  let raw = autocorrelation(signal, max_lag)
  let energy = raw[0]
  if energy == 0.0 {
    return Array::make(raw.length(), 0.0)
  }
  raw.map(value => value / energy)
}

///|
pub fn full_cross_correlation(
  signal : ArrayView[Double],
  other : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 || other.length() == 0 {
    raise EmptySignal
  }
  if signal.length() != other.length() {
    raise LengthMismatch
  }
  let n = signal.length()
  let result = Array::make(2 * n - 1, 0.0)
  for output_index in 0..<result.length() {
    let lag = output_index - (n - 1)
    let mut total = 0.0
    if lag < 0 {
      let offset = -lag
      for i in 0..<(n - offset) {
        total = total + signal[i + offset] * other[i]
      }
    } else {
      for i in 0..<(n - lag) {
        total = total + signal[i] * other[i + lag]
      }
    }
    result[output_index] = total
  }
  result
}
