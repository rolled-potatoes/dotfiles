#!/usr/bin/env python3
"""Isolated contract tests for validate_harness_state.py."""

from __future__ import annotations

import importlib.util
import os
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("validate_harness_state.py")
SPEC = importlib.util.spec_from_file_location("harness_state", MODULE_PATH)
assert SPEC and SPEC.loader
HARNESS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(HARNESS)


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def metadata(**values: str) -> str:
    body = "\n".join(f"{key}: {value}" for key, value in values.items())
    return f"---\n{body}\n---\n"


class HarnessStateTests(unittest.TestCase):
    def fixture(self) -> Path:
        root = Path(tempfile.mkdtemp(prefix="harness-state-")) / ".agents/work/example"
        write(root / "goal.md", "# Goal\n")
        write(root / "plan.md", metadata(approval="approved"))
        return root

    def project_fixture(self, manifest: str, contents: str) -> tuple[Path, Path]:
        project = Path(tempfile.mkdtemp(prefix="harness-project-"))
        write(project / manifest, contents)
        work = project / ".agents/work/example"
        write(work / "goal.md", "# Goal\n")
        write(work / "plan.md", metadata(approval="approved"))
        return project, work

    def loop(self, root: Path, number: int, status: str = "replan", key: str = "verify-failed", *, elapsed: str = "01:00:00", human: bool = False) -> None:
        directory = root / "loops" / f"loop-{number:02d}"
        write(directory / "plan.md", metadata(created_at="2026-08-23T00:00:00+00:00"))
        write(directory / "implement.md", "# Implement\n")
        write(directory / "validate.md", metadata(status="passed", snapshot=f"hash-{number}"))
        report = {
            "status": status,
            "finished_at": f"2026-08-23T{elapsed}+00:00",
            "validation_snapshot": f"hash-{number}",
        }
        if status == "replan":
            report["failure_key"] = key
        if human:
            report["human_verification_required"] = "true"
        write(directory / "report.md", metadata(**report))

    def test_accepts_single_replan(self) -> None:
        root = self.fixture()
        self.loop(root, 1)
        self.assertEqual(HARNESS.validate(root), [])

    def test_rejects_sixth_loop(self) -> None:
        root = self.fixture()
        for number in range(1, 7):
            self.loop(root, number)
        self.assertTrue(any("최대 5회" in error for error in HARNESS.validate(root)))

    def test_rejects_fourth_same_failure(self) -> None:
        root = self.fixture()
        for number in range(1, 5):
            self.loop(root, number)
        self.assertTrue(any("최대는 3회" in error for error in HARNESS.validate(root)))

    def test_requires_blocked_after_two_hours(self) -> None:
        root = self.fixture()
        self.loop(root, 1, elapsed="02:00:01")
        self.assertTrue(any("2시간 초과" in error for error in HARNESS.validate(root)))

    def test_rejects_success_without_required_human_evidence(self) -> None:
        root = self.fixture()
        self.loop(root, 1, status="success", human=True)
        self.assertTrue(any("사람 검증" in error for error in HARNESS.validate(root)))

    def test_rejects_stale_validation_snapshot(self) -> None:
        root = self.fixture()
        self.loop(root, 1)
        report = root / "loops/loop-01/report.md"
        write(report, metadata(status="replan", finished_at="2026-08-23T01:00:00+00:00", validation_snapshot="old", failure_key="verify-failed"))
        self.assertTrue(any("validation_snapshot" in error for error in HARNESS.validate(root)))

    def test_rejects_a_loop_after_blocked(self) -> None:
        root = self.fixture()
        self.loop(root, 1, status="blocked")
        self.loop(root, 2)
        self.assertTrue(any("blocked 뒤" in error for error in HARNESS.validate(root)))

    def test_accepts_success_with_human_evidence(self) -> None:
        root = self.fixture()
        self.loop(root, 1, status="success", human=True)
        report = root / "loops/loop-01/report.md"
        write(report, metadata(status="success", finished_at="2026-08-23T01:00:00+00:00", validation_snapshot="hash-1", human_verification_required="true", human_verification_status="passed"))
        self.assertEqual(HARNESS.validate(root), [])

    def test_accepts_a_node_project_fixture_and_relative_claude_link(self) -> None:
        project, work = self.project_fixture("package.json", '{"scripts":{"test":"node --test"}}\n')
        agents = project / "AGENTS.md"
        write(agents, "# Project rules\n")
        os.symlink("AGENTS.md", project / "CLAUDE.md")
        self.loop(work, 1, status="success")
        self.assertEqual(os.readlink(project / "CLAUDE.md"), "AGENTS.md")
        self.assertEqual(HARNESS.validate(work), [])

    def test_existing_harness_fixture_is_read_only_to_the_contract_auditor(self) -> None:
        project, work = self.project_fixture("pyproject.toml", "[project]\nname = 'example'\n")
        legacy = project / "scripts/legacy-harness.sh"
        write(legacy, "#!/bin/sh\necho legacy\n")
        before = legacy.read_bytes()
        self.loop(work, 1)
        self.assertEqual(HARNESS.validate(work), [])
        self.assertEqual(legacy.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
