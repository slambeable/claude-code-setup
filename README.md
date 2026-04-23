# Claude Code: стартовый сетап

Набор файлов-шаблонов для разработчиков, использующих Claude Code в проектах на **Vue 3 + Vite + TypeScript**.

Цель — сэкономить токены (читай: деньги и лимит), не ухудшив качество. Каждый файл в этом репо закрывает одну конкретную боль. Файлы, которых ты не понимаешь — не клади в проект.

## Что внутри

```
.
├── .claude/
│   ├── settings.json           # permissions.allow / permissions.ask / permissions.deny
│   ├── settings.md             # разбор правил в settings.json
│   ├── hooks/
│   │   └── bash-firewall.sh    # PreToolUse: блокировка опасных команд
│   └── skills/
│       └── commit-message/
│           └── SKILL.md        # пример skill — генерация коммитов
├── .claudeignore               # что агент не должен читать
├── .mcp.json                   # пустой шаблон для MCP-серверов
├── .mcp.examples.md            # примеры MCP и правила подключения
├── CLAUDE.md                   # минимальный шаблон под Vue+Vite+TS
├── CLAUDE.md.karpathy-style    # experimental: 4 правила из karpathy-skills
└── prompts/
    └── good-bad-examples.md    # примеры плохих и хороших промптов
```

## Как использовать

Возьмите необходимые файлы и положите в корень своего проекта — либо просто ориентируйтесь на них как на референс при настройке собственного сетапа.

Если хочется минимального старта — достаточно `CLAUDE.md` и `.claudeignore`. Остальное подключайте по мере необходимости.

`CLAUDE.md` содержит плейсхолдеры под конкретный проект — **вычитайте и адаптируйте перед использованием**, шаблон не работает сам по себе.

После изменений в `.claude/` перезапустите сессию Claude Code — они не подхватываются на лету.

## Про skills

Файлы в `.claude/skills/*/SKILL.md` — это project skills. Claude Code сканирует папку `.claude/skills/` при старте сессии, читает frontmatter каждого `SKILL.md` и дальше сам решает, когда применить тот или иной skill на основе поля `description` (или когда пользователь вызывает его вручную через `/skill-name`).

Чтобы skill триггерился надёжнее, его `description` обычно делают «pushy» — с явным перечислением триггер-слов, а не абстрактным «используй для X». Подробнее — в [официальной документации](https://code.claude.com/docs/en/skills).

## Про хуки

Хуки — shell-скрипты, которые Claude Code вызывает в определённых точках (перед tool call, после tool call и т.д.). В отличие от инструкций в `CLAUDE.md` (которые модель *может* проигнорировать), хук выполняется всегда — детерминированно.

### `bash-firewall.sh`

PreToolUse-hook для блокировки опасных команд. `exit 2` блокирует команду, `exit 1` предупреждает, `exit 0` пропускает.

Подключение в `settings.json`:

```json
{
  "permissions": { /* ... */ },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/bash-firewall.sh" }
        ]
      }
    ]
  }
}
```

После правки — перезапусти сессию, hooks не перезагружаются на лету.

### Hook или CLAUDE.md

Для защиты от `rm -rf` и подобного — hook: нельзя полагаться на то, что модель «поняла» запрет. Для поведенческих вещей («всегда запускай тесты с `--silent`») — хватит CLAUDE.md.

### Тестирование

Перед подключением в настройки проверь на безопасном окружении:

```bash
echo '{"tool_input":{"command":"rm -rf /"}}' | ./bash-firewall.sh
echo "exit: $?"
# ожидаем: BLOCKED + exit 2

echo '{"tool_input":{"command":"ls -la"}}' | ./bash-firewall.sh
echo "exit: $?"
# ожидаем: exit 0 без вывода
```

## Ссылки

- [Официальная документация Claude Code](https://code.claude.com/docs)
- [Prompt caching — как работает](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — курируемый список, куда идти за большим
