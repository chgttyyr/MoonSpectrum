///|
pub fn welch_psd(
  signal : ArrayView[Double],
  sample_rate~ : Double,
  segment_length~ : Int,
  overlap~ : Double,
  window_kind? : WindowKind = Rectangular,
) -> WelchResult raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  if segment_length <= 0 {
    raise InvalidArgument(message="segment_length must be positive")
  }
  if !is_power_of_two(segment_length) {
    raise NonPowerOfTwo(length=segment_length)
  }
  if overlap < 0.0 || overlap >= 1.0 {
    raise InvalidArgument(message="overlap must be in [0, 1)")
  }
  if signal.length() < segment_length {
    raise InvalidArgument(message="signal is shorter than segment_length")
  }
  let raw_step = Double::from_int(segment_length) * (1.0 - overlap)
  let step = raw_step.floor().to_int()
  if step <= 0 {
    raise InvalidArgument(message="overlap leaves no positive step")
  }
  let segment_count = 1 + (signal.length() - segment_length) / step
  let output_length = segment_length / 2 + 1
  let averaged = Array::make(output_length, 0.0)
  for segment in 0..<segment_count {
    let start = segment * step
    let frame = signal[start:start + segment_length]
    let raw = periodogram(frame, sample_rate, window_kind~)
    let one_sided = single_sided_psd(raw)
    for i in 0..<output_length {
      averaged[i] = averaged[i] + one_sided[i]
    }
  }
  let count = Double::from_int(segment_count)
  for i in 0..<output_length {
    averaged[i] = averaged[i] / count
  }
  let frequencies = Array::make(output_length, 0.0)
  for i in 0..<output_length {
    frequencies[i] = Double::from_int(i) *
      sample_rate /
      Double::from_int(segment_length)
  }
  { frequencies, psd: averaged }
}
