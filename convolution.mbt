///|
pub fn convolve(signal : ArrayView[Double], kernel : ArrayView[Double]) -> Array[Double] raise SpectrumError {
  let n = signal.length()
  let m = kernel.length()
  if n == 0 || m == 0 {
    raise SpectrumError::EmptySignal
  }
  let out = Array::make(n + m - 1, 0.0)
  for i in 0..<n {
    for j in 0..<m {
      out[i + j] = out[i + j] + signal[i] * kernel[j]
    }
  }
  out
}

///|
pub fn circular_convolve(signal : ArrayView[Double], kernel : ArrayView[Double]) -> Array[Double] raise SpectrumError {
  let n = signal.length()
  let m = kernel.length()
  if n == 0 || m == 0 {
    raise SpectrumError::EmptySignal
  }
  let len = if n > m { n } else { m }
  let out = Array::make(len, 0.0)
  for i in 0..<n {
    for j in 0..<m {
      let idx = (i + j) % len
      out[idx] = out[idx] + signal[i] * kernel[j]
    }
  }
  out
}
