///|
test "triangle and sawtooth generators are deterministic" {
  debug_inspect(
    triangle_wave(length=4, sample_rate=4.0, frequency=1.0),
    content="[0, 1, 0, -1]",
  )
  debug_inspect(
    sawtooth_wave(length=4, sample_rate=4.0, frequency=1.0),
    content="[-1, -0.5, 0, 0.5]",
  )
}

///|
test "generator amplitudes and arguments are checked" {
  let pulse = pulse_train(length=8, period=2, amplitude=2.0)
  debug_inspect(pulse, content="[2, 0, 2, 0, 2, 0, 2, 0]")
  try triangle_wave(length=0, sample_rate=4.0, frequency=1.0) catch {
    EmptySignal => inspect("empty", content="empty")
    _ => fail("unexpected error")
  } noraise {
    _ => fail("expected invalid length")
  }
}
