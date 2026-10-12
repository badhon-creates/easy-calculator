# Easy Calculator --- Product Requirements Document (PRD)

**Document status:** Implementation specification\
**Product:** Easy Calculator\
**Platform:** Android, with Flutter/Dart as the proposed implementation
stack\
**Primary development workflow:** Antigravity for AI-assisted
implementation and code review; Android Studio for Android
SDK/emulator/build/debugging\
**Repository target:** `easy-calculator`\
**Version:** 1.0 draft for implementation\
**Audience:** Product owner, implementation agent, developer, tester,
and future GitHub reviewers

------------------------------------------------------------------------

## 1. Product Summary

Easy Calculator is a polished Android calculator app with four main
modes:

1.  **Basic** --- everyday arithmetic.
2.  **Scientific** --- advanced mathematical functions.
3.  **Math Notes** --- persistent rich-text notes with bullets and
    freehand drawings, plus PDF sharing.
4.  **Convert** --- currency conversion using exchange-rate data from a
    network provider.

The app should feel fast, cohesive, intuitive, and carefully finished.
Mode changes, calculator layout changes, expression/result transitions,
and navigation should use smooth, purposeful animations without delaying
input or causing layout jumps.

The app is intended to be a credible public GitHub showcase. It must
therefore be built as a maintainable, tested, documented codebase---not
as a single large generated file or a superficial prototype.

## 2. Product Goals

-   Provide reliable everyday and scientific calculations.
-   Offer a distinct, consistent visual identity using the approved blue
    calculator icon and `#64AFFA` primary color.
-   Make light/dark appearance follow the Android system setting.
-   Preserve in-progress calculator work and Math Notes editing across
    interruptions and process/device restarts where practical.
-   Keep history and notes on the device; do not require an account or
    cloud database.
-   Let users create formatted notes, draw in them, and share faithful
    PDF exports through Android's standard share sheet.
-   Provide useful currency conversion with clear rate freshness,
    caching, offline/error states, and manual refresh.
-   Meet practical consumer-app security and privacy expectations.
-   Maintain professional code quality, automated tests, documentation,
    and a reproducible build.

## 3. Non-Goals for V1

Unless separately approved, V1 will not include: - User accounts,
sign-in, cloud synchronization, or a remote user database. - A backend
solely for storing notes/history. - Math Notes equation solving,
automatic calculations, variable evaluation, graphing, handwriting
recognition, or AI math assistance. - A promise that exchange rates
equal the final rate offered by a bank, card network, money-transfer
service, or cash-exchange counter. - Unnecessary permissions, analytics,
advertising SDKs, or background tracking. - A guarantee of absolute
security. Security controls must be appropriate, implemented, and
tested, while residual risk is acknowledged. - An iOS release. Android
is the target platform for this project.

## 4. Users and Core Use Cases

### 4.1 Basic calculator user

A user opens the app, enters an expression, sees a live expression
display, taps equals, and sees the result. The user may continue from
the result or start a new calculation.

### 4.2 Scientific calculator user

A user switches to Scientific, uses functions such as powers, roots,
logarithms, trigonometry, constants, factorial, memory, and angle-unit
selection, then switches back to Basic without unnecessary loss of work.

### 4.3 Math Notes user

A user creates a note, types and formats content, adds bullets or a
drawing, leaves the app, and returns later to find the in-progress edit
restored. The user can search, sort, select, delete, and share notes as
PDFs.

### 4.4 Currency conversion user

A user selects source and target currencies, enters an amount, sees a
converted amount and rate, swaps currencies, refreshes rates, and
understands whether the displayed rate is current or cached.

## 5. Product Principles

-   **Correctness before decoration:** mathematical and conversion
    results must be correct and predictable.
-   **Smooth, not slow:** animations must not block input or make the
    interface feel sluggish.
-   **Preserve work:** autosave unfinished work frequently and restore
    it safely.
-   **Honest status:** never label cached rates as live; communicate
    errors without exposing technical internals.
-   **Local-first:** notes, history, and calculator session state stay
    on the device unless the user explicitly shares/export content.
-   **Maintainability:** separate UI, calculation logic, persistence,
    and network concerns.
-   **Verify rather than assume:** a feature is not complete until it
    has been tested in the emulator and relevant automated tests pass.

------------------------------------------------------------------------

## 6. Platform, Framework, and Development Workflow

### 6.1 Proposed stack

-   Flutter and Dart for the application UI and cross-feature
    application code.
-   Android platform project generated and maintained by Flutter.
-   Android Studio for Android SDK management, emulator use,
    Gradle/build diagnostics, Logcat, and device testing.
-   Antigravity for assisted planning, coding, inspection, and iterative
    changes.
-   Git from the beginning of development; public GitHub publication
    after review and release preparation.

If the existing project setup materially differs, inspect it before
changing frameworks or replacing files. Do not silently create a second
project or maintain separate copies. Antigravity and Android Studio must
operate on the same `easy_calculator` project directory.

### 6.2 Development loop

Implement in small, reviewable stages: 1. Inspect project state and
environment. 2. Confirm a clear feature plan and acceptance criteria. 3.
Implement one coherent feature slice. 4. Format and run static analysis.
5. Run relevant unit/widget/integration tests. 6. Build and launch in an
Android emulator. 7. Inspect behavior, logs, accessibility, and layout.
8. Fix regressions before moving forward. 9. Commit a coherent, working
change with a meaningful message.

