///|
test "stft basic" {
  let signal = sine_wave(length=32, sample_rate=8.0, frequency=2.0)
  let res = stft(signal, Hann, 8, 4)
  inspect(res.length(), content="7")
  let first_peak = dominant_peak(res[0], 8.0)
  inspect(first_peak.index, content="2")
  assert_close(first_peak.frequency, 2.0)
  assert_close(first_peak.magnitude, 1.75)
}
