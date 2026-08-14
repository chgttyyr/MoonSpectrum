///|
test "signal stats reports descriptive moments" {
  let stats = signal_stats([1.0, 2.0, 3.0, 4.0])
  inspect(stats.count, content="4")
  assert_close(stats.mean, 2.5)
  assert_close(stats.variance, 1.25)
  assert_close(stats.stddev, 1.1180339887)
  assert_close(stats.rms, 2.7386127875)
  assert_close(stats.minimum, 1.0)
  assert_close(stats.maximum, 4.0)
  assert_close(stats.peak_to_peak, 3.0)
}

///|
test "constant signal has zero spread" {
  let stats = signal_stats([3.0, 3.0, 3.0])
  assert_close(stats.mean, 3.0)
  assert_close(stats.variance, 0.0)
  assert_close(stats.stddev, 0.0)
  assert_close(stats.rms, 3.0)
}

///|
test "preprocessing centers detrends and normalizes without mutation" {
  let input = [1.0, 3.0, 5.0, 7.0]
  let centered = center(input)
  let detrended = detrend_linear(input)
  let normalized = normalize_peak([-2.0, 0.0, 1.0])
  assert_close(centered[0], -3.0)
  assert_close(centered[3], 3.0)
  for value in detrended {
    assert_close(value, 0.0)
  }
  debug_inspect(normalized, content="[-1, 0, 0.5]")
  debug_inspect(input, content="[1, 3, 5, 7]")
}

///|
test "preprocessing rejects empty signals" {
  try center([]) catch {
    EmptySignal => inspect("empty", content="empty")
    err => fail("unexpected error: \{to_repr(err)}")
  } noraise {
    _ => fail("expected empty signal error")
  }
  try normalize_peak([]) catch {
    EmptySignal => inspect("empty", content="empty")
    err => fail("unexpected error: \{to_repr(err)}")
  } noraise {
    _ => fail("expected empty signal error")
  }
}
