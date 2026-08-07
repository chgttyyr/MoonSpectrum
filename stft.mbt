///|
pub fn stft(
  signal : ArrayView[Double],
  window_kind : WindowKind,
  window_length : Int,
  hop_size : Int,
) -> Array[Array[Complex]] raise SpectrumError {
  if window_length <= 0 {
    raise InvalidArgument(message="window_length must be positive")
  }
  if hop_size <= 0 {
    raise InvalidArgument(message="hop_size must be positive")
  }
  if !is_power_of_two(window_length) {
    raise NonPowerOfTwo(length=window_length)
  }
  if signal.length() < window_length {
    raise InvalidArgument(
      message="signal length must be at least window_length",
    )
  }

  let win = window(window_kind, window_length)
  let out : Array[Array[Complex]] = []

  let mut start = 0
  while start + window_length <= signal.length() {
    let end_idx = start + window_length
    let frame = signal[start:end_idx]
    let windowed = apply_window(frame, win)
    let complex_frame = real_signal(windowed)
    let fft_frame = fft(complex_frame)
    out.push(fft_frame)
    start = start + hop_size
  }
  out
}
