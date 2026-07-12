///|
pub(all) struct Biquad {
  mut b0 : Double
  mut b1 : Double
  mut b2 : Double
  mut a1 : Double
  mut a2 : Double
  mut x1 : Double
  mut x2 : Double
  mut y1 : Double
  mut y2 : Double
} derive(Debug, Eq, ToJson)

///|
pub fn Biquad::new(
  b0 : Double,
  b1 : Double,
  b2 : Double,
  a1 : Double,
  a2 : Double,
) -> Biquad {
  { b0, b1, b2, a1, a2, x1: 0.0, x2: 0.0, y1: 0.0, y2: 0.0 }
}

///|
pub fn Biquad::lowpass(
  cutoff_hz : Double,
  sample_rate : Double,
  q? : Double = 0.707,
) -> Biquad raise SpectrumError {
  if cutoff_hz <= 0.0 || sample_rate <= 0.0 || cutoff_hz >= sample_rate / 2.0 {
    raise InvalidArgument(message="cutoff must be between 0 and Nyquist")
  }
  let w0 = 2.0 * @math.PI * cutoff_hz / sample_rate
  let cosw = @math.cos(w0)
  let sinw = @math.sin(w0)
  let alpha = sinw / (2.0 * q)

  let b0 = (1.0 - cosw) / 2.0
  let b1 = 1.0 - cosw
  let b2 = (1.0 - cosw) / 2.0
  let a0 = 1.0 + alpha
  let a1 = -2.0 * cosw
  let a2 = 1.0 - alpha

  Biquad::new(b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0)
}

///|
pub fn Biquad::highpass(
  cutoff_hz : Double,
  sample_rate : Double,
  q? : Double = 0.707,
) -> Biquad raise SpectrumError {
  if cutoff_hz <= 0.0 || sample_rate <= 0.0 || cutoff_hz >= sample_rate / 2.0 {
    raise InvalidArgument(message="cutoff must be between 0 and Nyquist")
  }
  let w0 = 2.0 * @math.PI * cutoff_hz / sample_rate
  let cosw = @math.cos(w0)
  let sinw = @math.sin(w0)
  let alpha = sinw / (2.0 * q)

  let b0 = (1.0 + cosw) / 2.0
  let b1 = -(1.0 + cosw)
  let b2 = (1.0 + cosw) / 2.0
  let a0 = 1.0 + alpha
  let a1 = -2.0 * cosw
  let a2 = 1.0 - alpha

  Biquad::new(b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0)
}

///|
pub fn Biquad::bandpass(
  cutoff_hz : Double,
  sample_rate : Double,
  q? : Double = 0.707,
) -> Biquad raise SpectrumError {
  if cutoff_hz <= 0.0 || sample_rate <= 0.0 || cutoff_hz >= sample_rate / 2.0 {
    raise InvalidArgument(message="cutoff must be between 0 and Nyquist")
  }
  let w0 = 2.0 * @math.PI * cutoff_hz / sample_rate
  let cosw = @math.cos(w0)
  let sinw = @math.sin(w0)
  let alpha = sinw / (2.0 * q)

  let b0 = alpha
  let b1 = 0.0
  let b2 = -alpha
  let a0 = 1.0 + alpha
  let a1 = -2.0 * cosw
  let a2 = 1.0 - alpha

  Biquad::new(b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0)
}

///|
pub fn Biquad::step(self : Biquad, x : Double) -> Double {
  let y = self.b0 *
    x +
    self.b1 *
    self.x1 +
    self.b2 *
    self.x2 -
    self.a1 *
    self.y1 -
    self.a2 *
    self.y2
  self.x2 = self.x1
  self.x1 = x
  self.y2 = self.y1
  self.y1 = y
  y
}

///|
pub fn Biquad::filter(
  self : Biquad,
  signal : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  let out = Array::make(signal.length(), 0.0)
  for i in 0..<signal.length() {
    out[i] = self.step(signal[i])
  }
  out
}
