///|
test "full cross correlation reports negative through positive lags" {
  let result = full_cross_correlation([1.0, 2.0], [3.0, 4.0])
  debug_inspect(result, content="[6, 11, 4]")
}

///|
test "full cross correlation rejects mismatched inputs" {
  try full_cross_correlation([1.0], [1.0, 2.0]) catch {
    LengthMismatch => inspect("length", content="length")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected length mismatch")
  }
}
