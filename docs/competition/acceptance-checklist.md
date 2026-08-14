# MoonSpectrum acceptance checklist

## Repository

- Public GitHub repository: `https://github.com/chgttyyr/MoonSpectrum`
- Public GitLink repository: `https://gitlink.org.cn/chgttyyr/MoonSpectrum`
- License: Apache-2.0
- Main language: MoonBit
- Package name: `chgttyyr/MoonSpectrum`

## Required reviewer surfaces

- README with project intro, scope, examples, API sketch, limitations, and roadmap.
- Installation instructions covering the official MoonBit toolchain and the pinned dependency.
- Fixture provenance and numeric invariants documented in `docs/fixtures.md`.
- Runnable MoonBit tests.
- Numerical tests for statistics, correlation, Welch PSD, spectral descriptors, framing, filters, event detection, filter responses, and spectrogram summaries.
- CLI examples using checked fixture data.
- CLI smoke coverage for `stats`, `correlate`, `welch`, and `peaks`.
- CI workflow for format, check, tests, and CLI smoke.
- CI workflow for all-backend check, build, and test on Ubuntu, macOS, and Windows.
- GitLink `.gitlink-ci.yml` workflow with equivalent backend and CLI validation.
- One-page Chinese proposal PDF under `docs/competition/`.
- Mooncakes overlap search record under `docs/competition/mooncakes-search.md`.
- Final report under `docs/competition/final-report.md`.
- Release checklist under `docs/competition/release-checklist.md`.
- Mooncakes package page: `https://mooncakes.io/docs/chgttyyr/MoonSpectrum`.

## Local verification

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun
```

The script verifies required files, contributor history, Mooncakes availability, strict
external-command exit codes, normalized public-interface drift, `moon info`,
`moon fmt --check`, `moon check --target all --warn-list +73`, `moon build --target all`,
`moon test --target all`, and all documented CLI smoke commands. Windows native
validation requires MSYS2 UCRT64 GCC on the local machine; GitHub Actions installs
the same compiler family automatically.
