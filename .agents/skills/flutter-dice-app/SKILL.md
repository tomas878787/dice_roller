---
name: flutter-dice-app
description: Use when implementing, reviewing, testing, or modifying this Flutter dice roller app, especially work involving the dice design document, Signals state, go_router navigation, probability mode, roll history, animation behavior, or Flutter tests.
---

# Flutter Dice App

## Overview

Use this skill to keep work on this project aligned with the product and technical design in `docs/flutter-dice-app-design.md`. Treat that design document as the source of truth for scope, architecture, behavior, edge cases, and acceptance criteria.

## Required Context

Before changing app behavior, read the relevant sections of `docs/flutter-dice-app-design.md`.

Use these search anchors when the task is narrow:

| Task | Read |
| --- | --- |
| Routing or pages | `信息架构与导航`, `页面设计`, `Widget 与路由测试` |
| Random result generation | `随机结果工具类`, `DiceResultGenerator 单元测试` |
| Shared state | `Signals 状态设计`, `DiceGameStore 单元测试` |
| Probability mode | `概率模式`, `错误和边界处理`, `验收标准` |
| Animation or roll transaction | `掷骰事务与动画`, `历史规则` |
| Layout or accessibility | `视觉与屏幕适配`, `无障碍与交互质量` |

## Project Rules

- Keep the first version offline and single-player. Do not add login, networking, analytics, persistence, sound, vibration, theme switching, statistics, or extra dice types unless the user explicitly asks.
- Keep random generation independent from UI, animation, and Signals state.
- Keep probability mode transparent: the UI and history must identify it and must not present it as fair random.
- Preserve the transaction model: generate one final result in `prepareRoll()`, show it only after animation or immediate commit, and add exactly one history record per successful roll.
- Reject invalid dice count, target face, and probability values. Do not silently coerce invalid domain input inside core logic.
- Keep history in memory only, newest first, capped at 20 records.
- Respect system text scaling and reduced motion.

## Expected Structure

Prefer the design document's structure unless the current codebase has already established an equivalent local pattern:

```text
lib/
├── app.dart
├── router/app_router.dart
├── state/dice_game_store.dart
├── models/dice_probability_config.dart
├── models/roll_record.dart
├── services/dice_result_generator.dart
├── screens/dice_screen.dart
├── screens/history_screen.dart
├── screens/settings_screen.dart
└── widgets/
    ├── dice_board.dart
    └── dice_face.dart
```

## Verification

For behavior changes, add or update focused tests from the design document's test plan. Before reporting completion, run the fastest relevant checks, typically:

- `flutter analyze`
- `flutter test`

If the change affects layout, also run representative widget tests or inspect the rendered app for small, phone, and wide layouts.
