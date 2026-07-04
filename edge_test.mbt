///|
fn assert_close_edge(actual : Double, expected : Double, eps? : Double = 0.000001) -> Unit raise {
  if !approx_equal(actual, expected, eps~) {
    fail("expected \{expected}, got \{actual}")
  }
}

///|
test "fft rejects non power of two lengths" {
  try fft(real_signal([1.0, 2.0, 3.0])) catch {
    SpectrumError::NonPowerOfTwo(length=3) => inspect("non-power-of-two", content="non-power-of-two")
    err => fail("unexpected error: \{to_repr(err)}")
  } noraise {
    _ => fail("expected non power of two error")
  }
}

///|
test "circular convolution wraps energy into the output length" {
  let out = circular_convolve([1.0, 2.0, 3.0], [1.0, 1.0, 1.0])
  debug_inspect(out, content="[6, 6, 6]")
}

///|
test "white noise is deterministic for the same seed" {
  let a = white_noise(length=4, seed=7)
  let b = white_noise(length=4, seed=7)
  for i in 0..<a.length() {
    assert_close_edge(a[i], b[i])
  }
}

///|
test "highpass taps reject DC by summing near zero" {
  let taps = highpass_taps(length=5, cutoff_hz=1.0, sample_rate=8.0)
  let sum = taps.fold(init=0.0, (acc, item) => acc + item)
  assert_close_edge(sum, 0.0)
}