Do not generate the entire application in one enormous step. Do not
claim that a build, test, or security check passed unless it was
actually run and its result inspected.

------------------------------------------------------------------------

## 7. Information Architecture and Navigation

### 7.1 Main modes

The app has four selectable modes, in this order: 1. Basic 2. Scientific
3. Math Notes 4. Convert

A calculator/mode icon at the top-right opens a menu containing these
choices. Mode changes should animate smoothly.

### 7.2 Navigation behavior

-   Basic is the initial mode on a fresh install.
-   Scientific expands the calculator interface to expose scientific
    controls.
-   Returning from Scientific to Basic smoothly collapses the extra
    controls and preserves the current calculation whenever sensible.
-   Math Notes opens the notes list as a screen/view. A calculator icon
    at the top-right of the notes list returns to the calculator.
-   Convert opens the currency converter with a smooth transition.
-   Back navigation should be predictable and should not silently
    discard work.
-   Mode selection and current calculator state should be persisted for
    restoration.
-   Avoid animation conflicts with keyboard input, accessibility
    services, and rapid repeated taps.

### 7.3 Motion requirements

Use consistent, purposeful transitions for: - Opening/closing the mode
menu. - Switching between calculator modes. - Expanding/collapsing
scientific controls. - Expression-to-result display changes. -
Opening/closing Math Notes list/editor. - Showing/hiding toolbars or
color choices. - Switching currencies or refreshing conversion data
where visual feedback helps.

Animations should be short, interruptible, and non-blocking. Respect
Android reduced-motion/accessibility settings where practical. Do not
animate every small element gratuitously.

------------------------------------------------------------------------

## 8. Visual Identity and Design System

### 8.1 Approved logo

Use the user-provided approved blue calculator logo as the app icon and
visual reference. The approved concept is a vivid blue rounded-square
icon with a minimalist white calculator, dark navy display "0", and
white keys with blue arithmetic symbols.

**Mandatory instruction:** Use the attached approved logo asset supplied
with this PRD. Do not substitute a different icon/logo, redesign it, or
generate a replacement without explicit permission. If the logo file is
missing, ask for it rather than guessing.

### 8.2 Primary color

-   Primary blue: **`#64AFFA`**
-   The same primary blue is used in both light and dark themes.

Centralize design tokens in a theme/color layer (for example,
`app_colors.dart` and `app_theme.dart`). Do not scatter hard-coded
colors across feature widgets.

### 8.3 Light theme

-   Main screen and history background: white `#FFFFFF`.
-   Primary/operator/action buttons: blue `#64AFFA`.
-   Text/icons on blue primary buttons: black `#000000`.
-   Number/input buttons: white `#FFFFFF` with black labels/icons.
-   Main expression/result text: black.
-   History icon, text, and related icons: black.
-   Use clear boundaries between white buttons and the white background
    through spacing, shape, subtle outlines, or other restrained design
    treatment, without changing the required base colors.

### 8.4 Dark theme

-   Main calculator and history background: **`#1F1C1C`**.
-   Primary/operator/action buttons: blue `#64AFFA`.
-   Text/icons on primary buttons: white `#FFFFFF`.
-   Number/input buttons: dark gray, similar to the supplied iOS
    reference, but not pure black; white labels/icons.
-   Expression/result text: white.
-   History icon and text: white.
-   Muted secondary expression text: a legible gray appropriate to the
    dark background.

### 8.5 System theme

Follow the Android system light/dark setting automatically. A manual
theme toggle is not required for V1. Theme changes should not erase or
reset any user state.

### 8.6 Button geometry

Use a **super-rounded rectangle / squircle-like** shape across
calculator-related buttons in Basic, Scientific, and other calculator
keypad layouts: - Corners should be very large and smoothly curved. -
The central horizontal and vertical edges should remain relatively
straight. - Do not use circular buttons. - Do not use sharp-cornered
rectangles. - Do not settle for an ordinary moderate-radius rounded
rectangle if it does not match the approved reference. - Prefer a custom
squircle/superellipse-like shape or a suitable implementation that
achieves the reference geometry consistently. - Reuse the same shape
system across calculator modes; sizes and spacing may vary where needed.

### 8.7 Layout, responsiveness, and accessibility

-   Adapt to common Android phone screen sizes, display densities,
    portrait/landscape layouts where supported, and system font scaling.
-   Avoid keypad overlap with expression/result text, system bars,
    keyboard, or accessibility controls.
-   Long expressions and large results must remain readable; use a
    carefully designed scaling/wrapping/scrolling strategy.
-   Touch targets should be comfortable and consistent.
-   Provide semantic labels for icon-only buttons, sensible focus order,
    and adequate contrast.
-   Do not rely on color alone to communicate error, selected state, or
    rate freshness.

------------------------------------------------------------------------

## 9. Basic Calculator Requirements

### 9.1 Layout

-   History/clock icon at the top-left.
-   Calculator/mode icon at the top-right.
-   Expression/result display above the keypad.
-   Numeric and action keypad below.
-   Match the agreed design system and squircle-like button shape.

### 9.2 Input and operations

Support ordinary arithmetic: - Addition `+` - Subtraction `−` -
Multiplication `×` - Division `÷` - Decimal point - Sign change `±`
where applicable - Percentage `%` - Clear/all-clear behavior -
Backspace/delete - Equals `=` - Parentheses if the selected layout
exposes them or if shared expression entry supports them.

