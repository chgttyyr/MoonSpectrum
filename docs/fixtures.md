# Fixture provenance and numeric invariants

The files under `examples/` are small, deterministic, hand-authored fixtures
for documentation and CLI smoke tests. They are not copied from a third-party
dataset and contain no personal or licensed user data.

| Fixture | Construction | Purpose | Expected invariant |
| --- | --- | --- | --- |
| `sine.csv` | 8 samples of a unit sine wave at 2 Hz sampled at 8 Hz | FFT, peak detection, PSD, STFT | The dominant positive-frequency bin is 2; the single-sided PSD peak is 0.5 for this 8-sample frame. |
| `pulse.csv` | One unit impulse at index 3 in an 8-sample frame | Impulse/FFT smoke tests | The input has exactly one non-zero sample. |
| `vibration.csv` | 16 manually chosen bounded samples with a smooth oscillatory shape | CLI analysis demonstration | Values are finite and remain in the documented `[-1, 1]` range. |
| `kernel.csv` | Symmetric moving-average kernel `[0.25, 0.5, 0.25]` | Linear convolution CLI example | Coefficients sum to 1 and preserve DC in the interior. |

The executable commands read one numeric value per line. This intentionally
small format keeps the examples reproducible across MoonBit backends and
makes the CLI parser boundary explicit; it is not intended to replace a full
CSV/data-cleaning pipeline.

The algorithm tests use independently checkable numerical properties rather
than only checking array lengths:

- rectangular-window PSD of the aligned unit sine has a known bin energy;
- STFT frame count follows `1 + floor((N - window_length) / hop_size)`;
- linear interpolation preserves endpoints and midpoint values;
- sinc interpolation preserves exact integer sample locations;
- biquad responses and FIR band-pass/band-stop tap sums are checked with
  tolerance-based assertions.

These fixtures and invariants are version-controlled so reviewers can rerun
the same commands without downloading an external dataset.
