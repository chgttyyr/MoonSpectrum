///|
test "find peaks filters threshold and orders by magnitude" {
  let peaks = find_peaks([0.0, 1.0, 0.0, 0.0, 2.0, 1.0, 0.0], threshold=0.5)
  inspect(peaks.length(), content="2")
  inspect(peaks[0].index, content="4")
  assert_close(peaks[0].value, 2.0)
  inspect(peaks[1].index, content="1")
}

///|
test "find peaks enforces minimum distance" {
  let peaks = find_peaks(
    [0.0, 1.0, 0.0, 0.0, 2.0, 1.0, 0.0],
    threshold=0.5,
    min_distance=4,
  )
  inspect(peaks.length(), content="1")
  inspect(peaks[0].index, content="4")
}

///|
test "find peaks returns empty for empty input" {
  try find_peaks([]) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected empty signal error")
  }
}
