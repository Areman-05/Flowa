# Flowa

Premium fintech finance app built with **Flutter** for Android and iOS.

Flowa focuses on **clarity, control, and confidence** when managing money —
personal, family, and business flows in one place.

## Product pillars

- Clear money flows (Send ≠ Top-Up ≠ Receive)
- Customizable sub-accounts (Family / Business)
- Granular notification preferences
- AI assistant for guided actions
- External wallet linking (e.g. PayPal)
- Confirmation steps that prevent costly mistakes

## Tech stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter / Dart |
| Platforms | Android + iOS |
| Architecture | Feature-first + clean layers |
| Quality | Unit, widget, and flow tests |
| Performance | Lean rebuilds, efficient lists |

## Project structure

```
lib/
  app/           # App widget, theme, routing
  core/          # Constants, errors, utils, extensions
  design_system/ # Colors, typography, spacing, components
  domain/        # Entities and business rules
  data/          # Repositories and data sources
  features/      # Feature modules (home, send, ai, ...)
  shared/        # Cross-feature widgets and helpers
```

## Getting started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## License

Private portfolio project.
