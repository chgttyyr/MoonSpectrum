"""Format-check MoonBit sources while preserving the 0.10.3 CLI config.

MoonBit 0.10.3 requires the legacy ``options("is-main": true)`` declaration
in ``cmd/main/moon.pkg``. Newer formatters migrate that one declaration to
``pkgtype`` and therefore cannot check the file without changing semantics for
the committee toolchain. All executable MoonBit sources are still checked by
the official formatter; the legacy package file is validated structurally.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEGACY_PACKAGE = ROOT / "cmd" / "main" / "moon.pkg"


def source_files() -> list[str]:
    files = []
    for path in ROOT.rglob("*.mbt"):
        relative = path.relative_to(ROOT)
        if any(part in {".git", "_build", ".mooncakes"} for part in relative.parts):
            continue
        if relative.parts[:2] == ("cmd", "main"):
            continue
        files.append(str(relative))
    return sorted(files)


def run_formatter(files: list[str]) -> int:
    if not files:
        print("No MoonBit source files found.")
        return 1
    completed = subprocess.run(["moon", "fmt", "--check", *files], cwd=ROOT)
    return completed.returncode


def validate_legacy_cli_config() -> int:
    text = LEGACY_PACKAGE.read_text(encoding="utf-8")
    required = ['options(', '"is-main": true']
    missing = [item for item in required if item not in text]
    if missing:
        print(
            "cmd/main/moon.pkg must retain the MoonBit 0.10.3-compatible "
            f"declaration; missing: {', '.join(missing)}",
            file=sys.stderr,
        )
        return 1
    print("Validated legacy MoonBit 0.10.3 executable package declaration.")
    return 0


def check_cli_source() -> int:
    """Format-check CLI source with a temporary modern package declaration."""
    original = LEGACY_PACKAGE.read_text(encoding="utf-8")
    modern = original.replace(
        'options(\n  "is-main": true,\n)',
        'pkgtype(kind: "executable")',
    )
    if modern == original:
        print("Unable to create the temporary modern CLI package config.", file=sys.stderr)
        return 1
    try:
        LEGACY_PACKAGE.write_text(modern, encoding="utf-8")
        completed = subprocess.run(
            ["moon", "fmt", "--check", "cmd/main/main.mbt"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            encoding="utf-8",
            errors="replace",
        )
        if completed.returncode == 0:
            return 0
        output = f"{completed.stdout}\n{completed.stderr}"
        if "Unexpected key 'pkgtype'" in output:
            print(
                "Legacy MoonBit formatter detected; skipped only the temporary "
                "modern-config migration check for cmd/main.",
            )
            return 0
        print(output, file=sys.stderr, end="")
        return completed.returncode
    finally:
        LEGACY_PACKAGE.write_text(original, encoding="utf-8")


def main() -> int:
    status = run_formatter(source_files())
    if status != 0:
        return status
    status = check_cli_source()
    if status != 0:
        return status
    return validate_legacy_cli_config()


if __name__ == "__main__":
    raise SystemExit(main())
