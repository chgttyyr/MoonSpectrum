///|
fn main raise {
  let args = @env.args()
  match find_command(args) {
    Some(index) => run_command(args, index)
    None => print_help()
  }
}

///|
fn run_command(args : Array[String], index : Int) -> Unit raise {
  match args[index] {
    "demo" => run_demo()
    "fft" => run_fft(args, index)
    "analyze" => run_analyze(args, index)
    "window" => run_window(args, index)
    "convolve" => run_convolve(args, index)
    "stft" => run_stft(args, index)
    "psd" => run_psd(args, index)
    "resample" => run_resample(args, index)
    "biquad" => run_biquad(args, index)
    "stats" => run_stats(args, index)
    "correlate" => run_correlate(args, index)
    "welch" => run_welch(args, index)
    "peaks" => run_peaks(args, index)
    "help" | "--help" | "-h" => print_help()
    other => {
      println("unknown command: \{other}")
      print_help()
    }
  }
}

///|
fn print_help() -> Unit {
  println("MoonSpectrum scientific signal processing CLI")
  println("")
  println("Commands:")
  println("  demo")
  println("  fft <csv-file> --sample-rate <hz>")
  println("  analyze <csv-file> --sample-rate <hz>")
  println("  window <rectangular|hann|hamming|blackman> <length>")
  println("  convolve <csv-file> <kernel-csv-file>")
  println(
    "  stft <csv-file> --window-length <N> --hop-size <M> --window <kind>",
  )
  println("  psd <csv-file> --sample-rate <hz>")
  println("  resample <csv-file> --target-length <N>")
  println(
    "  biquad <csv-file> --type <lowpass|highpass|bandpass> --cutoff <hz> --sample-rate <hz>",
  )
  println("  stats <csv-file>")
  println("  correlate <csv-file> [other-csv-file] --max-lag <N>")
  println(
    "  welch <csv-file> --sample-rate <hz> --segment-length <N> --overlap <fraction>",
  )
  println("  peaks <csv-file> --threshold <value> --min-distance <N>")
}

///|
fn find_command(args : Array[String]) -> Int? {
  for i in 0..<args.length() {
    match args[i] {
      "demo"
      | "fft"
      | "analyze"
      | "window"
      | "convolve"
      | "stft"
      | "psd"
      | "resample"
      | "biquad"
      | "stats"
      | "correlate"
      | "welch"
      | "peaks"
      | "help"
      | "--help"
      | "-h" => break Some(i)
      _ => continue
    }
  } nobreak {
    None
  }
}

///|
fn run_demo() -> Unit raise {
  let signal = @ms.sine_wave(length=8, sample_rate=8.0, frequency=2.0)
  let spectrum = @ms.fft(@ms.real_signal(signal))
  let peak = @ms.dominant_peak(spectrum, 8.0)
  println(
    "{\"demo\":\"sine\",\"samples\":\{double_array_json(signal)},\"dominant_frequency\":\{peak.frequency},\"peak_bin\":\{peak.index}}",
  )
}

///|
fn run_fft(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="fft requires a csv file")
  }
  let sample_rate = flag_double(args, "--sample-rate", 1.0)
  let values = read_csv_column(args[index + 1])
  let spectrum = @ms.fft(@ms.real_signal(values))
  let magnitudes = @ms.magnitude_spectrum(spectrum)
  println(
    "{\"sample_rate\":\{sample_rate},\"magnitudes\":\{double_array_json(magnitudes)}}",
  )
}

///|
fn run_analyze(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="analyze requires a csv file")
  }
  let sample_rate = flag_double(args, "--sample-rate", 1.0)
  let values = read_csv_column(args[index + 1])
  let spectrum = @ms.fft(@ms.real_signal(values))
  let peak = @ms.dominant_peak(spectrum, sample_rate)
  println(
    "{\"samples\":\{values.length()},\"sample_rate\":\{sample_rate},\"dominant_bin\":\{peak.index},\"dominant_frequency\":\{peak.frequency},\"magnitude\":\{peak.magnitude}}",
  )
}

