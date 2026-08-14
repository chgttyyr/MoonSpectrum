# MoonSpectrum 结项报告

## 项目与仓库

- 项目名称：MoonSpectrum
- Mooncakes 包名：`chgttyyr/MoonSpectrum`
- GitHub 仓库：<https://github.com/chgttyyr/MoonSpectrum>
- GitLink 仓库：<https://gitlink.org.cn/chgttyyr/MoonSpectrum>
- Mooncakes 链接：<https://mooncakes.io/docs/chgttyyr/MoonSpectrum>
- Mooncakes 版本：`chgttyyr/MoonSpectrum@0.2.0`
- 许可证：Apache-2.0
- 主要语言：MoonBit

## 完成内容

MoonSpectrum 已完成科学信号处理基础库的首个可发布版本，包含：

- `Complex` 复数类型和近似比较。
- DFT、radix-2 FFT、inverse FFT。
- 幅度谱、功率谱、频率 bin 和主频检测。
- STFT、periodogram PSD、单边 PSD 和线性/sinc 重采样。
- 正弦波、方波、脉冲、chirp、确定性白噪声生成。
- Rectangular、Hann、Hamming、Blackman 窗函数。
- 线性卷积、循环卷积、移动平均、FIR 滤波和 IIR biquad 滤波。
- 统计量、去趋势、相关分析、峰值检测、Welch PSD、频谱特征、分帧、overlap-add 和 FFT 卷积。
- `cmd/main` 命令行工具：`demo`、`fft`、`analyze`、`window`、`convolve`、`stft`、`psd`、`resample`、`biquad`、`stats`、`correlate`、`welch`、`peaks`。
- 示例 CSV 数据、README、API 文档、设计说明、CI、验收脚本和一页申报 PDF。

## 组委会要求对应

- 公开仓库：GitHub 与 GitLink 均公开可访问。
- MoonBit 为主体：核心库与 CLI 均为 MoonBit 实现。
- README：包含项目目标、功能、示例命令、API 草图、边界和路线图。
- 可运行示例：`examples/` 下提供固定 CSV fixtures，CLI smoke test 可复现。
- 测试：覆盖 FFT/IFFT、卷积、窗函数、滤波、统计、相关、Welch PSD、频谱特征、分帧和边界条件。
- CI：GitHub Actions 在 Ubuntu、macOS、Windows 上覆盖接口生成、格式检查、全后端 check/build/test，并提供 CLI smoke。
- Mooncakes：本次变更后按 `moon.mod` 元数据发布为 `chgttyyr/MoonSpectrum@0.2.0`。
- 可维护性：文档说明当前边界和后续扩展方向，避免与音频引擎绑定。

## 本地验收命令

```powershell
moon info
moon fmt --check
moon check --target all --warn-list +73
moon build --target all
moon test --target all
moon run cmd/main -- demo
moon run cmd/main -- fft examples/sine.csv --sample-rate 8
moon run cmd/main -- analyze examples/sine.csv --sample-rate 8
moon run cmd/main -- window hann 4
moon run cmd/main -- convolve examples/sine.csv examples/kernel.csv
moon run cmd/main -- stft examples/sine.csv --window-length 8 --hop-size 4 --window hann
moon run cmd/main -- psd examples/sine.csv --sample-rate 8
moon run cmd/main -- resample examples/sine.csv --target-length 16
moon run cmd/main -- biquad examples/sine.csv --type lowpass --cutoff 2 --sample-rate 8
moon run cmd/main -- stats examples/offset.csv
moon run cmd/main -- correlate examples/dual-tone.csv --max-lag 4
moon run cmd/main -- welch examples/sine.csv --sample-rate 8 --segment-length 8 --overlap 0.5 --window hann
moon run cmd/main -- peaks examples/dual-tone.csv --threshold 0.4 --min-distance 2
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun
```

## 发布前身份要求

Mooncakes 发布账号必须与 `moon.mod` 中的模块 owner `chgttyyr` 一致。发布前需确认：

```powershell
moon whoami
```

输出应为 `Logged in as chgttyyr`。

## 发布结果

Mooncakes 发布命令：

```powershell
moon publish
```

服务端返回 `Server status: 200 OK`。发布后核查：

```powershell
curl.exe -s -o NUL -w "%{http_code}" https://mooncakes.io/api/v0/modules/chgttyyr/MoonSpectrum
curl.exe -s -o NUL -w "%{http_code}" https://mooncakes.io/docs/chgttyyr/MoonSpectrum
curl.exe -s -o NUL -w "%{http_code}" https://mooncakes.io/docs/chgttyyr/MoonSpectrum@0.2.0
```

上述三个地址均返回 `200`。
