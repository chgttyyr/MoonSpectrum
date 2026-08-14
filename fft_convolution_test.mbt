///|
test "fft convolution matches linear convolution" {
  let expected = convolve([1.0, 2.0], [1.0, 1.0, 1.0])
  let actual = fft_convolve([1.0, 2.0], [1.0, 1.0, 1.0])
  debug_inspect(actual, content="[1, 3, 3, 2]")
  for i in 0..<expected.length() {
    assert_close(actual[i], expected[i])
  }
}

///|
test "fft convolution rejects empty inputs" {
  try fft_convolve([], [1.0]) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected empty signal error")
  }
}