The exact visible key arrangement should follow the supplied design
references and be finalized during implementation, but no required
operation may be omitted merely because the layout is convenient.

### 9.3 Expression and result display

Before equals: - Show the current expression in large, clearly readable
text. - Keep the display right-aligned as in the reference.

After equals: - Animate the completed expression upward. - Reduce its
size and render it in a muted secondary color. - Show the result beneath
it in large, high-contrast text. - Keep the transition smooth and avoid
moving or covering the keypad.

The same concept must work in both themes, with suitable contrast.

### 9.4 Post-result behavior

-   Tapping a digit after a completed result starts a new calculation.
-   Tapping an operator after a completed result continues from the
    result. Example: after `43 + 43 = 86`, tapping `+` should begin
    `86 +`.
-   Backspace, clear, percentage, sign change, repeated equals, and
    operator replacement should follow predictable calculator
    conventions.
-   Do not silently change a completed result or expression in
    surprising ways.

### 9.5 Mathematical correctness

Use a proper expression parser/evaluator or a carefully tested
calculation engine. Do not evaluate user-entered expressions by
executing arbitrary Dart code or using unsafe dynamic evaluation.

Define and test: - Operator precedence and associativity. - Unary minus
and negative values. - Decimal handling and rounding/display rules. -
Repeated equals behavior, if supported. - Percentage semantics and
context. - Division by zero and invalid operations. - Very long
expressions and large/small magnitudes. - Invalid input, incomplete
expressions, and repeated decimal points. - Floating-point precision and
display formatting.

Avoid displaying misleading floating-point artifacts where practical.
Preserve enough precision internally for follow-up calculations; format
only for display unless the calculation model explicitly requires
otherwise.

### 9.6 Error states

Errors such as division by zero, invalid expression, or overflow must be
handled gracefully. Do not crash, freeze, or expose stack traces to the
user. Show a restrained user-facing error/invalid state and let the user
recover by editing or clearing.

------------------------------------------------------------------------

## 10. Scientific Calculator Requirements

### 10.1 Mode behavior

-   Scientific mode expands the calculator to show scientific controls.
-   Returning to Basic smoothly collapses those controls.
-   Preserve the current expression/result and other state whenever
    sensible.
-   Ensure the expanded layout remains usable on smaller screens; use
    responsive layout or scrolling rather than clipping controls.

### 10.2 Required functions and keys

Include the following scientific functions and controls: - Parentheses
`( )` - Memory: `mc`, `m+`, `m−`, `mr` - `2nd` - `x²`, `x³`, `xʸ` -
`eˣ`, `10ˣ` - `1/x` - `²√x`, `³√x`, `ʸ√x` - `ln`, `log₁₀` - `x!` -
`sin`, `cos`, `tan` - Constant `e` - `EE` scientific-notation exponent
entry - `Rand` - `sinh`, `cosh`, `tanh` - Constant `π` - Angle unit
selector: `Deg` / `Rad`

### 10.3 Scientific behavior

-   Implement correct mathematical behavior, domains, precedence, and
    error handling.
-   `Deg` and `Rad` must affect trigonometric functions and their
    inverse counterparts.
-   `2nd` must expose the intended secondary/inverse functions with a
    clear visual selected state. Final key mapping should be documented
    in the UI/implementation notes and tested.
-   `EE` must create a scientific-notation exponent entry, not behave
    like ordinary multiplication.
-   Memory actions must work predictably: clear memory, add current
    value, subtract current value, and recall memory.
-   `Rand` should produce a value in a documented range (normally
    `[0, 1)`) and should not crash or hang.
-   Factorial must validate its input and domain; define support for
    non-negative integers and handle unsupported inputs safely.
-   Roots, logarithms, powers, inverse functions, and trigonometric
    functions must handle invalid domains and overflow gracefully.
-   Display `π` and `e` as constants with adequate internal precision.
-   Maintain consistent expression parsing and formatting between Basic
    and Scientific.

### 10.4 Scientific styling

Dark mode: - Background `#1F1C1C`. - Scientific and numeric keys: dark
gray, white labels. - Operators: `#64AFFA`, white labels.

Light mode: - White background. - Scientific and numeric keys: white,
black labels. - Operators: `#64AFFA`, black labels.

Use the same super-rounded/squircle-like button geometry as Basic.

------------------------------------------------------------------------

## 11. Calculation History

### 11.1 Access and content

-   Open history using the clock/history icon at the top-left of the
    calculator.
-   Store completed calculations locally on the device.
-   Each entry should contain at least the expression, result, and
    timestamp.
-   Keep history entries separate from the current unfinished calculator
    session.
-   An unfinished expression must not be recorded as a completed
    calculation.

### 11.2 Retention

**Retention policy: seven calendar days**, meaning the current calendar
day plus the preceding six calendar days in the device's local
calendar/time context. Remove entries older than this window
automatically. This is not a rolling 168-hour timer and must not delete
the entire history every seven days.

Run expiry cleanup on relevant app launches/history access and at other
sensible points. Handle date/time changes and timezone changes
predictably, documenting the chosen policy.

### 11.3 Theme and interaction

-   Dark mode: background `#1F1C1C`, white text/icons.
-   Light mode: white background, black text/icons.
-   History items should be readable, consistently spaced, and
    selectable/tappable if reopening or reusing a calculation is
    supported.
