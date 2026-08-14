///|
test "spectral summary groups common descriptors" {
  let signal = sine_wave(length=8, sample_rate=8.0, frequency=2.0)
  let summary = spectral_summary(fft(real_signal(signal)), 8.0)
  assert_close(summary.centroid, 2.0)
  assert_true(summary.bandwidth > 0.0)
  assert_true(summary.entropy > 0.0)
  assert_close(summary.rolloff, 2.0)
}

///|
test "spectral slope distinguishes falling spectra" {
  assert_true(spectral_slope([4.0, 3.0, 2.0, 1.0]) < 0.0)
  assert_true(spectral_slope([1.0, 2.0, 3.0, 4.0]) > 0.0)
}
