#!/usr/bin/env python3
"""Audit a project-harness evidence directory without reading project secrets."""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter
from datetime import datetime, timedelta
from pathlib import Path


MAX_LOOPS = 5
MAX_FAILURE_REPEATS = 3
MAX_LOOP_DURATION = timedelta(hours=2)
LOOP_NAME = re.compile(r"loop-(\d{2})$")
FAILURE_KEY = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*$")


def frontmatter(path: Path) -> dict[str, str]:
    if not path.is_file():
        return {}
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return {}
    data: dict[str, str] = {}
    for line in lines[1:]:
        if line == "---":
            return data
        if ":" in line:
            key, value = line.split(":", 1)
            data[key.strip()] = value.strip()
    return {}


def parse_time(value: str, path: Path, field: str, errors: list[str]) -> datetime | None:
    if not value:
        errors.append(f"{path}: {field} frontmatter가 필요합니다.")
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        errors.append(f"{path}: {field}는 ISO-8601 시각이어야 합니다.")
        return None


def loop_paths(work_dir: Path, errors: list[str]) -> list[tuple[int, Path]]:
    loops = work_dir / "loops"
    if not loops.exists():
        return []
    found: list[tuple[int, Path]] = []
    for entry in loops.iterdir():
        match = LOOP_NAME.fullmatch(entry.name)
        if entry.is_dir() and match:
            found.append((int(match.group(1)), entry))
        elif entry.is_dir():
            errors.append(f"{entry}: 루프 디렉터리는 loop-NN 형식이어야 합니다.")
    found.sort()
    expected = list(range(1, len(found) + 1))
    if [index for index, _ in found] != expected:
        errors.append("loops: loop 번호는 01부터 빈틈없이 증가해야 합니다.")
    return found


def validate(work_dir: Path) -> list[str]:
    errors: list[str] = []
    for name in ("goal.md", "plan.md"):
        if not (work_dir / name).is_file():
            errors.append(f"{work_dir / name}: 필수 작업 증거가 없습니다.")

    plan = frontmatter(work_dir / "plan.md")
    if (work_dir / "plan.md").is_file() and plan.get("approval") != "approved":
        errors.append(f"{work_dir / 'plan.md'}: approval: approved가 필요합니다.")

    loops = loop_paths(work_dir, errors)
    if len(loops) > MAX_LOOPS:
        errors.append(f"loops: 최대 {MAX_LOOPS}회만 허용됩니다.")

    failures: Counter[str] = Counter()
    reports: list[tuple[int, dict[str, str], Path]] = []
    for position, (index, directory) in enumerate(loops):
        plan_path = directory / "plan.md"
        if not plan_path.is_file():
            errors.append(f"{plan_path}: 루프 계획이 없습니다.")
            continue
        loop_plan = frontmatter(plan_path)
        planned_at = parse_time(loop_plan.get("created_at", ""), plan_path, "created_at", errors)
        report_path = directory / "report.md"
        report = frontmatter(report_path)
        is_latest = position == len(loops) - 1
        if not report_path.is_file():
            if not is_latest:
                errors.append(f"{report_path}: 다음 루프 전에는 직전 결과가 필요합니다.")
            continue
        for name in ("implement.md", "validate.md"):
            if not (directory / name).is_file():
                errors.append(f"{directory / name}: 결과를 기록하기 전에 필요합니다.")
        status = report.get("status")
        if status not in {"success", "replan", "blocked"}:
            errors.append(f"{report_path}: status는 success, replan, blocked 중 하나여야 합니다.")
        finished_at = parse_time(report.get("finished_at", ""), report_path, "finished_at", errors)
        if planned_at and finished_at:
            if finished_at < planned_at:
                errors.append(f"{report_path}: finished_at이 created_at보다 이릅니다.")
            elif finished_at - planned_at > MAX_LOOP_DURATION and status != "blocked":
                errors.append(f"{report_path}: 2시간 초과 루프는 blocked여야 합니다.")
        validation = frontmatter(directory / "validate.md")
        if validation and report.get("validation_snapshot") != validation.get("snapshot"):
            errors.append(f"{report_path}: validation_snapshot이 validate.md의 snapshot과 일치해야 합니다.")
        if status == "replan":
            key = report.get("failure_key", "")
            if not FAILURE_KEY.fullmatch(key):
                errors.append(f"{report_path}: replan에는 kebab-case failure_key가 필요합니다.")
            else:
                failures[key] += 1
        if status == "success" and report.get("human_verification_required") == "true":
            if report.get("human_verification_status") != "passed":
                errors.append(f"{report_path}: 필요한 사람 검증이 passed가 아닙니다.")
        reports.append((index, report, report_path))

    for key, count in failures.items():
        if count > MAX_FAILURE_REPEATS:
            errors.append(f"loops: failure_key {key}가 {count}회 반복되었습니다. 최대는 {MAX_FAILURE_REPEATS}회입니다.")
    for index, report, path in reports[:-1]:
        if report.get("status") in {"success", "blocked"}:
            errors.append(f"{path}: {report.get('status')} 뒤에는 다음 루프를 만들 수 없습니다.")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="프로젝트 하네스 증거 상태를 검사합니다.")
    parser.add_argument("--work-dir", type=Path, required=True, help=".agents/work/<task-id> 경로")
    args = parser.parse_args()
    errors = validate(args.work_dir)
    for error in errors:
        print(f"ERROR: {error}")
    print(f"harness-state: {'PASS' if not errors else 'FAIL'} ({args.work_dir})")
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
