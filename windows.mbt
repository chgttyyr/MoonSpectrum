///|
pub fn window(kind : WindowKind, length : Int) -> Array[Double] raise SpectrumError {
  ignore(kind)
  ignore(length)
  raise SpectrumError::EmptySignal
}

///|
pub fn apply_window(signal : ArrayView[Double], weights : ArrayView[Double]) -> Array[Double] raise SpectrumError {
  ignore(signal)
  ignore(weights)
  raise SpectrumError::EmptySignal
}

