param(
  [switch]$SkipPublishDryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$env:Path = "$env:USERPROFILE\.moon\bin;" + $env:Path

function Assert-ExternalSuccess {
  param([string]$Label)
  if ($LASTEXITCODE -ne 0) {
    throw "$Label failed with exit code $LASTEXITCODE"
  }
}

Push-Location $root
try {
  Write-Host "MoonSpectrum acceptance gate"
  Write-Host "Workspace: $root"

  Write-Host ""
  Write-Host "Toolchain:"
  moon version --all
  Assert-ExternalSuccess "moon version"

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
    "docs/fixtures.md",
    "docs/competition/acceptance-checklist.md",
    "docs/competition/final-report.md",
    "docs/competition/release-checklist.md"
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
  Assert-ExternalSuccess "git rev-list"
  Write-Host "  commits=$count"
  if ($count -lt 10) {
    throw "Expected at least 10 commits for public development review; got $count"
  }
  $identities = git log --format="%an <%ae> | %cn <%ce>" | Sort-Object -Unique
  Assert-ExternalSuccess "git log"
  foreach ($identity in $identities) {
    if ($identity -notmatch "^chgttyyr <299825988\+chgttyyr@users\.noreply\.github\.com> \| chgttyyr <299825988\+chgttyyr@users\.noreply\.github\.com>$") {
      throw "Unexpected contributor identity: $identity"
    }
  }
  Write-Host "  contributor=chgttyyr"

  Write-Host ""
  Write-Host "Mooncakes search:"
  $modules = curl.exe -s -L https://mooncakes.io/api/v0/modules
  Assert-ExternalSuccess "Mooncakes module index request"
  $terms = "fft|fourier|spectrum|spectral|wavelet|convolution|iir"
  $hits = $modules | Select-String -Pattern $terms -AllMatches
  if ($hits) {
    Write-Host "  related keywords present in registry; see docs/competition/mooncakes-search.md"
  } else {
    Write-Host "  no direct keyword overlap found for fft/fourier/spectrum/wavelet/convolution/iir"
  }
  $packageStatus = curl.exe -s -o NUL -w "%{http_code}" https://mooncakes.io/api/v0/modules/chgttyyr/MoonSpectrum
  Assert-ExternalSuccess "Mooncakes package request"
  Write-Host "  package api status=$packageStatus"

  Write-Host ""
  Write-Host "MoonBit checks:"
  python scripts/check_format.py
  Assert-ExternalSuccess "python scripts/check_format.py"
  moon info
  Assert-ExternalSuccess "moon info"
  git diff --exit-code -- . ':(exclude)*.mbti'
  Assert-ExternalSuccess "source drift check"
git diff --ignore-space-at-eol --ignore-blank-lines --exit-code -- '*.mbti'
  Assert-ExternalSuccess "public interface drift check"
  moon check --target all --warn-list +73
  Assert-ExternalSuccess "moon check --target all"
  moon build --target all
  Assert-ExternalSuccess "moon build --target all"
  moon test --target all
  Assert-ExternalSuccess "moon test --target all"

  Write-Host ""
  Write-Host "CLI smoke:"
  moon run cmd/main -- demo
  Assert-ExternalSuccess "CLI demo"
  moon run cmd/main -- fft examples/sine.csv --sample-rate 8
  Assert-ExternalSuccess "CLI fft"
  moon run cmd/main -- analyze examples/sine.csv --sample-rate 8
  Assert-ExternalSuccess "CLI analyze"
  moon run cmd/main -- window hann 4
  Assert-ExternalSuccess "CLI window"
  moon run cmd/main -- convolve examples/sine.csv examples/kernel.csv
  Assert-ExternalSuccess "CLI convolve"
  moon run cmd/main -- stft examples/sine.csv --window-length 8 --hop-size 4 --window hann
  Assert-ExternalSuccess "CLI stft"
  moon run cmd/main -- psd examples/sine.csv --sample-rate 8
  Assert-ExternalSuccess "CLI psd"
  moon run cmd/main -- resample examples/sine.csv --target-length 16
  Assert-ExternalSuccess "CLI resample"
  moon run cmd/main -- biquad examples/sine.csv --type lowpass --cutoff 2 --sample-rate 8
  Assert-ExternalSuccess "CLI biquad"
  moon run cmd/main -- stats examples/offset.csv
  Assert-ExternalSuccess "CLI stats"
  moon run cmd/main -- correlate examples/dual-tone.csv --max-lag 4
  Assert-ExternalSuccess "CLI correlate"
  moon run cmd/main -- welch examples/sine.csv --sample-rate 8 --segment-length 8 --overlap 0.5 --window hann
  Assert-ExternalSuccess "CLI welch"
  moon run cmd/main -- peaks examples/dual-tone.csv --threshold 0.4 --min-distance 2
  Assert-ExternalSuccess "CLI peaks"

  if (-not $SkipPublishDryRun) {
    Write-Host ""
    Write-Host "Mooncakes dry run:"
    $dryRunOutput = @(moon publish --dry-run 2>&1)
    $dryRunOutput | Write-Host
    $dryRunExit = $LASTEXITCODE
    $dryRunText = $dryRunOutput -join "`n"
    if ($dryRunExit -ne 0 -and $dryRunText -notmatch "Dry run completed successfully") {
      throw "moon publish --dry-run failed with exit code $dryRunExit"
    }
  }

  Write-Host ""
  Write-Host "Acceptance gate passed"
}
finally {
  Pop-Location
}
