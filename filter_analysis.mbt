///|
/// Creates the response of a finite impulse response filter to a unit impulse.
pub fn fir_impulse_response(
  taps : ArrayView[Double],
  response_length : Int,
) -> Array[Double] raise SpectrumError {
  if taps.length() == 0 {
    raise EmptySignal
  }
  if response_length <= 0 {
    raise InvalidArgument(message="response_length must be positive")
  }
  let output = Array::make(response_length, 0.0)
  let count = if taps.length() < response_length {
    taps.length()
  } else {
    response_length
  }
  for i in 0..<count {
    output[i] = taps[i]
  }
  output
}

///|
/// Measures the positive-frequency response of an FIR filter by zero-padded FFT.
pub fn fir_frequency_response(
  taps : ArrayView[Double],
  sample_rate~ : Double,
  fft_length~ : Int,
) -> FrequencyResponse raise SpectrumError {
  if taps.length() == 0 {
    raise EmptySignal
  }
  validate_response_geometry(sample_rate, fft_length)
  if taps.length() > fft_length {
    raise InvalidArgument(message="fft_length must contain all taps")
  }
  let padded = Array::make(fft_length, 0.0)
  for i in 0..<taps.length() {
    padded[i] = taps[i]
  }
  let transformed = fft(real_signal(padded))
  response_from_spectrum(transformed, sample_rate)
}

///|
/// Measures the positive-frequency response of a biquad section.
pub fn biquad_frequency_response(
  filter : Biquad,
  sample_rate~ : Double,
  fft_length~ : Int,
) -> FrequencyResponse raise SpectrumError {
  validate_response_geometry(sample_rate, fft_length)
  let half = fft_length / 2
  let frequencies : Array[Double] = []
  let magnitude : Array[Double] = []
  for k in 0..<=half {
    let angle = 2.0 *
      @math.PI *
      Double::from_int(k) /
      Double::from_int(fft_length)
    let z1 = complex(re=@math.cos(angle), im=-@math.sin(angle))
    let z2 = z1.mul(z1)
    let numerator = complex(re=filter.b0, im=0.0)
      .add(z1.scale(filter.b1))
      .add(z2.scale(filter.b2))
    let denominator = complex(re=1.0, im=0.0)
      .add(z1.scale(filter.a1))
      .add(z2.scale(filter.a2))
    let denominator_power = denominator.re * denominator.re +
      denominator.im * denominator.im
    let real_part = (
        numerator.re * denominator.re + numerator.im * denominator.im
      ) /
      denominator_power
    let imaginary_part = (
        numerator.im * denominator.re - numerator.re * denominator.im
      ) /
      denominator_power
    frequencies.push(
      Double::from_int(k) * sample_rate / Double::from_int(fft_length),
    )
    magnitude.push(
      (real_part * real_part + imaginary_part * imaginary_part).sqrt(),
    )
  }
  { frequencies, magnitude }
}

///|
/// Returns the maximum magnitude and its frequency from a response.
pub fn response_peak(response : FrequencyResponse) -> Peak raise SpectrumError {
  if response.magnitude.length() == 0 {
    raise EmptySignal
  }
  let mut best = 0
  for i in 1..<response.magnitude.length() {
    if response.magnitude[i] > response.magnitude[best] {
      best = i
    }
  }
  {
    index: best,
    frequency: response.frequencies[best],
    magnitude: response.magnitude[best],
  }
}

///|
fn validate_response_geometry(
  sample_rate : Double,
  fft_length : Int,
) -> Unit raise SpectrumError {
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  if fft_length <= 0 {
    raise EmptySignal
  }
  if !is_power_of_two(fft_length) {
    raise NonPowerOfTwo(length=fft_length)
  }
}

///|
fn response_from_spectrum(
  spectrum : ArrayView[Complex],
  sample_rate : Double,
) -> FrequencyResponse {
  let half = spectrum.length() / 2
  let frequencies : Array[Double] = []
  let magnitude : Array[Double] = []
  for i in 0..<=half {
    frequencies.push(
      Double::from_int(i) * sample_rate / Double::from_int(spectrum.length()),
    )
    magnitude.push(spectrum[i].magnitude())
  }
  { frequencies, magnitude }
}
