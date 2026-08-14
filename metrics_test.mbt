///|
test "signal metrics quantify reconstruction quality" {
  let reference = [1.0, 1.0, 1.0]
  let estimate = [1.0, 1.1, 0.9]
  assert_close(mean_absolute_error(reference, estimate), 0.0666666667)
  assert_close(root_mean_square_error(reference, estimate), 0.0816496581)
  assert_close(signal_to_noise_db(reference, estimate), 21.7609126)
  assert_close(correlation_coefficient([1.0, 2.0, 3.0], [1.0, 2.0, 3.0]), 1.0)
  assert_close(correlation_coefficient([1.0, 2.0, 3.0], [3.0, 2.0, 1.0]), -1.0)
}

///|
test "range normalization maps endpoints" {
  debug_inspect(
    normalize_range([2.0, 4.0, 6.0], -1.0, 1.0),
    content="[-1, 0, 1]",
  )
}

///|
test "metrics reject mismatched and degenerate inputs" {
  try mean_absolute_error([1.0], [1.0, 2.0]) catch {
    LengthMismatch => inspect("length", content="length")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected length mismatch")
  }
  try correlation_coefficient([1.0, 1.0], [2.0, 2.0]) catch {
    InvalidArgument(message=_) => inspect("constant", content="constant")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected constant signal error")
  }
}
