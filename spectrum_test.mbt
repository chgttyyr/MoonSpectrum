///|
fn assert_close(
  actual : Double,
  expected : Double,
  eps? : Double = 0.000001,
) -> Unit raise {
  if !approx_equal(actual, expected, eps~) {
    fail("expected \{expected}, got \{actual}")
  }
}

///|
fn assert_complex_close(actual : Complex, expected : Complex) -> Unit raise {
  if !actual.approx_equal(expected) {
    fail("expected \{to_repr(expected)}, got \{to_repr(actual)}")
  }
}

///|
test "complex arithmetic supports scientific calculations" {
  let a = complex(re=1.0, im=2.0)
  let b = complex(re=3.0, im=-4.0)
  assert_complex_close(a.add(b), complex(re=4.0, im=-2.0))
  assert_complex_close(a.mul(b), complex(re=11.0, im=2.0))
  assert_close(a.magnitude(), 5.0.sqrt())
}

///|
test "dft returns hand checked bins for impulse and constant signals" {
  let impulse_bins = dft(real_signal([1.0, 0.0, 0.0, 0.0]))
  for item in impulse_bins {
    assert_complex_close(item, complex(re=1.0, im=0.0))
  }
  let constant_bins = dft(real_signal([1.0, 1.0, 1.0, 1.0]))
  assert_complex_close(constant_bins[0], complex(re=4.0, im=0.0))
  assert_complex_close(constant_bins[1], complex(re=0.0, im=0.0))
  assert_complex_close(constant_bins[2], complex(re=0.0, im=0.0))
  assert_complex_close(constant_bins[3], complex(re=0.0, im=0.0))
}

///|
test "fft agrees with dft and ifft reconstructs the original signal" {
  let signal = real_signal([0.0, 1.0, 0.0, -1.0])
  let slow = dft(signal)
  let fast = fft(signal)
  for i in 0..<slow.length() {
    assert_complex_close(fast[i], slow[i])
  }
  let reconstructed = ifft(fast)
  for i in 0..<signal.length() {
    assert_complex_close(reconstructed[i], signal[i])
  }
}

///|
test "frequency bins and dominant peak report the expected sine frequency" {
  let values = sine_wave(length=8, sample_rate=8.0, frequency=2.0)
  let bins = frequency_bins(8, 8.0)
  assert_close(bins[0], 0.0)
  assert_close(bins[2], 2.0)
  let peak = dominant_peak(fft(real_signal(values)), 8.0)
  inspect(peak.index, content="2")
  assert_close(peak.frequency, 2.0)
}

///|
test "windows and convolution expose deterministic signal primitives" {
  let hann = window(Hann, 4)
  assert_close(hann[0], 0.0)
  assert_close(hann[1], 0.75)
  assert_close(hann[2], 0.75)
  assert_close(hann[3], 0.0)
  let weighted = apply_window([1.0, 2.0, 3.0, 4.0], hann)
  assert_close(weighted[1], 1.5)
  assert_close(weighted[2], 2.25)
  let conv = convolve([1.0, 2.0, 3.0], [1.0, 1.0])
  debug_inspect(conv, content="[1, 3, 5, 3]")
}

///|
test "filters provide moving averages and windowed-sinc taps" {
  let avg = moving_average([1.0, 2.0, 3.0, 4.0], 2)
  debug_inspect(avg, content="[1, 1.5, 2.5, 3.5]")
  let taps = lowpass_taps(length=5, cutoff_hz=1.0, sample_rate=8.0)
  inspect(taps.length(), content="5")
  let sum = taps.fold(init=0.0, (acc, item) => acc + item)
  assert_close(sum, 1.0)
}
