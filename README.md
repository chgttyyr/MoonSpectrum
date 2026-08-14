# MoonSpectrum

[![CI](https://github.com/chgttyyr/MoonSpectrum/actions/workflows/ci.yml/badge.svg)](https://github.com/chgttyyr/MoonSpectrum/actions/workflows/ci.yml)

MoonSpectrum 是一个面向 MoonBit 生态的科学信号处理基础库。它提供复数运算、DFT/FFT、频谱分析、窗函数、卷积、基础 FIR 滤波和命令行分析工具，目标是补齐 MoonBit 在传感器数据、实验数据、振动信号、周期信号和教学验证中的基础算法能力。

本项目不做音频播放、采集或设备后端，也不依赖 native FFI。当前版本已覆盖 STFT、periodogram/Welch PSD、IIR 滤波、重采样、跨通道相关分析和频谱特征；后续再扩展流式输入、时间戳管线和 WebAssembly 可视化。

## Why

MoonBit 已经有一些音频、图形、矩阵和工程工具包，但通用科学信号处理方向还缺少一个小而稳的基础库。MoonSpectrum 的定位是：

- 给 MoonBit 项目提供可复用的 FFT、频谱、窗函数、卷积和基础滤波能力。
- 给 OSC2026 评审提供可直接运行的测试、示例数据和 CLI。
- 给后续生态扩展留下清楚边界，而不是把音频引擎、数据框、可视化和控制系统混在一起。

## Installation

MoonSpectrum is a MoonBit module. The repository is the source distribution;
the published module metadata and dependency version are recorded in
`moon.mod`.

### From the repository

Install the current MoonBit toolchain from the official installer, then clone
the repository and refresh its pinned dependency:

```powershell
# Windows PowerShell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex

git clone https://github.com/chgttyyr/MoonSpectrum.git
cd MoonSpectrum
moon update
moon check --target all

# For Windows native validation, install MSYS2 UCRT64 GCC and add
# C:\\msys64\\ucrt64\\bin to PATH before running the all-backend commands.
```

```bash
# Linux or macOS
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
git clone https://github.com/chgttyyr/MoonSpectrum.git
cd MoonSpectrum
moon update
moon check --target all
```

The competition notice recommended MoonBit 0.10.3. The CLI package keeps the
backward-compatible `options("is-main": true)` declaration, so it works with
the committee toolchain and newer official releases. Because newer formatters
try to migrate that legacy declaration, CI uses `scripts/check_format.py`: it
runs the official formatter against every `.mbt` source and structurally
checks the intentional legacy package file. CI prints
`moon version --all` so the exact compiler is visible. If starting a new copy
instead of using the committed `moon.mod`, the equivalent dependency command is
`moon add moonbitlang/x@0.4.45`.

## Features

- `Complex` 复数类型：加减乘、缩放、幅值、近似比较。
- DFT / radix-2 FFT / inverse FFT。
- 幅度谱、功率谱、频率 bin、主频检测。
- STFT、periodogram PSD、单边 PSD、线性重采样。
- 信号生成：正弦波、方波、脉冲、线性 chirp、确定性白噪声。
- 窗函数：Rectangular、Hann、Hamming、Blackman。
- 卷积：线性卷积、循环卷积。
- 基础滤波：移动平均、FIR taps、IIR biquad 低通/高通/带通。
- CLI：`demo`、`fft`、`analyze`、`window`、`convolve`、`stft`、`psd`、`resample`、`biquad`、`stats`、`correlate`、`welch`、`peaks`。

## Quick Start

```powershell
moon test
moon run cmd/main -- demo
moon run cmd/main -- fft examples/sine.csv --sample-rate 8
moon run cmd/main -- analyze examples/sine.csv --sample-rate 8
moon run cmd/main -- window hann 4
moon run cmd/main -- convolve examples/sine.csv examples/kernel.csv
```

Typical output:

```json
{"samples":8,"sample_rate":8,"dominant_bin":2,"dominant_frequency":2,"magnitude":4}
```

## API Sketch

```mbt
test {
  let signal = sine_wave(length=8, sample_rate=8.0, frequency=2.0)
  let spectrum = fft(real_signal(signal))
  let peak = dominant_peak(spectrum, 8.0)
  inspect(peak.index, content="2")
}
```

The root package exports the public API. CLI code lives in `cmd/main` and uses the same library functions as users would.

## Project Layout

- `complex.mbt` - complex arithmetic and approximate comparisons.
- `fft.mbt` - DFT, FFT, inverse FFT, real signal conversion.
- `analysis.mbt` - spectra, frequency bins, peak detection.
- `signals.mbt` - test/demo signal generation.
- `windows.mbt` - window functions and window application.
- `convolution.mbt` - linear and circular convolution.
- `filters.mbt` - moving average, FIR filtering, low/high-pass taps.
- `stft.mbt`, `psd.mbt`, `resampling.mbt`, `iir_filters.mbt` - extended
  scientific signal-processing primitives.
- `cmd/main` - CLI entry point.
- `examples` - small CSV fixtures for smoke tests.
- `docs/fixtures.md` - fixture provenance, construction rules, and expected
  numeric invariants.
- `docs/competition` - OSC2026 proposal and acceptance material.

## Verification

```powershell
moon info
python scripts/check_format.py
moon check --target all --warn-list +73
moon build --target all
moon test --target all
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun
```

The extended analysis commands are also covered by deterministic smoke tests:

```powershell
moon run cmd/main -- stats examples/offset.csv
moon run cmd/main -- correlate examples/dual-tone.csv --max-lag 4
moon run cmd/main -- welch examples/sine.csv --sample-rate 8 --segment-length 8 --overlap 0.5 --window hann
moon run cmd/main -- peaks examples/dual-tone.csv --threshold 0.4 --min-distance 2
```

## Release Links

- GitHub: <https://github.com/chgttyyr/MoonSpectrum>
- GitLink: <https://gitlink.org.cn/chgttyyr/MoonSpectrum>
- Mooncakes: <https://mooncakes.io/docs/chgttyyr/MoonSpectrum>

MoonSpectrum is published as the Mooncakes module `chgttyyr/MoonSpectrum@0.2.2`.
The `moon.mod` file is the source of truth for the package metadata shown on
Mooncakes.

## Current Boundaries

- FFT currently requires power-of-two input length.
- CSV parser intentionally handles simple single-column numeric fixtures.
- Time zones, timestamps, streaming IO, and visualization are future work.
- No native FFI is used in v0.2.2.

## Roadmap

- Cross-channel correlation and streaming window processing.
- Robust CSV/JSON data ingestion and timestamp-aware analysis.
- Browser/WebAssembly demo for frequency-domain visualization.
- Additional statistical estimators and calibration helpers.

## License

Apache-2.0.
