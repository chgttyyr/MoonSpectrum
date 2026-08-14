///|
test "window metrics quantify coherent and noise gain" {
  assert_close(window_coherent_gain(Hann, 4), 0.375)
  assert_close(window_noise_bandwidth(Hann, 4), 2.0)
  assert_true(
    window_coherent_gain(Blackman, 8) < window_coherent_gain(Rectangular, 8),
  )
}

///|
test "window metrics reject invalid lengths" {
  try window_coherent_gain(Hann, 0) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid window length")
  }
}
