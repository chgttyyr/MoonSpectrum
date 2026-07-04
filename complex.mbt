///|
pub fn complex(re~ : Double, im~ : Double) -> Complex {
  { re, im }
}

///|
pub fn Complex::zero() -> Complex {
  { re: 0.0, im: 0.0 }
}

///|
pub fn Complex::add(self : Complex, other : Complex) -> Complex {
  { re: self.re + other.re, im: self.im + other.im }
}

///|
pub fn Complex::sub(self : Complex, other : Complex) -> Complex {
  { re: self.re - other.re, im: self.im - other.im }
}

///|
pub fn Complex::mul(self : Complex, other : Complex) -> Complex {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
pub fn Complex::scale(self : Complex, factor : Double) -> Complex {
  { re: self.re * factor, im: self.im * factor }
}

///|
pub fn Complex::magnitude(self : Complex) -> Double {
  (self.re * self.re + self.im * self.im).sqrt()
}

///|
pub fn approx_equal(a : Double, b : Double, eps? : Double = 0.000001) -> Bool {
  (a - b).abs() <= eps
}

///|
pub fn Complex::approx_equal(
  self : Complex,
  other : Complex,
  eps? : Double = 0.000001,
) -> Bool {
  approx_equal(self.re, other.re, eps~) && approx_equal(self.im, other.im, eps~)
}
