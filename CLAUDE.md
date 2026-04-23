# Проект: [НАЗВАНИЕ ПРОЕКТА]

> ⚠️ Перед использованием: замени плейсхолдеры в скобках и вычитай каждую строку.
> Всё, что не соответствует твоему проекту — удали. Общий объём — до 200 строк, иначе Claude начинает хуже слушаться.

## Stack

- Vue 3 (Composition API, `<script setup>`)
- Vite, TypeScript (strict mode)
- [Pinia / Vuex — выбери одно] для состояния
- [Vue Router / nuxt routing]
- [ESLint + Prettier / Biome]
- [Jest / Vitest] для тестов, [Playwright / Cypress] для e2e

## Команды

```bash
npm run dev      # локальный dev-сервер
npm run build    # production-сборка
npm run test     # unit-тесты
npm run test:e2e # e2e (поднимает dev-сервер)
npm run lint     # проверка ESLint + типов
npm run format   # автоформат через Prettier
```

## Структура

```
src/
├── components/    # переиспользуемые UI-компоненты (atomic)
├── views/         # страницы, подключённые к router
├── composables/   # useXxx — переиспользуемая логика
├── stores/        # pinia stores
├── api/           # обёртки над HTTP-клиентом, по одному файлу на ресурс
├── types/         # глобальные TypeScript-типы
└── utils/         # чистые функции без зависимостей от Vue
```

Новый функционал обычно живёт в связке `views/ + api/ + stores/ + types/`. Компоненты — только если реально переиспользуются.

## Конвенции

- Компоненты — только через `<script setup lang="ts">`. Никаких Options API.
- State — через Pinia. Не вводить Vuex, не смешивать.
- HTTP — только через `src/api/*`, компоненты не дергают fetch напрямую.
- Валидация входных данных — через [zod / valibot], не руками.
- Ошибки API — возвращаем `{ data, error }`, наверх не пробрасываем raw-исключения.
- Не использовать `any`. Если тип сложный — `unknown` + narrowing.
- Импорты — абсолютные, через алиас `@/` (настроен в `vite.config.ts`).

## Что НЕ трогать без обсуждения

- `src/config/` — продакшн-конфиги и ключи
- Папка `migrations/` (если подключена бэкенд-часть)
- `vite.config.ts`, `tsconfig.json` — только с ревью
- `package-lock.json` — не редактировать руками никогда

## Подводные камни

- Tests: Vitest использует jsdom, поэтому `window.matchMedia`, IntersectionObserver — моки уже в `src/test/setup.ts`.
- Strict TS: `noUnusedLocals`, `noUnusedParameters` включены — мёртвый код ломает билд.
- HMR ломается, если трогать `src/main.ts` — нужно перезапускать dev-сервер руками.

## Рабочий процесс

1. Запланируй изменение в Plan Mode (Shift+Tab дважды), особенно если задевает >3 файла.
2. Реализуй.
3. `npm run lint && npm run test` — перед коммитом обязательно.
4. Коммит-сообщение: короткая суть + зачем, не «fixes bug».