-   Any entry reuse behavior must be clear and tested.
-   If history is empty, show a useful empty state.
-   Storage failures should not crash the app; show a restrained error
    and preserve the active calculation.

------------------------------------------------------------------------

## 12. Calculator Session Autosave and Restoration

### 12.1 Core requirement

Persist in-progress calculator state locally and restore it when the
user returns, including after: - Switching to another app. - Locking the
device. - Leaving the app for hours or longer. - Android terminating the
app process. - Device restart, where practical.

### 12.2 State to preserve

At minimum: - Current expression/input buffer. - Current result and
whether equals has been pressed. - Selected mode (Basic or Scientific,
and other mode/navigation state where appropriate). - Angle unit
(`Deg`/`Rad`). - Memory value and relevant memory state. - Other state
needed to continue the same calculation predictably.

### 12.3 Behavior and implementation

-   Save frequently during input, with debouncing or another approach
    that avoids excessive disk writes without risking user work.
-   Restore promptly without intrusive loading.
-   Do not create duplicate history entries on restoration.
-   Do not turn an unfinished expression into a completed calculation.
-   Make persistence robust against malformed or partially written
    state.
-   Keep storage and restoration code outside UI widgets where
    practical.
-   If state cannot be restored, recover safely to a valid default state
    and avoid crashing.

------------------------------------------------------------------------

## 13. Math Notes

### 13.1 Scope

Math Notes is a rich note-taking feature. It does **not** evaluate
mathematical expressions in V1. It is not an equation solver or graphing
calculator.

### 13.2 Notes list

-   Accessible through the mode menu.
-   Search bar at the top of the screen.
-   New-note/pencil icon beside the search bar at the top.
-   Calculator icon at the top-right returns to the calculator.
-   Three-dot menu on the notes list includes:
    -   Sort by date/time.
    -   Select notes.
    -   Permanently delete selected notes.
-   "Select all" may be included if it improves the interaction, but is
    not mandatory.
-   Search should cover note title and body text.
-   Provide useful empty states for no notes and no search results.
-   Sort order should be explicit and consistent; newest
    modified/created first is a sensible default unless the
    implementation reference indicates otherwise.

### 13.3 Note editor

-   Opens as a dedicated editor with smooth transitions.
-   Top-right controls: calculator/return icon, Undo, and Share.
-   **Do not put a three-dot menu in the editor.**
-   Standard Android keyboard supports text entry.
-   Preserve editing state, selection/cursor position where practical,
    formatting, and drawing state during interruption/restoration.
-   Undo should reverse recent text and drawing edits where feasible.
-   Redo is optional, not required by the approved scope.
-   Autosave during editing; leaving the editor should not require the
    user to press Save.

### 13.4 Formatting toolbar

The bottom toolbar includes: - `Aa` formatting menu: - Text color. -
Title. - Heading. - Subheading. - Body. - Bold. - Italic. - Underline. -
Bullet tool: - Enter on a populated bullet starts the next bullet. -
Enter on an empty bullet exits bullet mode. - Bullet state and list
structure persist after reopening. - Pencil/drawing tool: - Enables
freehand drawing. - Shows pencil color selection when drawing mode is
selected. - Preserve drawing strokes and chosen colors. - **No
attachment icon** is to be included.

### 13.5 Rich content model and persistence

Notes must not be stored as plain text only. The data model should
preserve: - Text content. - Title/heading/body styles. - Bold, italic,
and underline spans. - Text colors. - Bullets and paragraph/list
structure. - Drawing strokes, stroke colors, and enough coordinate/size
information to render drawings consistently. - Created/modified
timestamps and stable note IDs. - Any other structural information
required to reconstruct the note accurately.

Use a maintainable, versionable local data format or storage model.
Include migration/version handling where reasonable. Test
serialization/deserialization of formatted text and drawings. Avoid
losing formatting when autosaving or updating a note.

### 13.6 Note retention and deletion

-   Saved Math Notes persist until the user deletes them.
-   No automatic expiry.
-   Deletion must be intentional and clear; use confirmation for
    permanent multi-note deletion.
-   After deletion, remove the relevant persisted content and associated
    drawing data. Do not accidentally recreate deleted notes during
    session restoration.
-   Handle storage errors gracefully.

### 13.7 Autosave and restoration

-   Persist edits while the user works.
-   If Android kills the app or the device restarts, restore the active
    note and its unsaved edits where practical.
-   Restore text, formatting, bullets, drawings, color choices, and
    cursor/selection position where practical.
-   Do not create a duplicate note just because the user resumed an
    existing editing session.
-   A saved note remains available until deleted, independently of the
    calculator-history retention policy.

------------------------------------------------------------------------

## 14. Math Notes PDF Sharing

### 14.1 User flow

-   The Share icon in the note editor generates a PDF representation of
    the current note, including the latest autosaved/current content.
-   Open Android's standard share sheet so the user can choose
    compatible installed apps.
-   Do not promise a specific destination app will always appear;
    available targets depend on the device and installed apps.

### 14.2 PDF fidelity

Preserve as faithfully as practical: - Title, headings, body text, font
emphasis, and text colors. - Bold, italic, and underline. - Bullet/list
structure and indentation. - Drawings and their colors. - Paragraph
spacing and overall layout.

Long notes must paginate correctly. Do not silently truncate content,
clip drawings, overlap paragraphs, or lose formatting at page
boundaries.

### 14.3 Secure sharing and temporary files

