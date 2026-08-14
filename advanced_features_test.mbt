///|
test "advanced signal features expose energy and dynamics" {
  assert_close(signal_rms([3.0, 4.0]), 3.5355339059)
  assert_close(crest_factor([0.0, 3.0, 4.0]), 1.3856406461)
  assert_close(dynamic_range_db([1.0, 10.0]), 20.0)
  assert_close(spectral_flux([0.0, 1.0, 0.0], [0.0, 2.0, 0.0]), 1.0)
  assert_true(spectral_band_energy([0.0, 1.0, 2.0, 0.0], 8.0, 1.0, 4.0) > 0.0)
}

///|
test "advanced signal features pad and smooth deterministically" {
  debug_inspect(pad_to_power_of_two([1.0, 2.0, 3.0]), content="[1, 2, 3, 0]")
  inspect(next_power_of_two(9), content="16")
  let envelope = envelope_follow([0.0, 1.0, 1.0, 0.0], attack=0.5, release=0.5)
  assert_close(envelope[0], 0.0)
  assert_close(envelope[1], 0.5)
  assert_close(envelope[2], 0.75)
  assert_close(envelope[3], 0.375)
}

///|
test "advanced signal features reject invalid values" {
  try next_power_of_two(0) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid length")
  }
  try dynamic_range_db([0.0, 0.0]) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected zero dynamic range error")
  }
}
