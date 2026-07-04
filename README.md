# QuietCal

A minimalist iOS calorie tracking app built with SwiftUI and SwiftData.

## Overview

QuietCal helps you log meals and track daily calorie intake against a target.
The home screen shows a progress ring with today's totals, a stat strip, and a
list of meals. Tap the FAB to add a meal — calories are estimated from name and
grams using a calorie estimator service.

## Features

- Daily calorie ring with target / remaining / over indicators
- Add meals with name, weight (g/oz), and estimated kcal
- **Log meals hands-free with Siri** — say one natural phrase and the meal is
  estimated and logged in the background (see [Siri & Shortcuts](#siri--shortcuts))
- Swipe-to-delete meal rows
- History view with daily totals chart
- Adjustable calorie target
- Light / dark / system theme
- Weight unit preference (grams or ounces)
- CSV export/import for meal data

## Tech Stack

- **UI**: SwiftUI
- **Persistence**: SwiftData (meals), UserDefaults (settings)
- **Charts**: Swift Charts
- **Calorie estimation**: pluggable `CalorieEstimating` protocol with stub and
  Apple Intelligence implementations, backed by the
  [CalorieEstimator](https://github.com/mfsaglam/CalorieEstimator) package
  (1.2.0+, on-device via FoundationModels, incl. natural-language phrase parsing)
- **Siri**: App Intents framework (`LogMealIntent`, `TodaysCaloriesIntent`)
  exposed as App Shortcuts
- **Testing**: Swift Testing framework

## Project Structure

```
QuietCal/
├── App/             # App entry point and root view
├── AddMeal/         # Add meal screen + view model
├── Home/            # Home screen + view model
├── History/         # History screen + view model
├── Settings/        # Settings screens + view model
├── Components/      # Reusable UI components
├── Intents/         # App Intents + App Shortcuts (Siri / Shortcuts / Spotlight)
├── Models/          # Domain models (Meal, DayTotal, Theme, etc.)
├── Services/        # Calorie estimator implementations + phrase parsing
└── Stores/          # Persistence abstractions (meals & settings)

QuietCalTests/       # Unit tests (Swift Testing)
quiet-kcal/          # Original design handoff bundle (HTML/CSS prototypes)
```

## Architecture

MVVM with protocol-driven stores and services for testability:

- Views are thin SwiftUI structs that observe view models
- View models hold state and orchestrate stores/services
- `MealStore` and `SettingsStore` protocols have in-memory and persistent
  implementations — in-memory variants are used in previews and tests
- `CalorieEstimating` abstracts calorie estimation so different backends can be
  swapped in (stub, Apple Intelligence, etc.)

## Siri & Shortcuts

QuietCal exposes its actions to Siri, Spotlight, and the Shortcuts app via the
App Intents framework. The design goal is minimum-friction logging: the user
says a single natural phrase and everything — food, amount, unit — is inferred.

### Intents

- **Log a Meal** (`LogMealIntent`) — takes one free-text phrase, estimates the
  calories, and saves the meal in the background (the app doesn't open).
- **Today's Calories** (`TodaysCaloriesIntent`) — reports today's logged total.

Both are registered as App Shortcuts in `QuietCalShortcuts`, so no user setup is
required — the phrases work as soon as the app has been launched once.

### Usage

Trigger by voice, Type to Siri, Spotlight, or the Shortcuts app:

> "Hey Siri, log a meal in QuietCal"
> — *"What did you eat?"*
> "two hundred grams of grilled chicken"
> — *"Logged grilled chicken — about 330 calories."*

> "Hey Siri, how many calories have I logged in QuietCal?"
> — *"You've logged 1,240 calories today across 4 meals."*

Amounts can be weights, volumes, or counts — "8 oz salmon", "a cup of rice",
"250 ml orange juice", "two eggs". On device, the on-device model normalises the
amount to grams and estimates the calories in a single call.

### How it works

- The intent runs in a background process, separate from the UI, so it writes
  straight to the shared App Group SwiftData store and calls
  `WidgetCenter.reloadAllTimelines()` — the meal is there next time the app opens.
- Phrase parsing is delegated to the CalorieEstimator package's model-based
  `estimate(phrase:)`. A lightweight local fallback (`MealPhraseParser`) backs
  the simulator/stub path so the flow works without Apple Intelligence.
- A `SiriTipView` on the Home screen teaches the trigger phrase (dismissal is
  persisted).

### Notes

- Voice Siri and on-device estimation require a **real device** with Apple
  Intelligence enabled. On the simulator, exercise the intents from the
  **Shortcuts** app (they use the stub estimator).
- Every App Shortcut phrase must include the app name ("QuietCal").

## Requirements

- Xcode 26+
- iOS 26+
- Swift 6+

## Building

Open `QuietCal.xcodeproj` in Xcode and run the `QuietCal` scheme on a
simulator or device.

## Testing

Run the `QuietCalTests` scheme in Xcode, or use `Cmd+U`. Tests are written with
the Swift Testing framework.

## License

MIT — see [LICENSE](LICENSE).
