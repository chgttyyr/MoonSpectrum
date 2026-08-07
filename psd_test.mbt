///|
test "psd basic" {
  let signal = sine_wave(length=16, sample_rate=8.0, frequency=2.0)
  let p = periodogram(signal, 8.0, window_kind=Rectangular)
  inspect(p.length(), content="16")
  // A unit sine aligned to bin 4 has |X[4]|^2 = 64. With the
  // rectangular-window normalization N * fs, the two-sided PSD is 0.5.
  assert_close(p[4], 0.5)
  assert_close(p[0], 0.0)

  let single = single_sided_psd(p)
  inspect(single.length(), content="9")
  // Bin 4 is not Nyquist for N=16, so the single-sided representation
  // doubles the positive-frequency energy.
  assert_close(single[4], 1.0)
}
