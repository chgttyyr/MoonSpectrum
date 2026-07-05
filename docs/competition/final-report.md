# MoonSpectrum 结项报告

## 项目与仓库

- 项目名称：MoonSpectrum
- Mooncakes 包名：`chgttyyr/MoonSpectrum`
- GitHub 仓库：<https://github.com/chgttyyr/MoonSpectrum>
- GitLink 仓库：<https://gitlink.org.cn/chgttyyr/MoonSpectrum>
- Mooncakes 链接：<https://mooncakes.io/docs/chgttyyr/MoonSpectrum>
- 许可证：Apache-2.0
- 主要语言：MoonBit

## 完成内容

MoonSpectrum 已完成科学信号处理基础库的首个可发布版本，包含：

- `Complex` 复数类型和近似比较。
- DFT、radix-2 FFT、inverse FFT。
- 幅度谱、功率谱、频率 bin 和主频检测。
- 正弦波、方波、脉冲、chirp、确定性白噪声生成。
- Rectangular、Hann、Hamming、Blackman 窗函数。
- 线性卷积、循环卷积、移动平均和基础 FIR 滤波。
- `cmd/main` 命令行工具：`demo`、`fft`、`analyze`、`window`、`convolve`。
- 示例 CSV 数据、README、API 文档、设计说明、CI、验收脚本和一页申报 PDF。

## 组委会要求对应

- 公开仓库：GitHub 与 GitLink 均公开可访问。
- MoonBit 为主体：核心库与 CLI 均为 MoonBit 实现。
- README：包含项目目标、功能、示例命令、API 草图、边界和路线图。
- 可运行示例：`examples/` 下提供固定 CSV fixtures，CLI smoke test 可复现。
- 测试：覆盖 FFT/IFFT、卷积、窗函数、滤波和边界条件。
- CI：GitHub Actions 覆盖接口生成、格式检查、静态检查、测试和 CLI smoke。
- Mooncakes：按 `moon.mod` 元数据发布为 `chgttyyr/MoonSpectrum`。
- 可维护性：文档说明当前边界和后续扩展方向，避免与音频引擎绑定。

## 本地验收命令

```powershell
moon info
moon fmt --check
moon check --warn-list +73
moon test
moon run cmd/main -- demo
moon run cmd/main -- fft examples/sine.csv --sample-rate 8
moon run cmd/main -- analyze examples/sine.csv --sample-rate 8
moon run cmd/main -- window hann 4
moon run cmd/main -- convolve examples/sine.csv examples/kernel.csv
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun
```

## 发布前身份要求

Mooncakes 发布账号必须与 `moon.mod` 中的模块 owner `chgttyyr` 一致。发布前需确认：

```powershell
moon whoami
```

输出应为 `Logged in as chgttyyr`。
