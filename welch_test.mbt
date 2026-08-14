///|
test "welch psd preserves dominant frequency and dimensions" {
  let signal = sine_wave(length=32, sample_rate=8.0, frequency=2.0)
  let result = welch_psd(
    signal,
    sample_rate=8.0,
    segment_length=8,
    overlap=0.5,
    window_kind=Hann,
  )
  inspect(result.frequencies.length(), content="5")
  inspect(result.psd.length(), content="5")
  let mut best = 0
  for i in 1..<result.psd.length() {
    if result.psd[i] > result.psd[best] {
      best = i
    }
  }
  inspect(best, content="2")
  assert_close(result.frequencies[best], 2.0)
}

///|
test "welch psd rejects invalid segmentation" {
  try
    welch_psd(
      [1.0, 2.0, 3.0, 4.0],
      sample_rate=8.0,
      segment_length=3,
      overlap=0.5,
    )
  catch {
    NonPowerOfTwo(length=3) => inspect("power", content="power")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected non-power-of-two error")
  }
  try
    welch_psd(
      [1.0, 2.0, 3.0, 4.0],
      sample_rate=8.0,
      segment_length=8,
      overlap=0.5,
    )
  catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected short signal error")
  }
  try
    welch_psd(
      [1.0, 2.0, 3.0, 4.0],
      sample_rate=8.0,
      segment_length=4,
      overlap=1.0,
    )
  catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid overlap error")
  }
}