-   Use Android's secure content-URI/file-sharing mechanism, such as
    FileProvider or an equivalent supported implementation.
-   Grant temporary read access only as required for the share
    operation.
-   Do not expose unrestricted filesystem paths.
-   Generate a temporary PDF for sharing; do not retain a permanent
    exported copy unless the user explicitly chooses a save/export flow.
-   Clean up temporary files safely without deleting them before the
    receiving app has had a reasonable opportunity to read them.
-   Test sharing to multiple compatible targets and test
    large/multi-page notes.

------------------------------------------------------------------------

## 15. Currency Converter

### 15.1 Entry and layout

-   Access via the mode menu → Convert.
-   Smoothly transition into the converter.
-   Provide source and target currency selectors.
-   Use a searchable currency picker if practical.
-   Provide an amount-entry keypad.
-   Display the converted result and exchange rate.
-   Provide a swap control to reverse source and target currencies.
-   Allow manual rate refresh.
-   Show when the rate was last updated.

### 15.2 Conversion behavior

-   The converted result should update as the amount changes when a
    valid rate is available.
-   Changing either currency updates the displayed conversion and rate.
-   Swapping currencies should swap source and target and
    refresh/recalculate consistently.
-   Validate amounts and rate values; prevent invalid or non-finite
    outputs.
-   Apply sensible currency-specific display precision while retaining
    appropriate internal precision.
-   Clearly label source/target currency codes and avoid ambiguous
    symbols where different currencies share symbols.

### 15.3 Rate provider and network requirements

-   Choose an appropriate exchange-rate provider during implementation
    after checking current availability, terms, supported currencies,
    reliability, limits, and whether a secret API key is required.
-   Prefer a provider that can be called safely without embedding a
    confidential secret in the APK. If a confidential key is required,
    use a properly secured server-side component or choose another
    provider; do not pretend a build-time variable makes an embedded key
    secret.
-   Use HTTPS and normal platform TLS validation.
-   Validate response structure, timestamp, currency codes, and numeric
    rate values.
-   Use timeouts, bounded retries where sensible, and clear error
    handling.
-   Cache the last-known valid rates locally for temporary
    offline/network failures.
-   Clearly label cached data as cached/stale and show its update time;
    never represent stale data as live.
-   Provide manual refresh and a visible loading/error state.
-   Avoid excessive requests, uncontrolled refresh loops, or needless
    background network activity.
-   Make the provider replaceable behind a service/repository boundary
    to avoid tying UI code to a specific vendor.
-   Respect provider licensing/attribution and usage limits.
-   Explain that indicative market/reference rates may differ from rates
    charged by banks, cards, remittance providers, or exchange counters.

### 15.4 Offline and failure behavior

-   If no network is available but cached rates exist, permit conversion
    using cached rates and label them clearly.
-   If no valid rate is available, do not show a fabricated conversion;
    explain that rates cannot currently be loaded.
-   A failed refresh must not erase a previously valid cache.
-   Do not crash on timeouts, malformed JSON, unsupported currencies, or
    provider outages.

------------------------------------------------------------------------

## 16. Local Data and Persistence Design

-   No account or cloud database is required for V1.
-   Store history, notes, calculator session state, and currency-rate
    cache locally.
-   Prefer app-private storage and a maintained persistence approach
    suitable for structured, versioned data.
-   Choose the exact storage technology based on the data model and
    package maintenance/security review; document the choice and
    trade-offs.
-   Separate persistence interfaces from UI code.
-   Use stable IDs and timestamps where appropriate.
-   Handle schema changes/migrations and corrupted records gracefully.
-   Ensure deleting a note removes its saved content and associated
    drawing data.
-   Define retention separately:
    -   History: current calendar day plus previous six calendar days.
    -   Saved notes: until user deletion.
    -   Calculator session: retain the latest in-progress state for
        restoration.
    -   Exchange rates: cache according to a documented freshness
        policy; stale values must be labeled.
-   Do not log note text, expressions, user content, or API secrets
    unnecessarily.

------------------------------------------------------------------------

## 17. Security, Privacy, and Release Hardening

Security must use practical defense in depth. It reduces risk but cannot
guarantee absolute security.

### 17.1 Secrets and configuration

-   Never hardcode private API credentials in Dart, Android source,
    resources, build scripts, sample configuration, or committed files.
-   Never commit real secrets to GitHub.
-   Understand that `.env` files and build-time variables do not keep a
    secret confidential if the value is packaged in the APK.
-   If a confidential credential is required, use a server-side
    component or select a provider that does not require a confidential
    client secret.
-   Keep safe examples in configuration templates and exclude local
    secret files from version control.
-   Scan Git history and release artifacts for accidental credentials
    before publication.

### 17.2 Permissions and privacy

-   Request only permissions required by actual features.
-   Internet access may be needed for exchange rates; avoid unrelated
    permissions such as contacts, location, microphone, or camera unless
    a separately approved feature genuinely requires them.
-   Keep notes/history/session data in app-private storage.
-   Do not add analytics, advertising, or third-party crash-reporting
    SDKs without explicit review.
-   Do not log secrets, tokens, full note contents, or unnecessarily
    detailed user calculations.
-   Explain network use and any relevant data handling in the
    README/privacy documentation.

### 17.3 Input and computation safety

-   Use a controlled math parser/evaluator, not arbitrary code
    execution.
