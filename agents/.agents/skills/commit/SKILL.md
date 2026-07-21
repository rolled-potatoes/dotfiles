---
name: commit
description: git commit, 커밋, 현재 변경 사항을 작업 단위별로 정리해 commit을 만든다. Use when the user explicitly asks to commit changes.
disable-model-invocation: true
---

# 커밋 가이드

## 규칙

커밋 메세지는 다음 형식을 따른다.

### subject

`{prefix}: {title}`

prefix는 아래를 사용한다.
- feat: 기능 개발/변경
- fix: 동작 수정
- chore: 빌드, 패키지 설치, CI/CD 등 인프라 변경
- docs: 문서 업데이트

title은 80자 이내로 현재 작업의 목적과 결과를 요약한다.
한글로 작성하며, 어떤 것을 위한 작업인지 명확히 한다. 예를 들어, "사용자 검증을 위한 세션미들웨어 추가"와 같이 작성한다.


### body

필요하면 작업 요약을 적는다. 생략 가능하다.

## 커밋 절차

1. 현재 브랜치의 히스토리를 확인한다.
2. 변경 사항을 파악한다.
3. 연관 있는 변경만 묶어서 stage 한다.
4. 필요하면 lint/format/test를 확인한다.
5. 위 규칙에 맞는 commit을 작성한다.

## 주의

- 테스트가 실패하면 원인을 먼저 파악한다.
- 타입 에러를 `any`, `unknown`, `as`로 숨기지 않는다.
- 커밋 범위가 애매하면 먼저 묻는다.
