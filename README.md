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
  Apple Intelligence implementations
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
├── Models/          # Domain models (Meal, DayTotal, Theme, etc.)
├── Services/        # Calorie estimator implementations
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
