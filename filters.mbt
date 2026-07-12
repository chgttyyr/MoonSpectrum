///|
pub fn moving_average(
  signal : ArrayView[Double],
  width : Int,
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if width <= 0 {
    raise InvalidArgument(message="width must be positive")
  }
  let out : Array[Double] = []
  for i in 0..<signal.length() {
    let start = if i + 1 < width { 0 } else { i + 1 - width }
    let mut sum = 0.0
    let mut count = 0
    for j in start..<=i {
      sum = sum + signal[j]
      count = count + 1
    }
    out.push(sum / Double::from_int(count))
  }
  out
}

///|
pub fn fir_filter(
  signal : ArrayView[Double],
  taps : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  convolve(signal, taps)
}

///|
pub fn lowpass_taps(
  length~ : Int,
  cutoff_hz~ : Double,
  sample_rate~ : Double,
) -> Array[Double] raise SpectrumError {
  validate_filter_args(length, cutoff_hz, sample_rate)
  let fc = cutoff_hz / sample_rate
  let mid = (length - 1) / 2
  let win = window(Hamming, length)
  let taps : Array[Double] = []
  for n in 0..<length {
    let x = n - mid
    let raw = if x == 0 {
      2.0 * fc
    } else {
      @math.sin(2.0 * @math.PI * fc * Double::from_int(x)) /
      (@math.PI * Double::from_int(x))
    }
    taps.push(raw * win[n])
  }
  normalize_taps(taps)
}

///|
pub fn highpass_taps(
  length~ : Int,
  cutoff_hz~ : Double,
  sample_rate~ : Double,
) -> Array[Double] raise SpectrumError {
  let low = lowpass_taps(length~, cutoff_hz~, sample_rate~)
  let mid = (length - 1) / 2
  let out : Array[Double] = []
  for i in 0..<length {
    out.push(if i == mid { 1.0 - low[i] } else { -low[i] })
  }
  out
}

///|
fn validate_filter_args(
  length : Int,
  cutoff_hz : Double,
  sample_rate : Double,
) -> Unit raise SpectrumError {
  if length <= 0 {
    raise EmptySignal
  }
  if length % 2 == 0 {
    raise InvalidArgument(message="tap length must be odd")
  }
  if cutoff_hz <= 0.0 || sample_rate <= 0.0 || cutoff_hz >= sample_rate / 2.0 {
    raise InvalidArgument(message="cutoff must be between 0 and Nyquist")
  }
}

///|
fn normalize_taps(taps : Array[Double]) -> Array[Double] raise SpectrumError {
  let sum = taps.fold(init=0.0, (acc, item) => acc + item)
  if sum == 0.0 {
    raise InvalidArgument(message="tap sum is zero")
  }
  taps.map(item => item / sum)
}

///|
pub fn bandpass_fir_taps(
  length~ : Int,
  low_cutoff_hz~ : Double,
  high_cutoff_hz~ : Double,
  sample_rate~ : Double,
) -> Array[Double] raise SpectrumError {
  if low_cutoff_hz >= high_cutoff_hz {
    raise InvalidArgument(message="low_cutoff must be less than high_cutoff")
  }
  let low1 = lowpass_taps(length~, cutoff_hz=low_cutoff_hz, sample_rate~)
  let low2 = lowpass_taps(length~, cutoff_hz=high_cutoff_hz, sample_rate~)
  let out : Array[Double] = []
  for i in 0..<length {
    out.push(low2[i] - low1[i])
  }
  out
}

///|
pub fn bandstop_fir_taps(
  length~ : Int,
  low_cutoff_hz~ : Double,
  high_cutoff_hz~ : Double,
  sample_rate~ : Double,
) -> Array[Double] raise SpectrumError {
  if low_cutoff_hz >= high_cutoff_hz {
    raise InvalidArgument(message="low_cutoff must be less than high_cutoff")
  }
  let low1 = lowpass_taps(length~, cutoff_hz=low_cutoff_hz, sample_rate~)
  let low2 = lowpass_taps(length~, cutoff_hz=high_cutoff_hz, sample_rate~)
  let mid = (length - 1) / 2
  let out : Array[Double] = []
  for i in 0..<length {
    let delta = if i == mid { 1.0 } else { 0.0 }
    out.push(delta - (low2[i] - low1[i]))
  }
  out
}
