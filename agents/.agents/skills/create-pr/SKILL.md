---
name: create-pr
description: PR 제목·본문 초안 작성이나 PR용 변경 요약을 요청할 때 사용한다. publish-changes의 PR 문안 작성 단계에서도 이 규칙을 사용한다.
---

When writing a PR description:

단독 문안 요청은 초안 작성에서 마친다. 실제 PR 생성 요청은 [publish-changes](../publish-changes/SKILL.md)가 담당한다.

1. 대상 base와 작업 브랜치의 분기점부터 HEAD까지 변경을 확인한다. 커밋 전에 초안을 검토할 때는 이번에 포함할 로컬 변경도 함께 본다.
2. Write a description following this format:

## PR Template 

github PR 템플릿이 작업 디렉토리에 있는지 확인한다. 
만약 템플릿이 있다면 템플릿 섹션을 준수하여 내용을 작성한다.

### Default PR Template

만약 템플릿이 없다면 아래 형식을 사용하여 내용을 작성한다.

```md
## 작업 요약 

## 문제 정의 

## 작업 내용

## 영향 및 주의 사항

```


## Title

PR 전체 변경을 요약하는 제목을 작성한다.
작성 템플릿: `{prefix}: {title}`
한글로 작성한다.

prefix는 아래를 사용한다.
- feat: 기능 개발/변경
- fix: 동작 수정
- chore: 빌드, 패키지 설치, CI/CD 등 인프라 변경

## Description

PR 전체 변경을 한글로 설명한다.

- 어떤 문제를 해결하기 위한 작업인지 배경/목적을 작성한다.
- 문제를 해결하기 위해서 어떤 작업을 했는지 작성한다.
- 변경된 사항이 어떤 영향을 미치는지 작성한다.
- 코드리뷰어가 주의 깊게 살펴봐야 하는 부분이 있다면 작성한다.

