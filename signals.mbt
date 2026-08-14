///|
pub fn sine_wave(
  length~ : Int,
  sample_rate~ : Double,
  frequency~ : Double,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  validate_signal_args(length, sample_rate)
  let out : Array[Double] = []
  for i in 0..<length {
    let t = Double::from_int(i) / sample_rate
    out.push(amplitude * @math.sin(2.0 * @math.PI * frequency * t))
  }
  out
}

///|
pub fn square_wave(
  length~ : Int,
  sample_rate~ : Double,
  frequency~ : Double,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  validate_signal_args(length, sample_rate)
  let out : Array[Double] = []
  for i in 0..<length {
    let t = Double::from_int(i) / sample_rate
    let phase = @math.sin(2.0 * @math.PI * frequency * t)
    out.push(if phase >= 0.0 { amplitude } else { -amplitude })
  }
  out
}

///|
pub fn impulse(
  length~ : Int,
  index? : Int = 0,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  if index < 0 || index >= length {
    raise InvalidArgument(message="impulse index out of range")
  }
  let out = Array::make(length, 0.0)
  out[index] = amplitude
  out
}

///|
pub fn chirp(
  length~ : Int,
  sample_rate~ : Double,
  start_hz~ : Double,
  end_hz~ : Double,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  validate_signal_args(length, sample_rate)
  let duration = Double::from_int(length) / sample_rate
  let slope = (end_hz - start_hz) / duration
  let out : Array[Double] = []
  for i in 0..<length {
    let t = Double::from_int(i) / sample_rate
    let phase = 2.0 * @math.PI * (start_hz * t + 0.5 * slope * t * t)
    out.push(amplitude * @math.sin(phase))
  }
  out
}

///|
pub fn white_noise(
  length~ : Int,
  seed~ : UInt,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  let out : Array[Double] = []
  let mut state = seed.reinterpret_as_int() % 2147483
  for _ in 0..<length {
    state = (state * 1103 + 12345) % 2147483
    let unit = Double::from_int(state) / 2147483.0
    out.push((unit * 2.0 - 1.0) * amplitude)
  }
  out
}

///|
pub fn triangle_wave(
  length~ : Int,
  sample_rate~ : Double,
  frequency~ : Double,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  validate_signal_args(length, sample_rate)
  if frequency <= 0.0 || frequency > sample_rate / 2.0 {
    raise InvalidArgument(message="frequency must be between zero and Nyquist")
  }
  let out : Array[Double] = []
  for i in 0..<length {
    let phase = Double::from_int(i) * frequency / sample_rate
    let cycle = phase - phase.floor()
    let value = if cycle < 0.25 {
      4.0 * cycle
    } else if cycle < 0.75 {
      2.0 - 4.0 * cycle
    } else {
      -4.0 + 4.0 * cycle
    }
    out.push(amplitude * value)
  }
  out
}

///|
pub fn sawtooth_wave(
  length~ : Int,
  sample_rate~ : Double,
  frequency~ : Double,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  validate_signal_args(length, sample_rate)
  if frequency <= 0.0 || frequency > sample_rate / 2.0 {
    raise InvalidArgument(message="frequency must be between zero and Nyquist")
  }
  let out : Array[Double] = []
  for i in 0..<length {
    let phase = Double::from_int(i) * frequency / sample_rate
    let cycle = phase - phase.floor()
    out.push(amplitude * (2.0 * cycle - 1.0))
  }
  out
}

///|
pub fn pulse_train(
  length~ : Int,
  period~ : Int,
  amplitude? : Double = 1.0,
) -> Array[Double] raise SpectrumError {
  if length <= 0 || period <= 0 {
    raise InvalidArgument(message="length and period must be positive")
  }
  let out = Array::make(length, 0.0)
  for i in 0..<length {
    if i % period == 0 {
      out[i] = amplitude
    }
  }
  out
}

///|
fn validate_signal_args(
  length : Int,
  sample_rate : Double,
) -> Unit raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
}
