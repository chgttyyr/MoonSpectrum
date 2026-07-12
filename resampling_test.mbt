test "resampling basic" {
  let signal = [1.0, 2.0, 3.0, 4.0]
  let res_lin = resample_linear(signal, 7)
  inspect(res_lin[1], content="1.5")
  inspect(res_lin[5], content="3.5")

  let res_sinc = resample_sinc(signal, 7)
  inspect(approx_equal(res_sinc[0], 1.0), content="true")
  inspect(approx_equal(res_sinc[6], 4.0), content="true")
}
