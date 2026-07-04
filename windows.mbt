///|
pub fn window(
  kind : WindowKind,
  length : Int,
) -> Array[Double] raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  if length == 1 {
    [1.0]
  } else {
    let out : Array[Double] = []
    let denom = Double::from_int(length - 1)
    for n in 0..<length {
      let x = 2.0 * @math.PI * Double::from_int(n) / denom
      out.push(
        match kind {
          Rectangular => 1.0
          Hann => 0.5 - 0.5 * @math.cos(x)
          Hamming => 0.54 - 0.46 * @math.cos(x)
          Blackman => 0.42 - 0.5 * @math.cos(x) + 0.08 * @math.cos(2.0 * x)
        },
      )
    }
    out
  }
}

///|
pub fn apply_window(
  signal : ArrayView[Double],
  weights : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if signal.length() != weights.length() {
    raise LengthMismatch
  }
  let out : Array[Double] = []
  for i in 0..<signal.length() {
    out.push(signal[i] * weights[i])
  }
  out
}
