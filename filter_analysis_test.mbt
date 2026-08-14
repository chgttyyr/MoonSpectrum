///|
test "filter analysis reports impulse and frequency response" {
  let impulse = fir_impulse_response([0.5, 0.5], 4)
  debug_inspect(impulse, content="[0.5, 0.5, 0, 0]")
  let response = fir_frequency_response(
    [0.5, 0.5],
    sample_rate=8.0,
    fft_length=8,
  )
  inspect(response.frequencies.length(), content="5")
  assert_close(response.magnitude[0], 1.0)
  assert_close(response.magnitude[4], 0.0)
}

///|
test "filter analysis handles biquad response" {
  let lowpass = Biquad::lowpass(1.0, 8.0)
  let response = biquad_frequency_response(
    lowpass,
    sample_rate=8.0,
    fft_length=8,
  )
  assert_close(response.magnitude[0], 1.0, eps=0.00001)
  assert_true(response.magnitude[4] < response.magnitude[0])
}

///|
test "filter analysis rejects invalid response geometry" {
  try fir_impulse_response([], 4) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected empty error")
  }
  try fir_frequency_response([1.0], sample_rate=8.0, fft_length=6) catch {
    NonPowerOfTwo(length=6) => inspect("power", content="power")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected power error")
  }
}
