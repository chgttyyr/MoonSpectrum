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
