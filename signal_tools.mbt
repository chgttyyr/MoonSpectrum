///|
pub fn signal_energy(signal : ArrayView[Double]) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let mut total = 0.0
  for value in signal {
    total = total + value * value
  }
  total
}

///|
pub fn zero_crossing_rate(
  signal : ArrayView[Double],
) -> Double raise SpectrumError {
  if signal.length() < 2 {
    raise InvalidArgument(message="zero crossing rate needs two samples")
  }
  let mut crossings = 0
  for i in 1..<signal.length() {
    if signal[i - 1] * signal[i] < 0.0 {
      crossings = crossings + 1
    }
  }
  Double::from_int(crossings) / Double::from_int(signal.length() - 1)
}

///|
pub fn differentiate(
  signal : ArrayView[Double],
  sample_interval : Double,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if sample_interval <= 0.0 {
    raise InvalidArgument(message="sample_interval must be positive")
  }
  if signal.length() == 1 {
    return [0.0]
  }
  let out = Array::make(signal.length(), 0.0)
  for i in 0..<(signal.length() - 1) {
    out[i] = (signal[i + 1] - signal[i]) / sample_interval
  }
  let last = signal.length() - 1
  out[last] = (signal[last] - signal[last - 1]) / sample_interval
  out
}

///|
pub fn integrate_trapezoid(
  signal : ArrayView[Double],
  sample_interval : Double,
) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if sample_interval <= 0.0 {
    raise InvalidArgument(message="sample_interval must be positive")
  }
  if signal.length() == 1 {
    return 0.0
  }
  let mut area = 0.0
  for i in 1..<signal.length() {
    area = area + (signal[i - 1] + signal[i]) * sample_interval / 2.0
  }
  area
}

///|
pub fn quantile(
  signal : ArrayView[Double],
  probability : Double,
) -> Double raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if probability < 0.0 || probability > 1.0 {
    raise InvalidArgument(message="probability must be in [0, 1]")
  }
  let sorted = insertion_sorted(signal)
  if sorted.length() == 1 {
    return sorted[0]
  }
  let position = probability * Double::from_int(sorted.length() - 1)
  let lower = position.floor().to_int()
  let upper = if lower + 1 < sorted.length() { lower + 1 } else { lower }
  let fraction = position - Double::from_int(lower)
  sorted[lower] * (1.0 - fraction) + sorted[upper] * fraction
}

///|
pub fn median(signal : ArrayView[Double]) -> Double raise SpectrumError {
  quantile(signal, 0.5)
}

///|
pub fn moving_rms(
  signal : ArrayView[Double],
  width : Int,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if width <= 0 {
    raise InvalidArgument(message="width must be positive")
  }
  let out = Array::make(signal.length(), 0.0)
  let mut sum = 0.0
  for i in 0..<signal.length() {
    sum = sum + signal[i] * signal[i]
    if i >= width {
      sum = sum - signal[i - width] * signal[i - width]
    }
    let count = if i + 1 < width { i + 1 } else { width }
    out[i] = (sum / Double::from_int(count)).sqrt()
  }
  out
}

///|
fn insertion_sorted(signal : ArrayView[Double]) -> Array[Double] {
  let sorted : Array[Double] = []
  for value in signal {
    let mut index = 0
    while index < sorted.length() && sorted[index] <= value {
      index = index + 1
    }
    sorted.insert(index, value)
  }
  sorted
}
