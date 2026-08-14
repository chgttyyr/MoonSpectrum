///|
test "notch and allpass biquads are usable" {
  let notch = Biquad::notch(100.0, 1000.0)
  let allpass = Biquad::allpass(100.0, 1000.0)
  let input = [1.0, 0.0, 0.0, 0.0]
  inspect(notch.filter(input).length(), content="4")
  inspect(allpass.filter(input).length(), content="4")
  assert_true(notch.b0 > 0.0)
  assert_true(allpass.b0 > 0.0)
}
