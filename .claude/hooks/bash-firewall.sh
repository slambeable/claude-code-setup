#!/usr/bin/env bash
# bash-firewall.sh — PreToolUse-hook для защиты от опасных команд.
#
# Назначение: Claude Code передаёт на stdin JSON с описанием запрошенной
# команды. Скрипт парсит команду и возвращает exit code:
#   0 — пропустить
#   1 — выполнить, но с предупреждением
#   2 — полностью заблокировать
#
# Это второй рубеж поверх settings.json — на случай, если команда
# сформулирована так, что не попала в deny-список (например, через sh -c).
#
# ⚠️ Перед использованием: протестируй на своих командах.
# Запуск: bash-firewall.sh работает через PreToolUse-matcher в settings.json.
# См. документацию Claude Code hooks.

set -euo pipefail

# Прочитать команду из stdin (JSON)
INPUT=$(cat)

# Извлечь непосредственно команду (grep+sed, без зависимости от jq)
CMD=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')

if [ -z "$CMD" ]; then
    # Не смогли распарсить — пропускаем, чтобы не блокировать работу
    exit 0
fi

# Паттерны, которые блокируем полностью
DENY_PATTERNS=(
    'rm[[:space:]]+-[rf]+[[:space:]]+/'
    'rm[[:space:]]+-[rf]+[[:space:]]+\*'
    'rm[[:space:]]+-[rf]+[[:space:]]+\.'
    'git[[:space:]]+push[[:space:]]+.*--force'
    'git[[:space:]]+push[[:space:]]+.*-f([[:space:]]|$)'
    'git[[:space:]]+reset[[:space:]]+--hard'
    'DROP[[:space:]]+TABLE'
    'DROP[[:space:]]+DATABASE'
    'TRUNCATE[[:space:]]'
    'curl[[:space:]]+.*\|[[:space:]]*(bash|sh)'
    'wget[[:space:]]+.*\|[[:space:]]*(bash|sh)'
    'chmod[[:space:]]+777'
    ':\(\)\{.*\}'
)

for pattern in "${DENY_PATTERNS[@]}"; do
    if echo "$CMD" | grep -qE "$pattern"; then
        echo "❌ BLOCKED: команда соответствует запрещённому паттерну: $pattern" >&2
        echo "   Команда: $CMD" >&2
        exit 2
    fi
done

# Паттерны, на которые предупреждаем (но пропускаем)
WARN_PATTERNS=(
    'sudo[[:space:]]'
    'npm[[:space:]]+publish'
    'pip[[:space:]]+install'
    '>[[:space:]]*/etc/'
)

for pattern in "${WARN_PATTERNS[@]}"; do
    if echo "$CMD" | grep -qE "$pattern"; then
        echo "⚠️ WARN: потенциально опасная команда — пропускаю, но проверьте: $CMD" >&2
        exit 1
    fi
done

# Всё ок
exit 0
