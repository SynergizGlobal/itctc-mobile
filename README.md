# ITCTC Forms — NHSRCL Field Inspection

Flutter mobile application (Android & iOS) for NHSRCL field inspection form data entry.

## Features

- **Home** — Search and browse available inspection forms
- **Stepper forms** — Guided vertical data entry per form row
- **Auto-calculations** — Computed values (X, A, B, C, irregularity) saved on submit, not shown in UI
- **Theme** — Light / Dark / System with Plus Jakarta Sans typography
- **Global error handling** — Custom dialog with retry support

## Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/           → Theme, network, errors, routing, shared widgets
├── data/           → Form repository
└── features/
    ├── home/       → Form catalog and search
    └── forms/      → C-1, C-7, T-2 form screens
```

## Forms

| Form | Description |
|------|-------------|
| C-1 | Formation width measurement |
| C-7 | Noise barrier height measurement |
| T-2 | Track irregularity measurement |

Calculated fields are computed server-side on submit. The UI collects only raw measured values and standard values per the original form tables.
