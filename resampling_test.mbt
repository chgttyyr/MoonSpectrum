///|
test "resampling basic" {
  let signal = [1.0, 2.0, 3.0, 4.0]
  let res_lin = resample_linear(signal, 7)
  assert_close(res_lin[0], 1.0)
  inspect(res_lin[1], content="1.5")
  assert_close(res_lin[3], 2.5)
  inspect(res_lin[5], content="3.5")
  assert_close(res_lin[6], 4.0)

  let res_sinc = resample_sinc(signal, 7)
  // Cardinal sinc interpolation reproduces the original samples at
  // integer locations, while its half-sample values are intentionally not
  // the same as linear interpolation.
  assert_close(res_sinc[0], 1.0)
  assert_close(res_sinc[2], 2.0)
  assert_close(res_sinc[3], 2.1220659079, eps=0.000001)
  assert_close(res_sinc[4], 3.0)
  assert_close(res_sinc[6], 4.0)
}
