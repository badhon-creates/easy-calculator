# Easy Calculator — Phase 8: Expand Convert into a Units Converter

## Project context

- **Project:** Easy Calculator
- **Phase:** 8 — Expand the existing Convert feature into a multi-category Units Converter
- **Reference:** The user will provide three iOS Calculator Units screenshots. Use them as visual references for category navigation and unit selection, adapted to Easy Calculator's established design.

## Objective

Expand **Calculator → top-right mode icon → Convert**. Currently, Convert opens the Currency Converter. Change it so Convert opens a **Units** screen with multiple conversion categories. Preserve and integrate the existing Phase 6 Currency Converter rather than replacing or reimplementing it unnecessarily.

First inspect the actual codebase, architecture, tests, and Git status. Make a focused plan before editing. Do not assume previous status reports prove the code is correct. Work in the existing project; do not create a separate app or duplicate the project.

## Navigation and behavior

1. From the calculator, open the existing top-right mode/menu icon.
2. Selecting **Convert** opens the new **Units** screen.
3. Show a horizontally scrollable category selector.
4. Selecting a category updates its available units and conversion interface.
5. Users can select source and destination units and enter an amount; the converted value updates immediately when the amount or units change.
6. Provide a clear way to swap source and destination units.
7. Provide a clear return path to the calculator using existing navigation and transition patterns.
8. Preserve relevant in-progress conversion state when navigating away and returning, without resetting unrelated calculator state.
9. Remember the selected category while navigating within the conversion interface. Persist across restarts only if consistent with the current architecture; avoid unnecessary complexity.
10. Keep transitions smooth and layouts responsive on small screens and with larger system font settings.

## Categories

Implement these 15 categories:

1. Angle
2. Area
3. Currency
4. Data
5. Energy
6. Force
7. Fuel
8. Length
9. Power
10. Pressure
11. Speed
12. Temperature
13. Time
14. Volume
15. Weight

The category selector must scroll horizontally and remain usable on narrow screens. The default category may be **Currency** to preserve the existing Convert workflow's intent, unless the current design provides a stronger reason to choose otherwise. Document the chosen default in the implementation report.

## Initial supported units

Use practical, commonly used units. Keep unit definitions extensible so adding units does not require duplicating UI or conversion algorithms.

- **Angle:** degree, radian, gradian.
- **Area:** square millimeter, square centimeter, square meter, square kilometer, square inch, square foot, square yard, acre, hectare.
- **Currency:** currencies supported by the existing Phase 6 exchange-rate provider, subject to its capabilities and API constraints.
- **Data:** bit, byte, kilobit, kilobyte, megabit, megabyte, gigabit, gigabyte, terabit, terabyte. Define whether decimal (SI) or binary (IEC) units are used. Prefer explicit labels/symbols such as kB versus KiB; do not ambiguously mix the systems.
- **Energy:** joule, kilojoule, calorie, kilocalorie, watt-hour, kilowatt-hour; electronvolt if straightforward.
- **Force:** newton, kilonewton, pound-force.
- **Fuel economy:** kilometers per liter, liters per 100 kilometers, miles per US gallon, miles per Imperial gallon. Reciprocal conversions need special handling; a single linear multiplier is insufficient.
- **Length:** millimeter, centimeter, meter, kilometer, inch, foot, yard, mile, nautical mile.
- **Power:** watt, kilowatt, megawatt, metric horsepower, mechanical horsepower.
- **Pressure:** pascal, kilopascal, bar, millibar, atmosphere, PSI, millimeters of mercury.
- **Speed:** meters per second, kilometers per hour, miles per hour, knot.
- **Temperature:** Celsius, Fahrenheit, Kelvin. Use correct offsets and scaling.
- **Time:** millisecond, second, minute, hour, day, week.
- **Volume:** milliliter, liter, cubic meter, US liquid gallon, Imperial gallon, US cup, tablespoon, teaspoon.
- **Weight/mass:** milligram, gram, kilogram, metric tonne, ounce, pound, stone.

These are initial targets. Verify conversion constants and unit definitions. Use sensible precision and add tests. Do not overengineer units that cannot be implemented and verified correctly.

## Conversion correctness

- Keep conversion logic separate from UI widgets and make it testable.
- Use clear unit metadata (category, name, symbol, and conversion behavior).
- Use accurate conversion factors relative to a common base unit for ordinary linear conversions.
- Handle temperature offsets/scaling correctly.
- Handle fuel economy's reciprocal conversions correctly, including US versus Imperial gallons.
- Handle currency through the existing exchange-rate service; it is not a static unit conversion.
- Avoid floating-point display artifacts; format results sensibly without hiding meaningful precision.
- Safely handle zero, negative values where meaningful, decimals, large/small values, invalid input, and non-finite results.
- Handle units for which negative values are invalid or nonsensical without crashing or silently returning misleading results.
- Never evaluate arbitrary code or pass raw user input into an unsafe evaluator.
- Keep conversion logic deterministic and unit-testable wherever live rates are not involved.

## Currency integration — preserve Phase 6

Inspect the current Currency Converter before editing. Reuse its existing exchange-rate provider, cache, supported-currency list, source/target selection logic, loading/error states, and disclaimer wherever possible.

