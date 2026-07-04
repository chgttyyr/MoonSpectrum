///|
pub(all) struct Complex {
  re : Double
  im : Double
} derive(Debug, Eq, ToJson)

///|
pub(all) enum WindowKind {
  Rectangular
  Hann
  Hamming
  Blackman
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Peak {
  index : Int
  frequency : Double
  magnitude : Double
} derive(Debug, Eq, ToJson)

///|
pub(all) suberror SpectrumError {
  EmptySignal
  LengthMismatch
  NonPowerOfTwo(length~ : Int)
  InvalidArgument(message~ : String)
} derive(Debug, Eq, ToJson)
