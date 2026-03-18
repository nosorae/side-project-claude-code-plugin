# Git Flow

## 브랜치 전략

| 브랜치 | 용도 | 병합 대상 |
|--------|------|-----------|
| `main` | 프로덕션 배포 | — |
| `develop` | 개발 통합 | `main` |
| `feature/{이슈번호}-{설명}` | 기능 개발 | `develop` |
| `fix/{이슈번호}-{설명}` | 버그 수정 | `develop` |

## 규칙

- `main`은 direct push 금지. PR을 통해서만 병합
- `develop`은 작업 브랜치의 통합 지점
- 작업 시작 시 `develop`에서 브랜치를 생성한다
- 작업 완료 시 `develop`으로 PR을 생성한다
- `develop` → `main` 병합은 릴리스 시점에 수행한다

## 브랜치 이름 규칙

```
feature/42-add-login-screen
fix/57-crash-on-startup
```

- 이슈 번호를 접두사로 포함
- kebab-case 사용
- 간결하게 작업 내용을 설명

## 커밋 규칙

기존 커밋 메시지 규칙(`<Type>: <설명>`)을 따른다.
