///|
test "signal quality reports robust spread measures" {
  assert_close(covariance([1.0, 2.0, 3.0], [2.0, 4.0, 8.0]), 2.0)
  assert_close(autocovariance([1.0, 2.0, 3.0], 0), 2.0 / 3.0)
  assert_close(mean_absolute_deviation([1.0, 2.0, 4.0, 5.0]), 1.5)
  assert_close(interquartile_range([1.0, 2.0, 3.0, 4.0]), 1.5)
}

///|
test "signal quality clips and detects events deterministically" {
  debug_inspect(
    clip_signal([-2.0, -0.5, 0.5, 2.0], -1.0, 1.0),
    content="[-1, -0.5, 0.5, 1]",
  )
  debug_inspect(
    threshold_crossings([-1.0, 0.5, 2.0, 0.0, -2.0], 1.0),
    content="[2, 3]",
  )
  debug_inspect(
    zero_crossing_indices([1.0, -1.0, 2.0, -2.0]),
    content="[1, 2, 3]",
  )
}

///|
test "signal quality rejects invalid input" {
  try covariance([], []) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected empty error")
  }
  try threshold_crossings([1.0], 0.0) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected invalid error")
  }
}
