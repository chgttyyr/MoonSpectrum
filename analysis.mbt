///|
pub fn magnitude_spectrum(spectrum : ArrayView[Complex]) -> Array[Double] {
  spectrum.map(item => item.magnitude())
}

///|
pub fn power_spectrum(spectrum : ArrayView[Complex]) -> Array[Double] {
  spectrum.map(item => item.re * item.re + item.im * item.im)
}

///|
pub fn frequency_bins(length : Int, sample_rate : Double) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(sample_rate)
  raise SpectrumError::EmptySignal
}

///|
pub fn dominant_peak(spectrum : ArrayView[Complex], sample_rate : Double) -> Peak raise SpectrumError {
  ignore(spectrum)
  ignore(sample_rate)
  raise SpectrumError::EmptySignal
}

