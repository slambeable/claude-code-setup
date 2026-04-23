---
name: commit-message
description: Генерирует короткое осмысленное коммит-сообщение в формате Conventional Commits на основе git diff. Используй ВСЕГДА когда пользователь упоминает коммит, commit, закоммитить, зафиксировать изменения, git commit — даже если прямо не просит сгенерировать сообщение. Также используй, если пользователь готовит изменения к пушу.
allowed-tools: Bash, Read
---

# Commit message generator

> Этот файл — project skill для Claude Code. Лежит в `.claude/skills/commit-message/SKILL.md`
> и активируется автоматически: при старте сессии Claude Code сканирует `.claude/skills/` и
> грузит frontmatter всех `SKILL.md` в контекст. Дальше модель сама решает, когда его
> применить на основе поля `description`. Ручной вызов: `/commit-message`.

Задача — написать короткое, полезное коммит-сообщение в формате Conventional Commits.

## Процесс

1. Запусти `git diff --staged` (если пусто — `git diff`). Проанализируй изменения.
2. Определи тип коммита:
   - `feat:` — новая функциональность
   - `fix:` — исправление бага
   - `refactor:` — рефакторинг без изменения поведения
   - `perf:` — оптимизация производительности
   - `test:` — изменения в тестах
   - `docs:` — документация
   - `chore:` — служебные изменения (deps, config)
3. Определи scope (опционально): модуль или фича, которая затронута. Например `feat(auth):`, `fix(editor):`.
4. Напиши описание: **одна строка, до 72 символов, в императиве**. Пример: `add timeout handling` (не «added», не «adds»).
5. Если изменения нетривиальные — после пустой строки добавь тело: 1-3 предложения «зачем» (не «что» — это уже видно из диффа).

## Чего избегать

- «Fixed bug», «Updated code», «Various changes» — бесполезно
- Перечислять, что менял по файлам — это уже есть в диффе
- Хвастаться масштабом («massive refactor», «huge improvement»)
- Пустые коммиты с сообщением «wip»

## Формат ответа

Просто покажи предложенное сообщение в блоке кода. Не коммитить без подтверждения пользователя.

```
feat(editor): add pattern validation on export

Empty patterns silently produced broken level files.
Validation runs before Blob creation and shows confirm
dialog with affected pattern IDs.
```

После одобрения — выполни `git commit -m "..."` (или с `-F` для многострочного).