-   Validate expression length/complexity and all function domains.
-   Protect against malformed input, huge values, non-finite values,
    invalid exponents, invalid factorials, invalid logs/roots, and
    malformed network responses.
-   Avoid crashes, hangs, or unbounded resource use from pathological
    input.

### 17.4 Network and dependencies

-   Use HTTPS only for exchange-rate requests.
-   Keep normal TLS certificate validation enabled.
-   Validate network responses and fail safely.
-   Do not add certificate pinning by default; evaluate it only if
    justified and supportable over time.
-   Use reputable, maintained dependencies, minimize package count,
    review licenses and known vulnerabilities, and update dependencies
    deliberately.
-   Do not use obsolete or abandoned packages without a documented
    reason.

### 17.5 PDF sharing

-   Share PDFs through controlled content URIs with scoped grants.
-   Do not expose unrestricted local file paths or broad storage access.
-   Clean up temporary files safely.

### 17.6 Release checks

Before public release: - Scan source and Git history for secrets. -
Review Android permissions and manifest configuration. - Review
network/TLS behavior and currency provider terms. - Review local
storage, deletion, and restoration behavior. - Review logs for sensitive
data. - Review dependency health/licenses. - Verify release build
configuration and ensure debug-only functionality is not shipped
unintentionally. - Test input validation, PDF sharing, offline behavior,
and data retention. - Document any known limitations rather than
claiming perfect security.

------------------------------------------------------------------------

## 18. Architecture and Code Quality

### 18.1 Organization

Use a feature-oriented structure that reflects actual responsibilities.
A possible starting point is:

