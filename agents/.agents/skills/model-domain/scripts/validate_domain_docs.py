#!/usr/bin/env python3
"""Validate structural, language, and readability contracts for DDD Markdown."""

from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


ID_PREFIXES = (
    "BC",
    "AGG",
    "ENT",
    "VO",
    "CMD",
    "EVT",
    "STATE",
    "INV",
    "POL",
    "BR",
    "DS",
    "DEC",
    "Q",
    "ASM",
)
ID_PATTERN = re.compile(
    rf"\b(?:{'|'.join(ID_PREFIXES)})-\d{{3}}\b"
)
DEFINITION_PATTERN = re.compile(
    rf"^###\s+((?:{'|'.join(ID_PREFIXES)})-\d{{3}})\b",
    re.MULTILINE,
)
FRONTMATTER_PATTERN = re.compile(r"\A---\s*\n(.*?)\n---\s*(?:\n|\Z)", re.DOTALL)
KEY_PATTERN = re.compile(r"^([a-z_][a-z0-9_]*):(?:\s*(.*))?$", re.MULTILINE)
SECOND_LEVEL_HEADING_PATTERN = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)
READER_GUIDE_FIELD_PATTERN = re.compile(
    r"^\s*-\s*(목적|적용 범위|핵심 변경|권장 읽기 순서)\s*:\s*(.*?)\s*$",
    re.MULTILINE,
)
HANGUL_PATTERN = re.compile(r"[가-힣]")
ASCII_LETTER_PATTERN = re.compile(r"[A-Za-z]")

CORE_DOCUMENT_TYPES = {
    "domain-model.md": "domain-model",
    "domain-policies.md": "domain-policies",
    "business-rules.md": "business-rules",
}
REQUIRED_FRONTMATTER = {
    "document_type",
    "document_language",
    "bounded_context",
    "status",
    "version",
    "last_reviewed_at",
    "evidence_revision",
    "knowledge_owner",
    "supersedes",
}
VALID_DOCUMENT_STATUSES = {"draft", "confirmed", "superseded"}
REQUIRED_READER_GUIDE_FIELDS = {
    "목적",
    "적용 범위",
    "핵심 변경",
    "권장 읽기 순서",
}
EXPECTED_DOCUMENT_LANGUAGE = "ko-KR"
MIN_READER_GUIDE_HANGUL = 10
MAX_TABLE_DATA_ROWS = 20


@dataclass(frozen=True)
class Location:
    path: Path
    line: int

    def render(self, root: Path) -> str:
        return f"{self.path.relative_to(root)}:{self.line}"


def parse_frontmatter(text: str) -> dict[str, str] | None:
    match = FRONTMATTER_PATTERN.search(text)
    if not match:
        return None
    return {
        key: strip_scalar_quotes(value.strip())
        for key, value in KEY_PATTERN.findall(match.group(1))
    }


def strip_scalar_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def mask_fenced_code(text: str) -> str:
    def mask(match: re.Match[str]) -> str:
        return "\n" * match.group(0).count("\n")

    masked = re.sub(r"```.*?```", mask, text, flags=re.DOTALL)
    return re.sub(r"~~~.*?~~~", mask, masked, flags=re.DOTALL)


def mask_frontmatter(text: str) -> str:
    match = FRONTMATTER_PATTERN.search(text)
    if not match:
        return text
    return "\n" * match.group(0).count("\n") + text[match.end():]


