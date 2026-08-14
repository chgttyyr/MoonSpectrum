///|
test "spectral features describe a dominant tone" {
  let signal = sine_wave(length=8, sample_rate=8.0, frequency=2.0)
  let spectrum = fft(real_signal(signal))
  let magnitudes = magnitude_spectrum(spectrum)
  assert_close(spectral_centroid(magnitudes, 8.0), 2.0)
  assert_true(spectral_bandwidth(magnitudes, 8.0) > 0.0)
  assert_true(spectral_flatness(magnitudes) < 0.5)
  assert_true(spectral_entropy(magnitudes) > 0.0)
  assert_close(spectral_rolloff(magnitudes, 8.0, ratio=0.85), 2.0)
}

///|
test "spectral features handle flat and empty inputs" {
  assert_close(spectral_flatness([1.0, 1.0, 1.0, 1.0]), 1.0)
  assert_close(spectral_entropy([1.0, 1.0, 1.0, 1.0]), 2.0)
  try spectral_centroid([], 8.0) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected empty spectrum error")
  }
}
