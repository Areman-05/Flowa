# Flowa architecture

Feature-first layout with clean architecture layers inside each feature.
Portfolio demo: local/mock data only — no real backend.

## Product pillars (UI discourse)

1. **Truly available** — spendable after tax vault + commitments (`home`, `card_wallet_store`, `freelance_entities`)
2. **Tax vault / Hacienda** — % of income reserved (`vault`, register last step)
3. **Por cobrar** — primary nav loop: client owes you → collect → reserve
4. **Design system** — ink + mint `#00E6A6` + Manrope (`design_system/`)
5. **Send confirmation** — Send → Review → Success

Primary shell tabs: Inicio | Por cobrar | Movs | Más. Rewards is under Más, not primary nav.

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
