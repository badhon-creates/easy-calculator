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
- [x] **Phase 4**: Math Notes
- [x] **Phase 5**: PDF Sharing
- [ ] **Phase 6**: Currency Converter
- [ ] **Phase 7**: Hardening, Full Testing, and Release Readiness

## Architecture & Features

### PDF Sharing & Native Android Share Sheet (Phase 5)
- **High-Fidelity PDF Generation**: Pure Dart vector document generation (`pdf` package) creating fully selectable, paginated A4 documents preserving note titles, rich-text blocks (Title, Heading, Subheading, Body), inline styles (Bold, Italic, Underline), custom text colors, indented bullet lists, and freehand drawings.
- **True Vector Drawing Rendering**: Freehand strokes are scaled and mapped to PDF vector graphics paths (`pw.CustomPaint` / `PdfGraphics`), maintaining crispness and color accuracy at any zoom level without pixelation or rasterization.
- **Automatic Pagination**: Long notes seamlessly flow across multiple pages with standard margins (36 pt), running headers on continuation pages, and dynamic page numbering footers (`Page X of Y`).
- **Android Native Share Sheet**: Dispatches standard Android system share sheet (`share_plus`) via secure content URIs using Android's `FileProvider`, restricting access to narrowly scoped temporary read permissions without exposing raw filesystem paths.
- **Safe Temporary File Management**: Generates timestamped export files inside app cache (`math_notes_exports/`) with sanitized filenames, avoiding filename collisions or overwriting actively shared files, accompanied by automatic pruning of temporary exports older than 30 minutes.
- **Non-Destructive Export**: PDF generation operates on the active note snapshot, flushing in-progress edits while never modifying, duplicating, or corrupting the original stored Math Note.
- **User Feedback & Debouncing**: Responsive top-bar Share button with subtle loading spinner and tap debouncing to prevent accidental duplicate exports during generation.

### Math Notes (Phase 4)
- **Rich Text Editor**: Modular document blocks supporting Title, Heading, Subheading, and Body styling with inline formatting (Bold, Italic, Underline, and customizable text colors) via the `Aa` toolbar.
- **Smart Bullet Lists**: Dedicated bullet-list tool where pressing Enter on a populated bullet generates the next list item, and pressing Enter on an empty bullet cleanly exits the list.
- **Freehand Vector Drawing**: Integrated drawing canvas capturing vector stroke points, colors, and widths as structured data without corrupting or replacing typed text.
- **Indefinite Local Retention**: Saved notes persist indefinitely in app-private storage (`easy_calc_notes.json`) until explicitly deleted by the user. There is no automatic expiry.
- **Autosave & Session Recovery**: Continuous debounced autosave and lifecycle flushing (`easy_calc_note_session.json`) ensure unfinished drafts restore seamlessly across app backgrounding or termination without creating duplicate notes.
- **Note Management & Search**: Real-time search by title and content, date sorting, multi-note selection, and permanent deletion with confirmation dialogs.
- **Navigation Continuity**: Smooth transition between the Calculator and Math Notes with a dedicated return button preserving active calculator session state.

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
