///|
test "time-domain features calculate energy crossings and calculus" {
  assert_close(signal_energy([1.0, -2.0, 3.0]), 14.0)
  assert_close(zero_crossing_rate([1.0, -1.0, 1.0, -1.0]), 1.0)
  debug_inspect(
    differentiate([0.0, 1.0, 3.0, 6.0], 1.0),
    content="[1, 2, 3, 3]",
  )
  assert_close(integrate_trapezoid([0.0, 1.0, 2.0], 1.0), 2.0)
}

///|
test "quantile median and moving rms are deterministic" {
  assert_close(quantile([4.0, 1.0, 3.0, 2.0], 0.5), 2.5)
  assert_close(median([4.0, 1.0, 3.0, 2.0]), 2.5)
  let rms = moving_rms([3.0, 4.0, 0.0], 2)
  assert_close(rms[0], 3.0)
  assert_close(rms[1], 3.5355339059)
  assert_close(rms[2], 2.8284271247)
}

///|
test "time-domain helpers reject invalid arguments" {
  try differentiate([1.0], 0.0) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid interval")
  }
  try quantile([1.0, 2.0], 1.5) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid probability")
  }
}
