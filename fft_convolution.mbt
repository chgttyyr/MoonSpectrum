///|
pub fn fft_convolve(
  signal : ArrayView[Double],
  kernel : ArrayView[Double],
) -> Array[Double] raise SpectrumError {
  if signal.length() == 0 || kernel.length() == 0 {
    raise EmptySignal
  }
  let output_length = signal.length() + kernel.length() - 1
  let fft_length = next_power_of_two(output_length)
  let left = Array::make(fft_length, Complex::zero())
  let right = Array::make(fft_length, Complex::zero())
  for i in 0..<signal.length() {
    left[i] = complex(re=signal[i], im=0.0)
  }
  for i in 0..<kernel.length() {
    right[i] = complex(re=kernel[i], im=0.0)
  }
  let left_spectrum = fft(left)
  let right_spectrum = fft(right)
  let product = Array::make(fft_length, Complex::zero())
  for i in 0..<fft_length {
    product[i] = left_spectrum[i].mul(right_spectrum[i])
  }
  let time_domain = ifft(product)
  let output = Array::make(output_length, 0.0)
  for i in 0..<output_length {
    output[i] = time_domain[i].re
  }
  output
}
