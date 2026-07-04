param(
  [switch]$SkipPublishDryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  Write-Host "MoonSpectrum acceptance gate"
  Write-Host "Workspace: $root"

  Write-Host ""
  Write-Host "Toolchain:"
  moon version --all

  Write-Host ""
  Write-Host "Required files:"
  $required = @(
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "moon.mod",
    "moon.pkg",
    "cmd/main/main.mbt",
    ".github/workflows/ci.yml",
    "docs/competition/acceptance-checklist.md"
  )
  foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
      throw "Missing required file: $path"
    }
    Write-Host "  ok $path"
  }

  Write-Host ""
  Write-Host "Commit history:"
  $count = [int](git rev-list --count HEAD)
  Write-Host "  commits=$count"
  if ($count -lt 10 -or $count -gt 20) {
    throw "Expected 10-20 commits for proposal review; got $count"
  }

  Write-Host ""
  Write-Host "Mooncakes search:"
  $modules = curl.exe -s -L https://mooncakes.io/api/v0/modules
  $terms = "fft|fourier|spectrum|spectral|wavelet|convolution|iir"
  $hits = $modules | Select-String -Pattern $terms -AllMatches
  if ($hits) {
    Write-Host "  related keywords present in registry; see docs/competition/mooncakes-search.md"
  } else {
    Write-Host "  no direct keyword overlap found for fft/fourier/spectrum/wavelet/convolution/iir"
  }

  Write-Host ""
  Write-Host "MoonBit checks:"
  moon info
  moon fmt --check
  moon check --warn-list +73
  moon test

  Write-Host ""
  Write-Host "CLI smoke:"
  moon run cmd/main -- demo
  moon run cmd/main -- fft examples/sine.csv --sample-rate 8
  moon run cmd/main -- analyze examples/sine.csv --sample-rate 8
  moon run cmd/main -- window hann 4
  moon run cmd/main -- convolve examples/sine.csv examples/kernel.csv

  if (-not $SkipPublishDryRun) {
    Write-Host ""
    Write-Host "Mooncakes dry run:"
    moon publish --dry-run
  }

  Write-Host ""
  Write-Host "Acceptance gate passed"
}
finally {
  Pop-Location
}
