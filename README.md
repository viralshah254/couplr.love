# Couplr

AI-powered relationship workspace for couples. Built with Flutter.

## Stack

- **Flutter** — UI
- **Riverpod** — State management
- **GoRouter** — Navigation
- **Clean architecture** — Feature-first modules under `lib/`

## Project structure

```
lib/
  app/           # App widget, bootstrap
  core/          # Env, analytics, logging, DI, localization
  features/       # Feature modules (home, auth, journal, …)
  shared/         # Reusable widgets, skeleton/empty/error states
  router/         # GoRouter config
  theme/          # Design tokens, light/dark theme
```

## Setup

1. **Flutter** — Install [Flutter](https://docs.flutter.dev/get-started/install).
2. **Env** — Optional: copy `assets/env/.env.example` to `assets/env/.env` and set values. The app uses `assets/env/default.env` if `.env` is missing.
3. **Run** — `flutter pub get` then `flutter run`.

## Master prompt

See **COUPLR_MASTER_PROMPT.md** for the full Cursor/master prompt and phased roadmap (splash, auth, partner linking, dashboard, Talk & Heal, journal, community, premium, tablet, insights, QA, store launch).

## Design

- Design tokens: `lib/theme/app_tokens.dart` (colors, typography, spacing, radii, elevation, motion).
- Light + dark theme: `lib/theme/app_theme.dart`.
- Visual language: soft gradients, rounded cards, serif headlines, calm palette, motion-first.

---

*Couplr is infrastructure for love. Build it calm. Build it safe. Build it beautiful.*
# couplr.love
