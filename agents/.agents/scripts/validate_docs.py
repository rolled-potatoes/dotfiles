#!/usr/bin/env python3
"""Run lightweight readability checks against Markdown documents."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


FRONTMATTER_PATTERN = re.compile(r"\A---\s*\n.*?\n---\s*(?:\n|\Z)", re.DOTALL)
FENCED_CODE_PATTERN = re.compile(
    r"^(?P<fence>`{3,}|~{3,})[^\n]*\n.*?^(?P=fence)\s*$",
    re.DOTALL | re.MULTILINE,
)
LIST_ITEM_PATTERN = re.compile(r"^\s*(?:[-*+]\s+|\d+[.)]\s+)", re.MULTILINE)
SECOND_LEVEL_HEADING_PATTERN = re.compile(r"^##\s+", re.MULTILINE)
TABLE_LINE_PATTERN = re.compile(r"^\s*\|.*\|\s*$")
METADATA_LABEL_PATTERN = re.compile(
    r"^(?:작성자|작성일|수정일|최종\s*수정일|author|created(?:\s*at)?|"
    r"updated(?:\s*at)?|last\s*updated|date)$",
    re.IGNORECASE,
)
EMOJI_PATTERN = re.compile(
    "["
    "\U0001F1E6-\U0001F1FF"
    "\U0001F300-\U0001F5FF"
    "\U0001F600-\U0001F64F"
    "\U0001F680-\U0001F6FF"
    "\U0001F700-\U0001F77F"
    "\U0001F780-\U0001F7FF"
    "\U0001F800-\U0001F8FF"
    "\U0001F900-\U0001F9FF"
    "\U0001FA00-\U0001FAFF"
    "\u2600-\u26FF"
    "\u2700-\u27BF"
    "]"
)

MAX_PARAGRAPH_LENGTH = 300
MIN_DOCUMENT_LENGTH_FOR_LIST = 600
MAX_EMOJI_COUNT = 1


@dataclass(frozen=True)
class Finding:
    level: str
    path: Path
    line: int
    message: str

    def render(self) -> str:
        return f"[{self.level}] {self.path}:{self.line}: {self.message}"


def mask_match_preserving_lines(match: re.Match[str]) -> str:
    return "\n" * match.group(0).count("\n")


def mask_non_prose(text: str) -> str:
    masked = FRONTMATTER_PATTERN.sub(mask_match_preserving_lines, text, count=1)
    return FENCED_CODE_PATTERN.sub(mask_match_preserving_lines, masked)


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def split_table_cells(line: str) -> list[str]:
    return [cell.strip().strip("*_`") for cell in line.strip().strip("|").split("|")]


def find_top_metadata_table(text: str, path: Path) -> list[Finding]:
    analysis_text = mask_non_prose(text)
    heading = SECOND_LEVEL_HEADING_PATTERN.search(analysis_text)
    top_end = heading.start() if heading else len(analysis_text)
    top_lines = analysis_text[:top_end].splitlines()

    findings: list[Finding] = []
    for index, line in enumerate(top_lines, start=1):
        if not TABLE_LINE_PATTERN.match(line):
            continue
        labels = split_table_cells(line)
        if any(METADATA_LABEL_PATTERN.fullmatch(label) for label in labels):
            findings.append(
                Finding(
                    "ERROR",
                    path,
                    index,
                    "문서 상단에 작성자·작성일·수정일 등의 메타정보 표를 두지 마세요.",
                )
            )
            break
    return findings


def iter_plain_paragraphs(text: str) -> list[tuple[int, str]]:
    paragraphs: list[tuple[int, str]] = []
    current: list[str] = []
    start_line = 1

    def flush() -> None:
        nonlocal current
        if current:
            paragraphs.append((start_line, " ".join(part.strip() for part in current)))
            current = []

    for index, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        excluded = (
            not stripped
            or stripped.startswith("#")
            or stripped.startswith(">")
            or stripped.startswith("<!--")
            or TABLE_LINE_PATTERN.match(line)
            or LIST_ITEM_PATTERN.match(line)
        )
        if excluded:
            flush()
            continue
        if not current:
            start_line = index
        current.append(line)
    flush()
    return paragraphs


def validate_text(text: str, path: Path) -> list[Finding]:
    findings = find_top_metadata_table(text, path)
    prose = mask_non_prose(text)

    for start_line, paragraph in iter_plain_paragraphs(prose):
        if len(paragraph) >= MAX_PARAGRAPH_LENGTH:
            findings.append(
                Finding(
                    "WARNING",
                    path,
                    start_line,
                    f"일반 문단이 {len(paragraph)}자입니다. {MAX_PARAGRAPH_LENGTH}자 미만의 의미 단위로 나누는 것을 검토하세요.",
                )
            )

    emoji_matches = list(EMOJI_PATTERN.finditer(prose))
    if len(emoji_matches) > MAX_EMOJI_COUNT:
        findings.append(
            Finding(
                "WARNING",
                path,
                line_number(prose, emoji_matches[1].start()),
                f"이모지가 {len(emoji_matches)}개입니다. 꼭 필요한 표현만 남기세요.",
            )
        )

    body_length = len(re.sub(r"\s+", "", prose))
    if body_length >= MIN_DOCUMENT_LENGTH_FOR_LIST and not LIST_ITEM_PATTERN.search(prose):
        findings.append(
            Finding(
                "WARNING",
                path,
                1,
                f"본문이 {body_length}자인데 목록이 없습니다. 병렬 정보나 절차를 목록으로 정리할 수 있는지 검토하세요.",
            )
        )
    return findings


def discover_markdown(inputs: list[Path]) -> tuple[list[Path], list[str]]:
    files: set[Path] = set()
    errors: list[str] = []
    for input_path in inputs:
        if input_path.is_dir():
            files.update(path for path in input_path.rglob("*.md") if path.is_file())
        elif input_path.is_file() and input_path.suffix.lower() == ".md":
            files.add(input_path)
        elif not input_path.exists():
            errors.append(f"입력 경로가 없습니다: {input_path}")
        else:
            errors.append(f"Markdown 파일 또는 디렉터리가 아닙니다: {input_path}")
    if not files and not errors:
        errors.append("검사할 Markdown 파일을 찾지 못했습니다.")
    return sorted(files), errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Markdown 문서의 명백한 가독성 규칙 위반을 검사합니다."
    )
    parser.add_argument("paths", nargs="+", type=Path, help="Markdown 파일 또는 디렉터리")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    files, input_errors = discover_markdown(args.paths)
    if input_errors:
        for error in input_errors:
            print(f"[ERROR] {error}")
        return 2

    findings: list[Finding] = []
    for path in files:
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as error:
            print(f"[ERROR] {path}: 파일을 읽을 수 없습니다: {error}")
            return 2
        findings.extend(validate_text(text, path))

    for finding in findings:
        print(finding.render())

    errors = sum(finding.level == "ERROR" for finding in findings)
    warnings = sum(finding.level == "WARNING" for finding in findings)
    print(f"검사 완료: files={len(files)} errors={errors} warnings={warnings}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
