///|
fn sinc(x : Double) -> Double {
  if x == 0.0 {
    1.0
  } else {
    let px = @math.PI * x
    @math.sin(px) / px
  }
}

///|
pub fn resample_linear(
  signal : ArrayView[Double],
  target_length : Int,
) -> Array[Double] raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise EmptySignal
  }
  if target_length <= 0 {
    raise InvalidArgument(message="target_length must be positive")
  }
  if target_length == 1 {
    return [signal[0]]
  }
  if n == 1 {
    return Array::make(target_length, signal[0])
  }
  let out = Array::make(target_length, 0.0)
  let ratio = Double::from_int(n - 1) / Double::from_int(target_length - 1)
  for i in 0..<target_length {
    let x = Double::from_int(i) * ratio
    let x_floor = x.floor().to_int()
    let x_ceil = if x_floor + 1 < n { x_floor + 1 } else { n - 1 }
    let t = x - Double::from_int(x_floor)
    out[i] = (1.0 - t) * signal[x_floor] + t * signal[x_ceil]
  }
  out
}

///|
pub fn resample_sinc(
  signal : ArrayView[Double],
  target_length : Int,
) -> Array[Double] raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise EmptySignal
  }
  if target_length <= 0 {
    raise InvalidArgument(message="target_length must be positive")
  }
  if target_length == 1 {
    return [signal[0]]
  }
  if n == 1 {
    return Array::make(target_length, signal[0])
  }
  let out = Array::make(target_length, 0.0)
  let ratio = Double::from_int(n - 1) / Double::from_int(target_length - 1)
  for i in 0..<target_length {
    let x = Double::from_int(i) * ratio
    let mut sum = 0.0
    for j in 0..<n {
      let diff = x - Double::from_int(j)
      sum = sum + signal[j] * sinc(diff)
    }
    out[i] = sum
  }
  out
}
