#!/usr/bin/env python3
"""Register shared Codex roles without rewriting machine-local TOML."""
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import tomllib
from datetime import datetime

BEGIN = "# >>> dotfiles managed codex agents >>>"
END = "# <<< dotfiles managed codex agents <<<"


def main():
    config = Path(sys.argv[1])
    roles = Path(sys.argv[2]).resolve()
    dry_run = sys.argv[3] == "1"
    if config.is_symlink():
        raise ValueError(f"refusing to replace symlinked configuration: {config}")
    original = config.read_text(encoding="utf-8") if config.exists() else ""
    lines = original.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.strip() == BEGIN]
    ends = [i for i, line in enumerate(lines) if line.strip() == END]
    if len(starts) != len(ends) or len(starts) > 1 or (starts and starts[0] >= ends[0]):
        raise ValueError("invalid managed Codex agents markers")
    base = "".join(lines[:starts[0]] + lines[ends[0] + 1:]) if starts else original
    parsed = tomllib.loads(base)
    existing = parsed.get("agents", {})
    if not isinstance(existing, dict):
        raise ValueError("agents must be a TOML table")
    files = sorted(roles.glob("*.toml"))
    if not files:
        raise ValueError(f"no role files found in {roles}")
    conflicts = [file.stem for file in files if file.stem in existing]
    if conflicts:
        raise ValueError("existing agent settings require manual reconciliation: " + ", ".join(conflicts))
    block = [BEGIN]
    for file in files:
        block.extend((f"[agents.{json.dumps(file.stem, ensure_ascii=True)}]", f"config_file = {json.dumps(str(file), ensure_ascii=True)}", ""))
    block.append(END)
    updated = base.rstrip("\n") + ("\n\n" if base else "") + "\n".join(block) + "\n"
    tomllib.loads(updated)
    if updated == original:
        print(f"Codex agent configuration already current: {config}")
        return
    print(f"{'Would update' if dry_run else 'Update'} Codex agent configuration: {config}")
    if dry_run:
        return
    config.parent.mkdir(parents=True, exist_ok=True)
    if config.exists():
        backup = config.with_name(config.name + ".dotfiles-backup-" + datetime.now().strftime("%Y%m%d%H%M%S%f"))
        shutil.copy2(config, backup)
        print(f"Backup: {backup}")
    fd, temp = tempfile.mkstemp(prefix=".config.toml.", dir=config.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            output.write(updated)
        if config.exists():
            os.chmod(temp, config.stat().st_mode & 0o777)
        os.replace(temp, config)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, tomllib.TOMLDecodeError) as error:
        sys.exit(f"Error configuring Codex agents: {error}")
