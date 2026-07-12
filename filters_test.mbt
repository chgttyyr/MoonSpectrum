test "iir filters basic" {
  let lp = Biquad::lowpass(100.0, 1000.0)
  let sig = [1.0, 1.0, 1.0, 1.0, 1.0]
  let res = lp.filter(sig)
  inspect(res.length(), content="5")

  let hp = Biquad::highpass(100.0, 1000.0)
  let res_hp = hp.filter(sig)
  inspect(res_hp.length(), content="5")
}

test "bandpass fir taps basic" {
  let taps = bandpass_fir_taps(length=15, low_cutoff_hz=100.0, high_cutoff_hz=200.0, sample_rate=1000.0)
  inspect(taps.length(), content="15")

  let taps_stop = bandstop_fir_taps(length=15, low_cutoff_hz=100.0, high_cutoff_hz=200.0, sample_rate=1000.0)
  inspect(taps_stop.length(), content="15")
}
