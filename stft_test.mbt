test "stft basic" {
  let signal = sine_wave(length=32, sample_rate=8.0, frequency=2.0)
  let res = stft(signal, Hann, 8, 4)
  inspect(res.length(), content="7")
}
