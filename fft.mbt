///|
pub fn dft(signal : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise SpectrumError::EmptySignal
  }
  let out : Array[Complex] = []
  for k in 0..<n {
    let mut sum = Complex::zero()
    for t in 0..<n {
      let angle = -2.0 * @math.PI * Double::from_int(k * t) / Double::from_int(n)
      let w = complex(re=@math.cos(angle), im=@math.sin(angle))
      sum = sum.add(signal[t].mul(w))
    }
    out.push(sum)
  }
  out
}

///|
pub fn fft(signal : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  let n = signal.length()
  if n == 0 {
    raise SpectrumError::EmptySignal
  }
  if !is_power_of_two(n) {
    raise SpectrumError::NonPowerOfTwo(length=n)
  }
  fft_inner(signal)
}

///|
pub fn ifft(spectrum : ArrayView[Complex]) -> Array[Complex] raise SpectrumError {
  let n = spectrum.length()
  if n == 0 {
    raise SpectrumError::EmptySignal
  }
  let conjugated = spectrum.map(item => complex(re=item.re, im=-item.im))
  let transformed = fft(conjugated)
  transformed.map(item => complex(re=item.re / Double::from_int(n), im=-item.im / Double::from_int(n)))
}

///|
pub fn real_signal(values : ArrayView[Double]) -> Array[Complex] {
  values.map(v => complex(re=v, im=0.0))
}

///|
fn is_power_of_two(n : Int) -> Bool {
  if n <= 0 {
    false
  } else {
    for value = n; value > 1; {
      if value % 2 != 0 {
        break false
      } else {
        continue value / 2
      }
    } nobreak {
      true
    }
  }
}

///|
fn fft_inner(signal : ArrayView[Complex]) -> Array[Complex] {
  let n = signal.length()
  if n == 1 {
    [signal[0]]
  } else {
    let even : Array[Complex] = []
    let odd : Array[Complex] = []
    for i in 0..<n {
      if i % 2 == 0 {
        even.push(signal[i])
      } else {
        odd.push(signal[i])
      }
    }
    let even_fft = fft_inner(even)
    let odd_fft = fft_inner(odd)
    let out = Array::make(n, Complex::zero())
    for k in 0..<(n / 2) {
      let angle = -2.0 * @math.PI * Double::from_int(k) / Double::from_int(n)
      let twiddle = complex(re=@math.cos(angle), im=@math.sin(angle))
      let term = twiddle.mul(odd_fft[k])
      out[k] = even_fft[k].add(term)
      out[k + n / 2] = even_fft[k].sub(term)
    }
    out
  }
}
