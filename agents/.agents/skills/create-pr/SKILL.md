---
name: create-pr
description: Writes pull request descriptions. Use when creating a PR, writing a PR, or when the user asks to summarize changes for a pull request.
---

When writing a PR description:

1. 현재 작업 브랜치에서 HEAD 까지 변경된 사항을 확인한다.
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

현재 작업 브랜치에서 HEAD 까지 변경된 사항을 요약하는 제목을 작성한다.
작성 템플릿: `{prefix}: {title}`

prefix는 아래를 사용한다.
- feat: 기능 개발/변경
- fix: 동작 수정
- chore: 빌드, 패키지 설치, CI/CD 등 인프라 변경

## Description

현재 작업 브랜치에서 HEAD 까지 변경된 사항을 요약하는 설명을 작성한다. 

- 어떤 문제를 해결하기 위한 작업인지 배경/목적을 작성한다.
- 문제를 해결하기 위해서 어떤 작업을 했는지 작성한다.
- 변경된 사항이 어떤 영향을 미치는지 작성한다.
- 코드리뷰어가 주의 깊게 살펴봐야 하는 부분이 있다면 작성한다.