def discover_markdown(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*.md") if path.is_file())


def validate_reader_guide(
    text: str,
    relative: Path,
    errors: list[str],
) -> None:
    headings = list(SECOND_LEVEL_HEADING_PATTERN.finditer(text))
    if not headings or headings[0].group(1).strip() != "문서 안내":
        errors.append(
            f"{relative}: 첫 번째 2단계 절은 '문서 안내'여야 합니다."
        )
        return

    start = headings[0].end()
    end = headings[1].start() if len(headings) > 1 else len(text)
    guide = text[start:end]
    fields = {
        key: value.strip()
        for key, value in READER_GUIDE_FIELD_PATTERN.findall(guide)
    }
    missing = sorted(REQUIRED_READER_GUIDE_FIELDS - fields.keys())
    if missing:
        errors.append(
            f"{relative}: 문서 안내 필수 항목 누락: {', '.join(missing)}"
        )
    empty = sorted(
        key
        for key in REQUIRED_READER_GUIDE_FIELDS
        if key in fields and not fields[key]
    )
    if empty:
        errors.append(
            f"{relative}: 문서 안내 필수 항목의 값이 비어 있습니다: "
            f"{', '.join(empty)}"
        )

    guide_values = " ".join(fields.values())
    if len(HANGUL_PATTERN.findall(guide_values)) < MIN_READER_GUIDE_HANGUL:
        errors.append(
            f"{relative}: 문서 안내의 설명을 충분한 한국어로 작성해야 합니다."
        )


def warn_heading_hierarchy(
    text: str,
    relative: Path,
    warnings: list[str],
) -> None:
    previous_level: int | None = None
    for match in re.finditer(r"^(#{1,6})\s+\S", text, re.MULTILINE):
        level = len(match.group(1))
        if previous_level is not None and level > previous_level + 1:
            warnings.append(
                f"{relative}:{line_number(text, match.start())}: "
                f"제목 계층이 H{previous_level}에서 H{level}(으)로 건너뜁니다."
            )
        previous_level = level


def warn_long_tables(
    text: str,
    relative: Path,
    warnings: list[str],
) -> None:
    lines = text.splitlines()
    start_line: int | None = None
    row_count = 0

    def flush() -> None:
        nonlocal start_line, row_count
        data_rows = max(0, row_count - 2)
        if start_line is not None and data_rows > MAX_TABLE_DATA_ROWS:
            warnings.append(
                f"{relative}:{start_line}: 표의 데이터 행이 {data_rows}개입니다. "
                "작업자가 비교하기 쉽도록 주제별 분할을 검토하세요."
            )
        start_line = None
        row_count = 0

    for index, line in enumerate(lines, start=1):
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|"):
            if start_line is None:
                start_line = index
            row_count += 1
        else:
            flush()
    flush()


def warn_readability(
    raw_text: str,
    analysis_text: str,
    relative: Path,
    warnings: list[str],
) -> None:
    warn_heading_hierarchy(analysis_text, relative, warnings)
    warn_long_tables(analysis_text, relative, warnings)

    if re.search(r"^```mermaid\s*$", raw_text, re.MULTILINE):
        has_explanation = re.search(
            r"^\s*(?:#{2,6}\s+)?(?:다이어그램 설명|범례)\s*:?",
            analysis_text,
            re.MULTILINE,
        )
        if not has_explanation:
            warnings.append(
                f"{relative}: Mermaid에 한국어 '다이어그램 설명' 또는 '범례'가 없습니다."
            )

    hangul_count = len(HANGUL_PATTERN.findall(analysis_text))
    ascii_count = len(ASCII_LETTER_PATTERN.findall(analysis_text))
    if ascii_count >= 200 and hangul_count * 20 < ascii_count:
        warnings.append(
            f"{relative}: 영어 비중이 높습니다. canonical term을 제외한 설명문이 "
            "한국어인지 검토하세요."
        )


def validate(root: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    definitions: dict[str, list[Location]] = defaultdict(list)
    references: dict[str, list[Location]] = defaultdict(list)
    core_docs_found: dict[Path, set[str]] = defaultdict(set)

    markdown_files = discover_markdown(root)
    if not markdown_files:
        return [f"{root}: Markdown 문서를 찾지 못했습니다."], []

    for path in markdown_files:
        text = path.read_text(encoding="utf-8")
        relative = path.relative_to(root)
        analysis_text = mask_fenced_code(mask_frontmatter(text))

        if path.name in CORE_DOCUMENT_TYPES:
            core_docs_found[path.parent].add(path.name)
            metadata = parse_frontmatter(text)
            if metadata is None:
                errors.append(f"{relative}: YAML frontmatter가 없습니다.")
            else:
                missing = sorted(REQUIRED_FRONTMATTER - metadata.keys())
                if missing:
                    errors.append(
                        f"{relative}: 필수 metadata 누락: {', '.join(missing)}"
                    )
                expected_type = CORE_DOCUMENT_TYPES[path.name]
                actual_type = metadata.get("document_type")
                if actual_type and actual_type != expected_type:
                    errors.append(
                        f"{relative}: document_type은 {expected_type!r}이어야 하나 "
                        f"{actual_type!r}입니다."
                    )
                document_language = metadata.get("document_language")
                if (
                    "document_language" in metadata
                    and document_language != EXPECTED_DOCUMENT_LANGUAGE
                ):
                    errors.append(
                        f"{relative}: document_language은 "
                        f"{EXPECTED_DOCUMENT_LANGUAGE!r}이어야 하나 "
                        f"{document_language!r}입니다."
                    )
                status = metadata.get("status")
                if status and status not in VALID_DOCUMENT_STATUSES:
                    errors.append(
                        f"{relative}: 알 수 없는 document status {status!r}"
                    )
                if status == "confirmed" and metadata.get("knowledge_owner") == "unknown":
                    warnings.append(
                        f"{relative}: confirmed 문서의 knowledge_owner가 unknown입니다."
                    )

            validate_reader_guide(analysis_text, relative, errors)

        definition_spans: set[tuple[int, int]] = set()
        for match in DEFINITION_PATTERN.finditer(analysis_text):
            identifier = match.group(1)
            definitions[identifier].append(
                Location(path, line_number(analysis_text, match.start(1)))
            )
            definition_spans.add(match.span(1))

        for match in ID_PATTERN.finditer(analysis_text):
            if match.span() in definition_spans:
                continue
            references[match.group(0)].append(
                Location(path, line_number(analysis_text, match.start()))
            )

        for marker in ("TODO", "TBD"):
            for match in re.finditer(rf"\b{marker}\b", analysis_text):
                warnings.append(
                    f"{relative}:{line_number(analysis_text, match.start())}: "
                    f"미해결 marker {marker}"
                )

        warn_readability(text, analysis_text, relative, warnings)

    for identifier, locations in sorted(definitions.items()):
        if len(locations) > 1:
            rendered = ", ".join(location.render(root) for location in locations)
            errors.append(f"{identifier}: canonical definition 중복: {rendered}")

    for identifier, locations in sorted(references.items()):
        if identifier not in definitions:
            first = locations[0].render(root)
            errors.append(
                f"{identifier}: canonical definition이 없습니다. 첫 참조: {first}"
            )

    for directory, found in sorted(core_docs_found.items()):
        missing_docs = sorted(set(CORE_DOCUMENT_TYPES) - found)
        if missing_docs:
            relative_dir = directory.relative_to(root)
            errors.append(
                f"{relative_dir}: 핵심 문서 누락: {', '.join(missing_docs)}"
            )

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "DDD Markdown의 metadata, 한국어 안내, 가독성, canonical ID와 "
            "핵심 문서 세트를 검사합니다."
        )
    )
    parser.add_argument("domain_docs_dir", type=Path)
    args = parser.parse_args()

    root = args.domain_docs_dir.resolve()
    if not root.is_dir():
        print(f"ERROR: 디렉터리가 아닙니다: {root}", file=sys.stderr)
        return 2

    errors, warnings = validate(root)

    for message in errors:
        print(f"ERROR: {message}")
    for message in warnings:
        print(f"WARNING: {message}")

    print(
        f"SUMMARY: errors={len(errors)} warnings={len(warnings)} "
        f"root={root}"
    )
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
