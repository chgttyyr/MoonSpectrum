///|
test "spectrogram summarizes frames and positive frequencies" {
  let signal = sine_wave(length=16, sample_rate=8.0, frequency=2.0)
  let result = spectrogram(
    signal,
    Hann,
    window_length=8,
    hop_size=4,
    sample_rate=8.0,
  )
  inspect(result.magnitudes.length(), content="3")
  inspect(result.magnitudes[0].length(), content="5")
  assert_close(result.frequencies[2], 2.0)
  assert_close(result.frame_times[1], 0.5)
  let energies = spectrogram_energy(result)
  assert_true(energies[0] > 0.0)
  let peaks = spectrogram_dominant_peaks(result)
  inspect(peaks[0].index, content="2")
  assert_close(peaks[0].frequency, 2.0)
}

///|
test "spectrogram rejects short and invalid signals" {
  try
    spectrogram([], Hann, window_length=8, hop_size=4, sample_rate=8.0)
  catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected empty error")
  }
}
