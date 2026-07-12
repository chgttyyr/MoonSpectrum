# Find the real moon binary
$realMoon = "$env:USERPROFILE\.moon\bin\moon.exe"

if ($args.Length -eq 0) {
  & $realMoon
  exit $LASTEXITCODE
}

$cmd = $args[0]
$restArgs = @()
if ($args.Length -gt 1) {
  $restArgs = $args[1..($args.Length - 1)]
}

# Check for --deny-warn
$denyWarn = $false
$filteredArgs = @()
foreach ($arg in $restArgs) {
  if ($arg -eq "--deny-warn") {
    $denyWarn = $true
  } else {
    $filteredArgs += $arg
  }
}

if ($cmd -eq "fmt") {
  if ($denyWarn) {
    # fmt --deny-warn check
    & $realMoon fmt --check @filteredArgs
    exit $LASTEXITCODE
  } else {
    & $realMoon fmt @filteredArgs
  }
} elseif ($cmd -eq "info") {
  if ($denyWarn) {
    & $realMoon info @filteredArgs
    if ($LASTEXITCODE -ne 0) {
      exit $LASTEXITCODE
    }
    git diff --exit-code
    exit $LASTEXITCODE
  } else {
    & $realMoon info @filteredArgs
  }
} else {
  if ($denyWarn) {
    & $realMoon $cmd --deny-warn @filteredArgs
  } else {
    & $realMoon $cmd @filteredArgs
  }
}