``` text
easy_calculator/
├── android/
├── assets/
│   └── branding/
├── lib/
│   ├── app/
│   ├── core/
│   │   ├── theme/
│   │   ├── storage/
│   │   ├── errors/
│   │   └── utils/
│   ├── shared/
│   │   ├── widgets/
│   │   └── animations/
│   ├── features/
│   │   ├── calculator/
│   │   ├── scientific/
│   │   ├── history/
│   │   ├── math_notes/
│   │   └── currency_converter/
│   └── main.dart
├── test/
├── integration_test/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

This is a guide, not a mandate to create empty folders. Adapt to the
actual project and avoid overengineering.

### 18.2 Separation of responsibilities

-   UI widgets should present state and forward user actions.
-   Calculator expression parsing/evaluation should be independent of
    UI.
-   Scientific functions and formatting rules should be testable without
    launching the app.
-   History, notes, session state, and exchange-rate data should use
    clear persistence/service boundaries.
-   PDF rendering/sharing should be isolated from note-editor
    presentation.
-   Network provider logic must not be embedded in UI widgets.
-   Theme tokens, button shapes, and reusable components should be
    centralized where that reduces duplication.

### 18.3 Quality requirements

-   Consistent naming, formatting, and linting.
-   Small, focused files and understandable functions.
-   Reusable components where repetition genuinely exists.
-   Clear state management appropriate to the app's complexity.
-   Meaningful errors and user recovery paths.
-   No unexplained hacks, fake data in production paths, placeholder
    functionality marked complete, dead code, giant widgets/files, or
    unnecessary abstractions.
-   Comments should explain non-obvious reasoning, not restate every
    line.
-   Do not suppress lint warnings globally just to get a green build.
-   Review AI-generated code critically and simplify or refactor it as
    needed.
-   Keep dependencies and generated files under control.
-   Make the project understandable to an external GitHub reviewer.

------------------------------------------------------------------------

## 19. Testing and Acceptance Criteria

A feature is not complete just because it compiles. Use automated tests
plus manual emulator/device checks.

### 19.1 Calculator unit tests

Test: - Basic arithmetic, precedence, associativity, unary minus,
decimals, parentheses. - Percentage and sign-change semantics. -
Backspace, clear, result continuation, and new-digit-after-result
behavior. - Division by zero and invalid expressions. - Floating-point
display/precision cases. - Scientific powers, roots, logarithms,
factorial, trigonometric/hyperbolic functions, constants,
inverse/secondary functions, `Deg`/`Rad`, `EE`, `Rand`, and memory. -
Large/small numbers and non-finite results. - Error recovery without
crashing.

### 19.2 History tests

-   Completed calculations are recorded with expression, result, and
    timestamp.
-   Unfinished/restored expressions are not recorded as completed
    entries.
-   Entries are retained for the correct seven-calendar-day window.
-   Expired entries are removed without wiping valid entries.
-   Theme and empty states render correctly.
-   Persistence failure does not destroy the active calculation.

### 19.3 Restoration tests

-   Enter an unfinished expression, background the app, and return.
-   Force-stop/terminate and reopen the app.
-   Restart the emulator/device where practical and reopen.
-   Confirm mode, expression, result state, angle unit, and memory
    restore.
-   Confirm restoration does not create duplicate history records.
-   Test corrupt/missing persisted state and safe recovery.

### 19.4 Math Notes tests

-   Create, edit, search, sort, and delete notes.
-   Test title/body search and empty search results.
-   Test title, heading, subheading, body, bold, italic, underline, and
    text colors.
-   Test bullet continuation and exiting on an empty bullet.
-   Test drawing, color selection, persistence, and reopening.
-   Test undo for supported edit types.
-   Kill/restart the app while editing and confirm the active edit is
    restored without duplication.
-   Confirm saved notes do not expire automatically.
-   Confirm deleting notes removes their persisted content.

### 19.5 PDF sharing tests

-   Confirm text, formatting, colors, bullets, and drawings appear in
    the PDF.
-   Confirm long notes paginate correctly and are not truncated.
-   Confirm share sheet opens and a compatible target can read the PDF.
-   Confirm content URI permissions are scoped correctly.
-   Confirm temporary-file cleanup does not happen too early.

### 19.6 Currency tests

-   Validate amount conversion and source/target changes.
-   Test currency swapping.
-   Test successful refresh, loading state, timeout, offline mode,
    malformed response, unsupported currency, and provider failure.
-   Confirm cached rates are labeled with their last update time.
-   Confirm failed refresh does not erase a valid cached rate.
-   Confirm no fabricated conversion is shown when no valid rate exists.
-   Verify API credentials are not embedded in the app.

### 19.7 UI, accessibility, and quality checks

-   Test both system light and dark modes.
-   Test Basic/Scientific transitions and mode switching during/after
    calculations.
-   Test smaller and larger phone sizes, text scaling, and landscape if
    supported.
-   Verify squircle shape and colors against the approved reference.
-   Verify animations do not block input or cause overlaps.
-   Check semantics/labels and touch targets.
-   Run formatter, static analysis/lints, unit tests, widget tests,
    integration tests as applicable, and a release build.
-   Review runtime logs and resolve unexpected errors/warnings.

### 19.8 Definition of Done

A feature is done only when: - Requirements and edge cases are
implemented. - Relevant automated tests pass. - Static
analysis/formatting checks pass. - It has been run and visually checked
in the emulator. - Errors and empty/offline states have been reviewed. -
No known regression remains unaddressed. - Documentation is updated when
behavior or setup changes. - The implementation is reviewed for
maintainability and security. - Any limitation that remains is
explicitly documented.

------------------------------------------------------------------------

## 20. GitHub and Documentation Requirements

### 20.1 Repository hygiene

-   Initialize Git early and make small, meaningful commits.
-   Use a clear repository name such as `easy-calculator`.
-   Maintain a useful `.gitignore` for Flutter/Android build artifacts,
    local IDE state, and secrets.
-   Never commit API secrets, signing keys, local machine paths,
    generated build outputs that do not belong in source control, or
    private user data.
-   Do not rewrite project history carelessly once shared publicly.

### 20.2 README

The README should include: - Product summary and feature list. -
Screenshots or a short demo once stable. - Tech stack and architecture
overview. - Prerequisites and exact setup/build/run instructions. - Test
and static-analysis commands. - Explanation of local storage, history
retention, notes persistence, and currency-rate behavior. -
Network/provider attribution and limitations. - Permissions/privacy
notes. - Known limitations. - License and contribution guidance if
applicable.

### 20.3 Additional documentation

-   Keep a meaningful `CHANGELOG.md`.
-   Include an appropriate open-source `LICENSE`; confirm the owner's
    choice before publishing because the license affects reuse rights.
-   Document calculation semantics and any non-obvious scientific
    behavior.
-   Document data schema/versioning and exchange-rate freshness policy
    where useful.
-   Provide a clear setup path that works on a clean development
    machine.

### 20.4 Public release standard

Do not publish the repository as a finished showcase until: - Core
features work and have been tested. - A clean build succeeds. - Tests
and static analysis have been run. - Screenshots accurately represent
the shipped app. - Secrets and permissions have been reviewed. -
README/setup instructions are verified. - License choice is resolved. -
Known issues and limitations are disclosed.

------------------------------------------------------------------------

## 21. Suggested Implementation Phases

### Phase 0 --- Inspect and prepare

-   Inspect the existing environment/project and confirm Flutter/Android
    tooling.
-   Create or verify the single `easy_calculator` project directory.
-   Add approved logo asset once provided.
-   Initialize Git and baseline Flutter project.
-   Configure linting, theme tokens, app shell, and initial tests.
-   Confirm a clean emulator build before feature work.

### Phase 1 --- Design system and Basic calculator

-   Implement light/dark themes, color tokens, squircle buttons, shared
    keypad components, responsive layout, and animations.
-   Implement parser/evaluator and Basic calculator state behavior.
-   Add unit tests for arithmetic and input handling.
-   Verify on emulator before proceeding.

### Phase 2 --- Scientific calculator

-   Add scientific controls, advanced math engine support, angle units,
    memory, secondary functions, and scientific notation.
-   Add broad unit/domain/error tests.
-   Verify responsive layout and mode transitions.

### Phase 3 --- History and session persistence

-   Implement local history, seven-calendar-day retention, and cleanup.
-   Implement calculator autosave/restoration.
-   Test process death and restoration without duplicate history
    entries.

### Phase 4 --- Math Notes

-   Implement notes list/search/sort/select/delete.
-   Implement rich text formatting, bullets, drawings, undo, and
    autosave.
-   Implement robust persistence and active-edit restoration.
-   Test schema round-trips and deletion.

### Phase 5 --- PDF sharing

-   Implement faithful PDF rendering, multi-page handling, secure
    Android share flow, and temporary-file cleanup.
-   Test large notes and multiple receiving apps.

### Phase 6 --- Currency converter

-   Select and document provider.
-   Implement searchable currency selection, conversion, swap, rate
    freshness, cache, refresh, and offline/error states.
-   Test network failure and key/secret handling.

### Phase 7 --- Quality and release preparation

-   Run full tests, static analysis, release build,
    responsive/accessibility review, and security checks.
-   Resolve defects and update docs.
-   Add verified screenshots/demo, license, changelog, and GitHub-ready
    README.
-   Publish only after the owner approves the final repository and
    release.

The phases may be adjusted based on technical findings, but avoid
starting multiple complex features before the core architecture and
persistence approach are stable.

------------------------------------------------------------------------

## 22. Implementation Decisions That Must Be Explicitly Resolved

Use sound defaults and document the choice. Ask the product owner only
when the choice changes product behavior, creates cost/legal
obligations, or cannot be safely inferred.

1.  **Exchange-rate provider:** select after checking current API terms,
    coverage, reliability, attribution, rate limits, and credential
    requirements.
2.  **Local persistence technology:** select a maintained approach
    appropriate for structured rich notes, drawings, session state, and
    history; explain why.
3.  **Scientific `2nd` mappings:** define and test the secondary/inverse
    functions.
4.  **Percentage semantics and repeated equals:** choose predictable
    conventions and document them.
5.  **History timezone/date-boundary behavior:** implement the
    seven-calendar-day rule using a consistent documented
    interpretation.
6.  **Currency rate freshness threshold:** set a sensible documented
    threshold based on provider update cadence; label older cached data
    clearly.
7.  **License:** obtain owner approval before choosing a public
    repository license.
8.  **Exact keypad spacing and dimensions:** match the attached design
    references while validating usability across Android screens.
9.  **Logo asset availability:** use the approved logo image supplied
    with the PRD; request it if not attached.

Do not block progress over cosmetic choices that can be safely refined
in emulator review. Do not silently change approved requirements.

------------------------------------------------------------------------

## 23. Instructions to Antigravity

Treat this PRD and the separately attached approved logo image as the
authoritative product requirements.

1.  **Inspect before editing.** Review the project files and current
    build setup before making changes. Do not overwrite unrelated work
    or create duplicate projects.
2.  **Use the attached approved logo.** Do not replace or redesign it
    without permission.
3.  **Plan in small phases.** Present a concise implementation plan and
    then work in reviewable feature slices. Do not generate the entire
    app in one massive pass.
4.  **Respect all explicit requirements.** In particular: `#64AFFA`,
    automatic system theme, dark background `#1F1C1C`, squircle-like
    buttons, four modes, seven-calendar-day history, persistent Math
    Notes, calculator/Math Notes restoration, and PDF sharing.
