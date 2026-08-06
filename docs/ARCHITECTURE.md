# Flowa architecture

Feature-first layout with clean architecture layers inside each feature.

## Layers

| Path | Responsibility |
| --- | --- |
| `app/` | Root widget, theme wiring, navigation shell |
| `core/` | Cross-cutting constants, errors, utils, extensions |
| `design_system/` | Visual tokens and reusable branded components |
| `domain/` | Pure business entities and repository contracts |
| `data/` | Implementations, DTOs, local/remote sources |
| `features/` | Vertical slices (UI + feature domain/data as needed) |
| `shared/` | Widgets and helpers reused by multiple features |

## Feature module convention

```
features/<name>/
  presentation/   # pages, widgets, controllers
  domain/         # feature-specific entities/use-cases (optional)
  data/           # feature-specific sources (optional)
```

Keep presentation free of raw data-source details. Prefer depending on
domain contracts so tests stay fast and UI stays thin.
