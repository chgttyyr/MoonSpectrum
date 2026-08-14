///|
test "autocorrelation returns non-negative lags" {
  let result = autocorrelation([1.0, 2.0, 3.0], 2)
  debug_inspect(result, content="[14, 8, 3]")
  let normalized = normalized_correlation([1.0, 2.0, 3.0], 2)
  assert_close(normalized[0], 1.0)
  assert_close(normalized[1], 8.0 / 14.0)
}

///|
test "cross correlation uses positive lag consistently" {
  let result = cross_correlation([1.0, 2.0, 3.0], [3.0, 2.0, 1.0], 2)
  debug_inspect(result, content="[10, 4, 1]")
}

///|
test "correlation rejects invalid ranges and empty inputs" {
  try autocorrelation([], 0) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected empty signal error")
  }
  try autocorrelation([1.0, 2.0], 2) catch {
    InvalidArgument(message=_) => inspect("invalid", content="invalid")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid lag error")
  }
}
