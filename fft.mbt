///|
pub fn dft(signal : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  ignore(signal)
  raise SpectrumError::EmptySignal
}

///|
pub fn fft(signal : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  ignore(signal)
  raise SpectrumError::EmptySignal
}

///|
pub fn ifft(spectrum : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  ignore(spectrum)
  raise SpectrumError::EmptySignal
}

///|
pub fn real_signal(values : ArrayView[Double]) -> Array[Complex] {
  values.map(v => complex(re=v, im=0.0))
}

