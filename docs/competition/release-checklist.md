# MoonSpectrum 发布清单

## 官方验收面

- [x] 公开 GitHub 仓库
- [x] 公开 GitLink 仓库
- [x] MoonBit 为主要实现语言
- [x] README 完整说明目标、功能、示例和边界
- [x] Apache-2.0 许可证
- [x] 可运行测试
- [x] 可运行 CLI 示例
- [x] GitHub Actions CI
- [x] 一页中文申报 PDF
- [x] Mooncakes 检索记录
- [x] Mooncakes 正式发布

## 发布命令

```powershell
moon whoami
moon publish --dry-run
moon publish
```

## 发布后核查

```powershell
curl.exe -I -L https://mooncakes.io/docs/chgttyyr/MoonSpectrum
curl.exe -s -L https://mooncakes.io/api/v0/modules/chgttyyr/MoonSpectrum
```

发布成功。`chgttyyr/MoonSpectrum@0.1.0` 已在 Mooncakes API 和文档页返回 HTTP 200。
