///|
test "iir filters basic" {
  let lp = Biquad::lowpass(100.0, 1000.0)
  let sig = [1.0, 1.0, 1.0, 1.0, 1.0]
  let res = lp.filter(sig)
  inspect(res.length(), content="5")
  assert_close(res[0], 0.0674522828, eps=0.000001)
  assert_close(res[4], 0.9479602914, eps=0.000001)

  let hp = Biquad::highpass(100.0, 1000.0)
  let res_hp = hp.filter(sig)
  inspect(res_hp.length(), content="5")
  assert_close(res_hp[0], 0.6389171933, eps=0.000001)
  assert_true(res_hp[1] < res_hp[0])
}

///|
test "bandpass fir taps basic" {
  let taps = bandpass_fir_taps(
    length=15,
    low_cutoff_hz=100.0,
    high_cutoff_hz=200.0,
    sample_rate=1000.0,
  )
  inspect(taps.length(), content="15")
  let bandpass_sum = taps.fold(init=0.0, (acc, item) => acc + item)
  assert_close(bandpass_sum, 0.0)

  let taps_stop = bandstop_fir_taps(
    length=15,
    low_cutoff_hz=100.0,
    high_cutoff_hz=200.0,
    sample_rate=1000.0,
  )
  inspect(taps_stop.length(), content="15")
  let bandstop_sum = taps_stop.fold(init=0.0, (acc, item) => acc + item)
  assert_close(bandstop_sum, 1.0)
}