5.  **Build a real calculation engine.** Do not use unsafe dynamic code
    execution or fake scientific results.
6.  **Keep data local by default.** Only currency-rate requests need
    network access in V1; no accounts/cloud sync.
7.  **Handle failures honestly.** No fabricated exchange rates, fake
    "live" labels for cached data, swallowed errors, or false claims
    that tests passed.
8.  **Protect secrets and data.** Do not hardcode or commit private
    credentials, add unnecessary permissions, or log note content.
9.  **Write tests as features are built.** Run formatter, static
    analysis, relevant tests, and emulator checks regularly.
10. **Maintain professional code quality.** Use clear architecture and
    names, small focused files, meaningful abstractions, and
    documentation. Refactor AI-generated code where necessary.
11. **Preserve user work.** Autosave and restore in-progress state;
    avoid duplicates and avoid turning unfinished calculations into
    history entries.
12. **Keep a progress log.** After each phase, report what was
    implemented, files/areas changed, commands/tests actually run,
    results, known issues, and the next step.
13. **Do not claim completion prematurely.** Mark a feature complete
    only when its acceptance criteria have been verified.
14. **Do not publish to GitHub automatically.** Prepare the repository
    for review; wait for explicit approval before public publication.
15. **Escalate only meaningful ambiguities.** Use the defaults in this
    PRD where safe; ask before changing approved product decisions,
    incurring costs, choosing a license, or introducing a
    confidential-key backend.

------------------------------------------------------------------------

## 24. Final Product Acceptance Checklist

Before calling V1 complete, verify all of the following:

-   [ ] Approved logo is used as the app icon.
-   [ ] Basic calculator is correct and predictable.
-   [ ] Scientific calculator functions and edge cases are tested.
-   [ ] Basic/Scientific and all mode transitions are smooth and
    responsive.
-   [ ] Required colors and system-following light/dark themes are
    correct.
-   [ ] Calculator buttons use the intended squircle/super-rounded
    rectangle geometry.
-   [ ] History is local and expires according to the seven-calendar-day
    policy.
-   [ ] In-progress calculator state restores without creating false
    history.
-   [ ] Math Notes support rich formatting, bullets, drawing, undo,
    search, sorting, selection, and deletion.
-   [ ] Math Notes persist until deleted and active edits restore
    without duplication.
-   [ ] PDF exports preserve formatting/drawings, paginate long notes,
    and use secure sharing.
-   [ ] Currency conversion supports selection, amount entry, swapping,
    refresh, cache, offline handling, and rate freshness labels.
-   [ ] No confidential API secret is embedded in the APK or committed
    to GitHub.
-   [ ] Permissions, local storage, logs, dependencies, and release
    configuration have been reviewed.
-   [ ] Automated tests and static analysis pass, and a release build
    succeeds.
-   [ ] README, changelog, setup instructions, screenshots, known
    limitations, and license are ready.
-   [ ] Remaining known issues are documented.
-   [ ] Public GitHub publication occurs only after explicit owner
    approval.

**End of PRD**
