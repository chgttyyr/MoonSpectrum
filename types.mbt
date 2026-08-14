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
pub(all) struct SignalStats {
  count : Int
  mean : Double
  variance : Double
  stddev : Double
  rms : Double
  minimum : Double
  maximum : Double
  peak_to_peak : Double
} derive(Debug, Eq, ToJson)

///|
pub(all) struct SignalPeak {
  index : Int
  value : Double
} derive(Debug, Eq, ToJson)

///|
pub(all) struct WelchResult {
  frequencies : Array[Double]
  psd : Array[Double]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct SpectralSummary {
  centroid : Double
  bandwidth : Double
  flatness : Double
  entropy : Double
  rolloff : Double
} derive(Debug, Eq, ToJson)

///|
pub(all) struct FrequencyResponse {
  frequencies : Array[Double]
  magnitude : Array[Double]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct SpectrogramResult {
  frequencies : Array[Double]
  frame_times : Array[Double]
  magnitudes : Array[Array[Double]]
} derive(Debug, Eq, ToJson)

///|
pub(all) suberror SpectrumError {
  EmptySignal
  LengthMismatch
  NonPowerOfTwo(length~ : Int)
  InvalidArgument(message~ : String)
} derive(Debug, Eq, ToJson)
