# Easy Calculator

Easy Calculator is a polished, modern Android calculator application built with Flutter and Dart.

## Overview

The application features four core modes:
1. **Basic**: Fast, reliable daily arithmetic with smooth expression-to-result transitions.
2. **Scientific**: Advanced mathematics including trigonometry, hyperbolic functions, memory operations, degree/radian angle modes, powers, roots, and constants.
3. **Math Notes**: A local-first rich note-taking environment supporting formatted text, bullet lists, freehand vector drawings, and high-fidelity PDF sharing.
4. **Convert**: Currency conversion powered by live exchange rates with local caching and offline support.

## Design Identity

- **Primary Brand Color**: `#64AFFA`
- **Dark Theme Background**: `#1F1C1C`
- **Light Theme Background**: `#FFFFFF`
- **Button Geometry**: Super-rounded squircle / superellipse styling.
- **Theme Support**: Seamless, automatic adaptation to Android system light and dark themes.

## Technology Stack

- **Platform**: Android
- **Framework**: Flutter (Channel Stable) & Dart
- **Application ID**: `com.easycalculator.app`
- **State Management**: `flutter_bloc` / `Cubit`
- **Local Persistence**: SQLite via `sqflite` (local-first, app-private storage)
- **Currency Data**: Public exchange rate API (HTTPS, no embedded client secrets)
- **Target Repository**: `easy-calculator`
- **License**: MIT License

## Project Status

- [x] **Phase 0**: Project Foundation and Verification
- [x] **Phase 1**: Design System and Basic Calculator
- [x] **Phase 2**: Scientific Calculator
- [x] **Phase 3**: History and Session Persistence
- [ ] **Phase 4**: Math Notes
- [ ] **Phase 5**: PDF Sharing
- [ ] **Phase 6**: Currency Converter
- [ ] **Phase 7**: Hardening, Full Testing, and Release Readiness

## Architecture & Features

### History & Session Persistence (Phase 3)
- **Calculation History**: Automatically captures completed calculations from both Basic and Scientific modes upon pressing `=`. Unfinished expressions and state-restorations are strictly ignored to prevent duplicate entries.
- **7-Calendar-Day Expiry**: Strict local calendar-day retention policy (current calendar day plus six preceding calendar days). Evaluated against local device midnight boundaries (`startOfToday - 6 days`), ensuring calculations do not prematurely expire based on rolling 168-hour intervals or app restart timing.
- **Session Autosave & Resumption**: Autosaves uncompleted expressions, computed results, evaluation status, active mode, angle mode (`Deg`/`Rad`), secondary function toggles, and memory registers to app-private storage (`easy_calc_session.json`). Flushes instantly on calculation, mode switch, and Android app lifecycle background/pause events.
- **Local-First App Storage**: Uses crash-resilient atomic file writes (`.tmp` write followed by atomic rename) inside Android app-private storage (`getApplicationDocumentsDirectory()`), maintaining total user privacy without external network transmission.
- **History UI**: High-contrast, clean design system integration (#FFFFFF Light, #1F1C1C Dark) featuring relative timestamp formatting, tap-to-reuse expression/result continuation, individual entry deletion, and a clear-all confirmation dialog.

## Development & Verification

### Prerequisites
- Flutter SDK 3.47+ & Dart SDK 3.13+
- Android SDK 36.0.0+ / Android Studio
- Android Emulator (e.g., Pixel 7)

### Verification Commands
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
