///|
pub fn sine_wave(length~ : Int, sample_rate~ : Double, frequency~ : Double, amplitude? : Double = 1.0) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(sample_rate)
  ignore(frequency)
  ignore(amplitude)
  raise SpectrumError::EmptySignal
}

///|
pub fn square_wave(length~ : Int, sample_rate~ : Double, frequency~ : Double, amplitude? : Double = 1.0) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(sample_rate)
  ignore(frequency)
  ignore(amplitude)
  raise SpectrumError::EmptySignal
}

///|
pub fn impulse(length~ : Int, index? : Int = 0, amplitude? : Double = 1.0) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(index)
  ignore(amplitude)
  raise SpectrumError::EmptySignal
}

///|
pub fn chirp(length~ : Int, sample_rate~ : Double, start_hz~ : Double, end_hz~ : Double, amplitude? : Double = 1.0) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(sample_rate)
  ignore(start_hz)
  ignore(end_hz)
  ignore(amplitude)
  raise SpectrumError::EmptySignal
}

///|
pub fn white_noise(length~ : Int, seed~ : UInt, amplitude? : Double = 1.0) -> Array[Double] raise SpectrumError {
  ignore(length)
  ignore(seed)
  ignore(amplitude)
  raise SpectrumError::EmptySignal
}

