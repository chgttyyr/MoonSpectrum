# MoonSpectrum acceptance checklist

## Repository

- Public GitHub repository: `https://github.com/chgttyyr/MoonSpectrum`
- Public GitLink repository: `https://gitlink.org.cn/chgttyyr/MoonSpectrum`
- License: Apache-2.0
- Main language: MoonBit
- Package name: `chgttyyr/MoonSpectrum`

## Required reviewer surfaces

- README with project intro, scope, examples, API sketch, limitations, and roadmap.
- Runnable MoonBit tests.
- CLI examples using checked fixture data.
- CI workflow for format, check, tests, and CLI smoke.
- One-page Chinese proposal PDF under `docs/competition/`.
- Mooncakes overlap search record under `docs/competition/mooncakes-search.md`.

## Local verification

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify_acceptance.ps1 -SkipPublishDryRun
```

The script verifies required files, commit count, Mooncakes keyword search, `moon info`,
`moon fmt --check`, `moon check --warn-list +73`, `moon test`, and CLI smoke commands.
