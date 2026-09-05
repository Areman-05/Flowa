# Flowa

App fintech en **Flutter** (Android / iOS) pensada para **freelancers y autónomos en España**.

No es un clon de Revolut. El producto gira alrededor de una idea clara:

> **Lo que puedes gastar de verdad** — no el saldo del banco.

Demo de portfolio con datos mock locales (sin backend real).

## Tesis de producto

1. **Disponible de verdad** — Hero del Home: saldo usable tras impuestos y compromisos fijos.
2. **Bote Hacienda** — Reserva un % de cada cobro para el trimestre IVA.
3. **Facturas en el rail principal** — Emitir / seguir / cobrar, y al cobrar se alimenta el bote.
4. **Confirmación en pagos** — Send → revisar → éxito, sin sorpresas.
5. **Design system minimalista** — Canvas negro, un acento mint `#00E6A6`, tipografía Manrope, motion quieto.

## Navegación

| Tab | Rol |
| --- | --- |
| Inicio | Disponible de verdad, tarjetas, CTAs Enviar / Ingresar / Bote / Análisis |
| Facturas | Loop freelance |
| Movs | Historial |
| Más | Servicios, recompensas (secundario), soporte, ajustes |

## Tech stack

| Capa | Elección |
| --- | --- |
| Framework | Flutter / Dart |
| Plataformas | Android + iOS |
| Arquitectura | Feature-first + capas clean ligeras |
| Persistencia demo | SharedPreferences (auth/prefs) + repos in-memory |
| Calidad | Unit + widget tests |

## Estructura

```
lib/
  app/             # FlowaApp, MainShell
  core/            # Utils, sesión, validadores
  design_system/   # Colores, tipografía, componentes
  domain/          # Entidades (finance, freelance…)
  data/            # Repos mock / local
  features/        # home, invoices, vault, send, auth…
  shared/          # Navegación y widgets cruzados
```

## Cómo correr

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Nota de portfolio

Flowa es una **demo honesta**: saldo, movimientos, facturas y contactos viven en memoria de sesión. Auth y preferencias sí se guardan en el dispositivo. Sirve para enseñar craft de producto y UI fintech, no para operar dinero real.

## License

Proyecto privado de portfolio.
