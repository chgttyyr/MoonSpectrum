///|
pub fn moving_average(signal : ArrayView[Double], width : Int) -> Array[Double] raise SpectrumError {
  ignore(signal)
  ignore(width)
  raise SpectrumError::EmptySignal
}

///|
pub fn fir_filter(signal : ArrayView[Double], taps : ArrayView[Double]) -> Array[Double] raise SpectrumError {
  convolve(signal, taps)
}

///|
pub fn lowpass_taps(length~ : Int, cutoff_hz~ : Double, sample_rate~ : Double) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(cutoff_hz)
  ignore(sample_rate)
  raise SpectrumError::EmptySignal
}

///|
pub fn highpass_taps(length~ : Int, cutoff_hz~ : Double, sample_rate~ : Double) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(cutoff_hz)
  ignore(sample_rate)
  raise SpectrumError::EmptySignal
}

