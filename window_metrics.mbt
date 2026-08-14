///|
pub fn window_coherent_gain(
  kind : WindowKind,
  length : Int,
) -> Double raise SpectrumError {
  let weights = window(kind, length)
  let mut total = 0.0
  for value in weights {
    total = total + value
  }
  total / Double::from_int(length)
}

///|
pub fn window_noise_bandwidth(
  kind : WindowKind,
  length : Int,
) -> Double raise SpectrumError {
  let weights = window(kind, length)
  let mut sum = 0.0
  let mut squares = 0.0
  for value in weights {
    sum = sum + value
    squares = squares + value * value
  }
  if sum == 0.0 {
    raise InvalidArgument(message="window has zero coherent gain")
  }
  Double::from_int(length) * squares / (sum * sum)
}
