test "benchmark dsp functions" {
  // 1. FFT benchmark
  let signal = sine_wave(length=1024, sample_rate=1000.0, frequency=50.0)
  let complex_sig = real_signal(signal)
  for _ in 0..<100 {
    let _ = fft(complex_sig)
  }

  // 2. STFT benchmark
  for _ in 0..<50 {
    let _ = stft(signal, Hann, 256, 128)
  }

  // 3. Resampling benchmark
  for _ in 0..<100 {
    let _ = resample_linear(signal, 2048)
  }

  // 4. IIR Filter benchmark
  let lp = Biquad::lowpass(100.0, 1000.0)
  for _ in 0..<100 {
    let _ = lp.filter(signal)
  }
}
