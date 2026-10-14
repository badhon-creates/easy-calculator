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
- [x] **Phase 6**: Currency Converter
- [x] **Phase 7**: Security Hardening, Full Regression Testing, and Release Readiness

## Architecture & Features

### Currency Converter (Phase 6)
- **Live & Reference Rates Integration**: Communicates via HTTPS with the open Frankfurter reference rates service (`api.frankfurter.dev/v2`) providing global central-bank reference rates for 150+ world currencies without embedding confidential API keys or requiring user accounts.
- **Accurate Cross-Rate Calculation**: Automatically computes cross-currency conversions using reference base rates ($Rate(A \to B) = \frac{Rate(base \to B)}{Rate(base \to A)}$), enabling conversion between all supported pairs (including BDT, USD, EUR, GBP, INR, JPY, and more).
- **Searchable Currency Selection**: Modal bottom sheet with instant search filtering across 150+ currencies by ISO code, English name, and symbol, complete with country flag emojis and selection indicators.
- **Dedicated Calculator Keypad**: Custom responsive squircle keypad with large number keys, decimal point, clear, backspace, and quick double-zero (`00`) entry tailored for currency inputs without accidental mode conflicts.
- **Instant Swapping & Live Recalculation**: Prominent central swap button reversing source and target currencies with instantaneous recalculation.
- **Local-First Caching & Offline Resilience**: Caches successful currency directories and exchange rate snapshots in app-private storage (`currencies_cache.json`, `rates_cache.json`). When offline, gracefully falls back to cached data, clearly displaying a "Cached" badge and last-updated timestamp without fabricated numbers or app crashes.
- **Session Persistence**: Remembers the user's active source currency, target currency, and amount across app restarts via `currency_session.json`.
- **Honest Disclaimers & Rate Freshness**: Prominently labels rates as "Live" or "Cached" with official market publication dates, accompanied by an accessible disclaimer stating reference rates are for informational purposes only.

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

### Security Hardening & Release Readiness (Phase 7)
- **Expression Evaluation Safety**: Tokenizer and Shunting-Yard parser enforce strict bounds (maximum expression length of 1,000 characters and maximum parentheses nesting depth of 50) to prevent denial-of-service or stack overflow attacks.
- **Pure Lexical Analysis**: Never executes arbitrary Dart code, scripts, or runtime `eval()`. Mathematical expressions are parsed into an Abstract Syntax Tree (AST) / Reverse Polish Notation (RPN) and evaluated purely using typed numeric tokens.
- **Strict Mathematical Domain Guards**: Comprehensive guards prevent crashes on undefined domains ($x/0$, $\sqrt{-x}$, $\ln(0)$, $\ln(-x)$, $\sin^{-1}(|x| > 1)$, $\cosh^{-1}(x < 1)$, $\tan(90^\circ)$, etc.) and cap factorial operations at $170!$ to prevent IEEE 754 infinity overflow.
- **App-Private Storage Sandbox**: User notes, drawings, sessions, and calculation history reside exclusively within the application's private storage sandbox (`getApplicationDocumentsDirectory()` and `getApplicationSupportDirectory()`). No personal content is ever uploaded or synced to external servers.
- **Path Traversal & Export Sanitization**: Exported PDF filenames are strictly sanitized (`sanitizeNoteFilename`) by stripping path traversal components (`../`), special characters (`< > : " / \ | ? *`), and truncating long titles. Stale temporary export files (> 30 minutes old) are automatically pruned upon new exports.
- **Android Permissions & Network Security**: Only the standard `android.permission.INTERNET` permission is declared for the Frankfurter reference rates API. No dangerous runtime permissions (storage, camera, location, contacts) are requested. Network calls strictly enforce HTTPS with standard TLS certificate validation.
- **Release Verification & Tree-Shaking**: Release APK build verified (`flutter build apk --release`), confirming successful asset tree-shaking (99.6% reduction in font payload), R8 code shrinking, and absence of unresolved native dependencies.

## Development & Verification

### Prerequisites
- Flutter SDK 3.47+ & Dart SDK 3.13+
- Android SDK 36.0.0+ / Android Studio
- Android Emulator (e.g., Pixel 6 Pro / Pixel 7 running Android 14+)

### Verification Commands
```bash
# Get dependencies
flutter pub get

# Code formatting check
dart format --output=none --set-exit-if-changed .

# Static code analysis (zero warnings/errors)
flutter analyze

# Full automated regression & unit test suite (197 tests)
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK (signed with debug keys by default)
flutter build apk --release
```

## Release Signing Configuration

For official production distribution on the Google Play Store, configure release signing without committing credentials to Git:

1. Create a Java Keystore:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create an `android/key.properties` file (automatically ignored by `.gitignore`):
   ```properties
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Update `android/app/build.gradle.kts` release signing configuration to load `key.properties` if present.
4. Run:
   ```bash
   flutter build appbundle --release
   ```

## Privacy & Security Considerations

- **Zero Telemetry or Analytics**: Easy Calculator does not contain tracking scripts, third-party analytics, advertisements, or user telemetry.
- **Offline First**: Calculator, Scientific functions, History, and Math Notes function 100% offline. Currency Converter features automatic local caching and offline fallback.
- **Open Reference Rates**: Exchange rates are sourced from the public Frankfurter service (ECB reference rates). No user identifiers, device metadata, or query payloads are transmitted.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
