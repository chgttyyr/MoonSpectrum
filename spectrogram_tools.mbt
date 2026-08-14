///|
/// Computes positive-frequency magnitude frames and their time coordinates.
pub fn spectrogram(
  signal : ArrayView[Double],
  window_kind : WindowKind,
  window_length~ : Int,
  hop_size~ : Int,
  sample_rate~ : Double,
) -> SpectrogramResult raise SpectrumError {
  if signal.length() == 0 {
    raise EmptySignal
  }
  if sample_rate <= 0.0 {
    raise InvalidArgument(message="sample_rate must be positive")
  }
  let frames = stft(signal, window_kind, window_length, hop_size)
  let half = window_length / 2
  let frequencies : Array[Double] = []
  for i in 0..<=half {
    frequencies.push(
      Double::from_int(i) * sample_rate / Double::from_int(window_length),
    )
  }
  let frame_times : Array[Double] = []
  let magnitudes : Array[Array[Double]] = []
  for frame_index, frame in frames {
    let all_magnitudes = magnitude_spectrum(frame)
    frame_times.push(Double::from_int(frame_index * hop_size) / sample_rate)
    let end = half + 1
    magnitudes.push(all_magnitudes[0:end].to_owned())
  }
  { frequencies, frame_times, magnitudes }
}

///|
/// Returns the sum of squared positive-frequency magnitudes for each frame.
pub fn spectrogram_energy(result : SpectrogramResult) -> Array[Double] {
  result.magnitudes.map(frame => {
    frame.fold(init=0.0, (total, value) => total + value * value)
  })
}

///|
/// Returns the dominant positive-frequency peak for every spectrogram frame.
pub fn spectrogram_dominant_peaks(
  result : SpectrogramResult,
) -> Array[Peak] raise SpectrumError {
  if result.magnitudes.length() == 0 {
    raise EmptySignal
  }
  let peaks : Array[Peak] = []
  for frame in result.magnitudes {
    let mut best = 0
    for i in 1..<frame.length() {
      if frame[i] > frame[best] {
        best = i
      }
    }
    peaks.push({
      index: best,
      frequency: result.frequencies[best],
      magnitude: frame[best],
    })
  }
  peaks
}

///|
/// Returns the frame index with the highest total energy.
pub fn spectrogram_loudest_frame(
  result : SpectrogramResult,
) -> Int raise SpectrumError {
  let energies = spectrogram_energy(result)
  if energies.length() == 0 {
    raise EmptySignal
  }
  let mut best = 0
  for i in 1..<energies.length() {
    if energies[i] > energies[best] {
      best = i
    }
  }
  best
}