Currency must retain:
- Live rates when available.
- Source and destination currency selection.
- Searchable selection if already present; otherwise add a practical searchable selector.
- Instant conversion as the amount changes.
- Currency swapping.
- Rate refresh.
- Clear live-versus-cached status and last-updated time.
- Offline and provider-error handling.
- The existing exchange-rate disclaimer.
- No fabricated exchange rates and no labeling cached rates as live.
- No private API keys hardcoded in source or embedded as secrets in the APK. Follow the existing security architecture.

Avoid unnecessary currency refactoring. If integration requires a refactor, keep it focused and test it.

## Unit-selection experience

Use the screenshots as references for:
- A centered **Units** title.
- A horizontally scrollable category row.
- Clear selected-category styling.
- A scrollable list with readable unit names and symbols.
- A visible selection indicator.
- Search to find units.
- A clear confirmation action where a selection flow requires it.

Adapt these ideas to Easy Calculator; do not copy iOS branding or use iOS-only controls. A reusable unit-picker sheet/page with search, names/symbols, selected-state indication, and a confirm/select action is recommended.

If the current converter already has source and target cards, retain and adapt them rather than replacing the whole screen solely to match the screenshots. Make source and destination selection intuitive.

## Visual design and accessibility

- Follow the existing Easy Calculator light/dark themes and centralized semantic colors.
- Do not scatter hardcoded colors or introduce a separate theme.
- Preserve the primary color **#64AFFA** and dark main/history background **#1F1C1C** where already used.
- Keep text, icons, selection states, and status labels readable in both themes.
- Use the existing custom squircle/super-rounded shape system for relevant controls where appropriate.
- Give category tabs, selectors, refresh, swap, search, and confirmation controls meaningful accessible labels and adequate touch targets.
- Do not use color as the only selection/status indicator.
- Handle font scaling, narrow screens, keyboard visibility, and safe areas.
- Match the app's existing spacing and typography.

## Architecture and scope

- Inspect current feature organization and state management first.
- Reuse shared widgets, theme tokens, navigation, storage, and animation patterns.
- Separate UI, conversion logic, unit definitions, and currency/network responsibilities.
- Avoid a giant screen file, duplicated formulas, needless abstractions, dead code, placeholders, and unrelated rewrites.
- Add dependencies only if necessary; prefer maintained compatible packages.
- Do not alter Basic/Scientific calculators, Math Notes, PDF sharing, history, autosave, or security except where integration requires it.
- Preserve local Git workflow. **Do not push to GitHub or any remote.**

## Tests and verification

Add or update automated tests.

### Unit tests
Cover:
- Representative conversions in every non-currency category.
- Round trips where mathematically appropriate.
- Temperature conversions in both directions, including negative and zero values.
- Fuel-economy conversions in both directions and US/Imperial gallon distinctions.
- Decimal versus binary data units.
- Formatting and rounding.
- Invalid inputs and non-finite results.
- Currency integration with controlled/fake rate data where practical; unit tests must not depend on live network access.

### Widget/integration checks
Verify:
- Convert opens Units.
- All 15 categories are present and selectable.
- Category selector scrolls on narrow screens.
- Unit selection, search, confirmation, and swapping work.
- Results update as the amount changes.
- Currency live/cached/error states remain accurate.
- Light and dark themes remain readable.
- Back navigation and return to calculator work.
- In-progress calculator state and existing features remain intact.
- No overflow or blocked controls on representative emulator sizes.

Run checks supported by the project: formatter, static analysis/linter, relevant unit/widget tests, full existing test suite, and debug/release builds if practical.

**Never claim a test, build, device check, or emulator check passed unless it was actually run and its result observed.** Clearly identify anything that remains unverified.

## Git requirements

- Inspect `git status` and current branch before editing.
- Preserve existing user changes; do not reset, discard, or overwrite unrelated work.
- Do not push to any remote.
- After implementation and successful verification, make a local commit with a clear message, for example:

  `feat(units): expand Convert to multi-category unit converter`

- Investigate and fix failures within scope. Do not claim completion merely because code was written.
- Report the actual commit hash and final working-tree status.

## Definition of done

Phase 8 is complete only when:
- Convert opens Units.
- All 15 categories are implemented and selectable.
- Supported units in every non-currency category convert accurately.
- Currency uses existing Phase 6 exchange-rate and cache logic.
- Unit selection, search, and source/target swapping work.
- Themes, navigation, and state preservation remain intact.
- Relevant tests, analysis, and build checks have actually run and their results are reported.
- No unrelated functionality has regressed.
- Limitations are explicitly documented.
- Changes are committed locally, and nothing is pushed remotely.

## Final implementation report

Provide a concise report covering:
1. What changed.
2. Categories and units implemented.
3. How Phase 6 Currency Converter was reused.
4. Files/components changed at a high level.
5. Tests, analysis, and builds actually run, with real pass/fail results.
6. Manual checks still needed.
7. Limitations or known issues.
8. Local commit hash and working-tree status.
9. Explicit confirmation that nothing was pushed to GitHub.

Do not start another phase without the user's instruction.