///|
fn run_window(args : Array[String], index : Int) -> Unit raise {
  guard index + 2 < args.length() else {
    raise @ms.InvalidArgument(message="window requires kind and length")
  }
  let kind = parse_window_kind(args[index + 1])
  let length = parse_double(args[index + 2].to_string_view()).to_int()
  let weights = @ms.window(kind, length)
  println(
    "{\"window\":\"\{args[index + 1]}\",\"weights\":\{double_array_json(weights)}}",
  )
}

///|
fn run_convolve(args : Array[String], index : Int) -> Unit raise {
  guard index + 2 < args.length() else {
    raise @ms.InvalidArgument(
      message="convolve requires signal and kernel csv files",
    )
  }
  let signal = read_csv_column(args[index + 1])
  let kernel = read_csv_column(args[index + 2])
  let out = @ms.convolve(signal, kernel)
  println("{\"result\":\{double_array_json(out)}}")
}

///|
fn flag_double(
  args : Array[String],
  flag : String,
  default : Double,
) -> Double raise {
  for i in 0..<args.length() {
    if args[i] == flag && i + 1 < args.length() {
      break parse_double(args[i + 1].to_string_view())
    }
  } nobreak {
    default
  }
}

///|
fn read_csv_column(path : String) -> Array[Double] raise {
  let text = @fs.read_file_to_string(path)
  let values : Array[Double] = []
  for raw_line in text.split("\n") {
    let line = raw_line.trim()
    if line != "" {
      let first = match line.split_once(",") {
        Some((head, _)) => head.trim()
        None => line
      }
      values.push(parse_double(first))
    }
  }
  values
}

///|
fn parse_window_kind(input : String) -> @ms.WindowKind raise @ms.SpectrumError {
  match input.to_lower() {
    "rectangular" | "rect" => Rectangular
    "hann" => Hann
    "hamming" => Hamming
    "blackman" => Blackman
    _ => raise InvalidArgument(message="unknown window kind")
  }
}

///|
fn double_array_json(values : ArrayView[Double]) -> String {
  "[\{values.map(item => item.to_string()).join(",")}]"
}

///|
fn parse_double(input : StringView) -> Double raise {
  @strconv.from_str(input)
}

///|
fn flag_int(args : Array[String], flag : String, default : Int) -> Int raise {
  for i in 0..<args.length() {
    if args[i] == flag && i + 1 < args.length() {
      break parse_double(args[i + 1].to_string_view()).to_int()
    }
  } nobreak {
    default
  }
}

///|
fn flag_string(args : Array[String], flag : String, default : String) -> String {
  for i in 0..<args.length() {
    if args[i] == flag && i + 1 < args.length() {
      break args[i + 1]
    }
  } nobreak {
    default
  }
}

///|
fn run_stft(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="stft requires a csv file")
  }
  let window_length = flag_int(args, "--window-length", 256)
  let hop_size = flag_int(args, "--hop-size", 128)
  let window_str = flag_string(args, "--window", "hann")
  let window_kind = parse_window_kind(window_str)
  let values = read_csv_column(args[index + 1])
  let res = @ms.stft(values, window_kind, window_length, hop_size)
  let mut frames_json = "["
  for i in 0..<res.length() {
    let magnitudes = @ms.magnitude_spectrum(res[i])
    frames_json = frames_json + double_array_json(magnitudes)
    if i + 1 < res.length() {
      frames_json = frames_json + ","
    }
  }
  frames_json = frames_json + "]"
  println("{\"frames\":\{frames_json}}")
}

///|
fn run_psd(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="psd requires a csv file")
  }
  let sample_rate = flag_double(args, "--sample-rate", 1.0)
  let values = read_csv_column(args[index + 1])
  let two_sided = @ms.periodogram(values, sample_rate, window_kind=Rectangular)
  let single = @ms.single_sided_psd(two_sided)
  println("{\"psd_single_sided\":\{double_array_json(single)}}")
}

