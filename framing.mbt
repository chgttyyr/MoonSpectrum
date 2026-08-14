///|
pub fn frame_signal(
  signal : ArrayView[Double],
  frame_length~ : Int,
  hop_size~ : Int,
) -> Array[Array[Double]] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if frame_length <= 0 || hop_size <= 0 {
    raise InvalidArgument(message="frame_length and hop_size must be positive")
  }
  if signal.length() < frame_length {
    raise InvalidArgument(message="signal is shorter than frame_length")
  }
  let count = 1 + (signal.length() - frame_length) / hop_size
  let output : Array[Array[Double]] = []
  for frame_index in 0..<count {
    let start = frame_index * hop_size
    output.push(signal[start:start + frame_length].to_owned())
  }
  output
}

///|
pub fn overlap_add(
  frames : ArrayView[Array[Double]],
  hop_size~ : Int,
) -> Array[Double] raise SpectrumError {
  if frames.length() == 0 {
    raise EmptySignal
  }
  if hop_size <= 0 {
    raise InvalidArgument(message="hop_size must be positive")
  }
  let frame_length = frames[0].length()
  if frame_length == 0 || hop_size > frame_length {
    raise InvalidArgument(message="frames must overlap or touch")
  }
  for frame in frames {
    if frame.length() != frame_length {
      raise LengthMismatch
    }
  }
  let output_length = (frames.length() - 1) * hop_size + frame_length
  let output = Array::make(output_length, 0.0)
  for frame_index in 0..<frames.length() {
    let start = frame_index * hop_size
    for i in 0..<frame_length {
      output[start + i] = output[start + i] + frames[frame_index][i]
    }
  }
  output
}
