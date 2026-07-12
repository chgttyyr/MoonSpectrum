test "psd basic" {
  let signal = sine_wave(length=16, sample_rate=8.0, frequency=2.0)
  let p = periodogram(signal, 8.0, window_kind=Rectangular)
  inspect(p.length(), content="16")

  let single = single_sided_psd(p)
  inspect(single.length(), content="9")
}