///|
fn run_resample(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="resample requires a csv file")
  }
  let target_length = flag_int(args, "--target-length", 128)
  let values = read_csv_column(args[index + 1])
  let res_lin = @ms.resample_linear(values, target_length)
  println("{\"resampled_linear\":\{double_array_json(res_lin)}}")
}

///|
fn run_biquad(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="biquad requires a csv file")
  }
  let filter_type = flag_string(args, "--type", "lowpass")
  let cutoff = flag_double(args, "--cutoff", 100.0)
  let sample_rate = flag_double(args, "--sample-rate", 1000.0)
  let values = read_csv_column(args[index + 1])
  let lp = match filter_type {
    "lowpass" => @ms.Biquad::lowpass(cutoff, sample_rate)
    "highpass" => @ms.Biquad::highpass(cutoff, sample_rate)
    "bandpass" => @ms.Biquad::bandpass(cutoff, sample_rate)
    other => raise @ms.InvalidArgument(message="unknown biquad type: " + other)
  }
  let res = lp.filter(values)
  println("{\"filtered\":\{double_array_json(res)}}")
}

///|
fn run_stats(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="stats requires a csv file")
  }
  let values = read_csv_column(args[index + 1])
  let stats = @ms.signal_stats(values)
  println(
    "{\"count\":\{stats.count},\"mean\":\{stats.mean},\"variance\":\{stats.variance},\"stddev\":\{stats.stddev},\"rms\":\{stats.rms},\"minimum\":\{stats.minimum},\"maximum\":\{stats.maximum},\"peak_to_peak\":\{stats.peak_to_peak}}",
  )
}

///|
fn run_correlate(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="correlate requires a csv file")
  }
  let signal = read_csv_column(args[index + 1])
  let max_lag = flag_int(args, "--max-lag", signal.length() - 1)
  if index + 2 < args.length() && args[index + 2] != "--max-lag" {
    let other = read_csv_column(args[index + 2])
    let result = @ms.cross_correlation(signal, other, max_lag)
    println("{\"kind\":\"cross\",\"correlation\":\{double_array_json(result)}}")
  } else {
    let result = @ms.normalized_correlation(signal, max_lag)
    println(
      "{\"kind\":\"auto-normalized\",\"correlation\":\{double_array_json(result)}}",
    )
  }
}

///|
fn run_welch(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="welch requires a csv file")
  }
  let sample_rate = flag_double(args, "--sample-rate", 1.0)
  let segment_length = flag_int(args, "--segment-length", 256)
  let overlap = flag_double(args, "--overlap", 0.5)
  let window_kind = parse_window_kind(flag_string(args, "--window", "hann"))
  let values = read_csv_column(args[index + 1])
  let result = @ms.welch_psd(
    values,
    sample_rate~,
    segment_length~,
    overlap~,
    window_kind~,
  )
  println(
    "{\"frequencies\":\{double_array_json(result.frequencies)},\"psd\":\{double_array_json(result.psd)}}",
  )
}

///|
fn run_peaks(args : Array[String], index : Int) -> Unit raise {
  guard index + 1 < args.length() else {
    raise @ms.InvalidArgument(message="peaks requires a csv file")
  }
  let threshold = flag_double(args, "--threshold", 0.0)
  let min_distance = flag_int(args, "--min-distance", 1)
  let values = read_csv_column(args[index + 1])
  let peaks = @ms.find_peaks(values, threshold~, min_distance~)
  println("{\"peaks\":\{signal_peaks_json(peaks)}}")
}

///|
fn signal_peaks_json(peaks : ArrayView[@ms.SignalPeak]) -> String {
  let items = peaks.map(peak => {
    "{\"index\":\{peak.index},\"value\":\{peak.value}}"
  })
  "[" + items.join(",") + "]"
}
