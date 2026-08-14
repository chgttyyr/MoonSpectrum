///|
test "calibration maps sensor values into engineering units" {
  debug_inspect(
    scale_signal(
      [0.0, 0.5, 1.0],
      input_min=0.0,
      input_max=1.0,
      output_min=-10.0,
      output_max=10.0,
    ),
    content="[-10, 0, 10]",
  )
  debug_inspect(remove_baseline([3.0, 4.0, 5.0], 4.0), content="[-1, 0, 1]")
  let z = robust_z_scores([1.0, 2.0, 3.0, 4.0, 100.0])
  assert_true(z[4] > 10.0)
}

///|
test "calibration detects bounded outliers" {
  debug_inspect(
    detect_outliers([1.0, 2.0, 3.0, 4.0, 100.0], z_threshold=3.0),
    content="[4]",
  )
}

///|
test "calibration rejects invalid ranges" {
  try
    scale_signal(
      [1.0],
      input_min=1.0,
      input_max=1.0,
      output_min=0.0,
      output_max=1.0,
    )
  catch {
    InvalidArgument(message=_) => inspect("range", content="range")
    _ => fail("wrong error")
  } noraise {
    _ => fail("expected range error")
  }
}
