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
- [ ] **Phase 1**: Design System and Basic Calculator
- [ ] **Phase 2**: Scientific Calculator
- [ ] **Phase 3**: History and Session Persistence
- [ ] **Phase 4**: Math Notes
- [ ] **Phase 5**: PDF Sharing
- [ ] **Phase 6**: Currency Converter
- [ ] **Phase 7**: Hardening, Full Testing, and Release Readiness

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
