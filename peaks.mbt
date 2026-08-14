///|
pub fn find_peaks(
  signal : ArrayView[Double],
  threshold? : Double = 0.0,
  min_distance? : Int = 1,
) -> Array[SignalPeak] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if threshold < 0.0 {
    raise InvalidArgument(message="threshold must be non-negative")
  }
  if min_distance <= 0 {
    raise InvalidArgument(message="min_distance must be positive")
  }
  let candidates : Array[SignalPeak] = []
  if signal.length() >= 3 {
    for i in 1..<(signal.length() - 1) {
      let value = signal[i]
      if value >= threshold && value > signal[i - 1] && value >= signal[i + 1] {
        candidates.push({ index: i, value })
      }
    }
  }
  let selected : Array[SignalPeak] = []
  let blocked = Array::make(candidates.length(), false)
  let mut remaining = candidates.length()
  while remaining > 0 {
    let mut best = -1
    for i in 0..<candidates.length() {
      if !blocked[i] &&
        (best < 0 || candidates[i].value > candidates[best].value) {
        best = i
      }
    }
    if best < 0 {
      remaining = 0
    } else {
      selected.push(candidates[best])
      for i in 0..<candidates.length() {
        if !blocked[i] &&
          (candidates[i].index - candidates[best].index).abs() < min_distance {
          blocked[i] = true
          remaining = remaining - 1
        }
      }
    }
  }
  selected
}
