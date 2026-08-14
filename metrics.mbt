///|
pub fn mean_absolute_error(
  reference : ArrayView[Double],
  estimate : ArrayView[Double],
) -> Double raise SpectrumError {
  validate_metric_inputs(reference, estimate)
  let mut total = 0.0
  for i in 0..<reference.length() {
    total = total + (reference[i] - estimate[i]).abs()
  }
  total / Double::from_int(reference.length())
}

///|
pub fn root_mean_square_error(
  reference : ArrayView[Double],
  estimate : ArrayView[Double],
) -> Double raise SpectrumError {
  validate_metric_inputs(reference, estimate)
  let mut total = 0.0
  for i in 0..<reference.length() {
    let error = reference[i] - estimate[i]
    total = total + error * error
  }
  (total / Double::from_int(reference.length())).sqrt()
}

///|
pub fn signal_to_noise_db(
  reference : ArrayView[Double],
  estimate : ArrayView[Double],
) -> Double raise SpectrumError {
  validate_metric_inputs(reference, estimate)
  let mut signal_power = 0.0
  let mut noise_power = 0.0
  for i in 0..<reference.length() {
    signal_power = signal_power + reference[i] * reference[i]
    let error = reference[i] - estimate[i]
    noise_power = noise_power + error * error
  }
  if signal_power == 0.0 || noise_power == 0.0 {
    raise InvalidArgument(message="signal and noise powers must be non-zero")
  }
  10.0 * @math.log10(signal_power / noise_power)
}

///|
pub fn correlation_coefficient(
  left : ArrayView[Double],
  right : ArrayView[Double],
) -> Double raise SpectrumError {
  validate_metric_inputs(left, right)
  let left_stats = signal_stats(left)
  let right_stats = signal_stats(right)
  if left_stats.variance == 0.0 || right_stats.variance == 0.0 {
    raise InvalidArgument(message="correlation needs non-constant signals")
  }
  let mut covariance = 0.0
  for i in 0..<left.length() {
    covariance = covariance +
      (left[i] - left_stats.mean) * (right[i] - right_stats.mean)
  }
  covariance /
  Double::from_int(left.length()) /
  (left_stats.stddev * right_stats.stddev)
}

///|
pub fn normalize_range(
  signal : ArrayView[Double],
  lower : Double,
  upper : Double,
) -> Array[Double] raise SpectrumError {
  let stats = signal_stats(signal)
  if upper <= lower {
    raise InvalidArgument(message="upper range must exceed lower range")
  }
  if stats.maximum == stats.minimum {
    return Array::make(stats.count, (lower + upper) / 2.0)
  }
  let scale = (upper - lower) / (stats.maximum - stats.minimum)
  signal.map(value => lower + (value - stats.minimum) * scale)
}

///|
fn validate_metric_inputs(
  left : ArrayView[Double],
  right : ArrayView[Double],
) -> Unit raise SpectrumError {
  if left.length() == 0 || right.length() == 0 {
    raise EmptySignal
  }
  if left.length() != right.length() {
    raise LengthMismatch
  }
}
