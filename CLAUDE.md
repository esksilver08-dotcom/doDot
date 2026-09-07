# doDot (mailmeil)

A native iOS app for tracking daily goals and their sub-tasks ("routines").
SwiftUI + Swift Testing, no external dependencies or package manager —
everything lives in the single `mailmeil.xcodeproj`.

## Commands

This repo has no toolchain available outside macOS/Xcode — builds and tests
cannot run inside this container. On a Mac with Xcode installed:

```bash
# Build for the simulator
xcodebuild -project mailmeil.xcodeproj -scheme mailmeil \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit + UI tests (Swift Testing + XCTest)
xcodebuild -project mailmeil.xcodeproj -scheme mailmeil \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Or open `mailmeil.xcodeproj` in Xcode and use Cmd+R / Cmd+U.

Deployment target: iOS 18.2. Swift 5.

A shared scheme (`mailmeil.xcodeproj/xcshareddata/xcschemes/mailmeil.xcscheme`)
is checked in so `-scheme mailmeil` works on a clean checkout (CI included) —
without it, only whatever user-specific scheme Xcode auto-generates locally
would exist, and `xcodebuild` would fail to find one on a fresh clone.

## CI

`.github/workflows/screenshots.yml` builds the app for the simulator on every
push, launches it, and uploads a screenshot as a workflow artifact — useful
for seeing UI changes without a local Mac.

## Project structure

```
mailmeil/
  mailmeilApp.swift          # @main entry point, wires GoalsViewModel in
  ContentView.swift
  Item.swift                 # Item: a single todo/routine entry (Codable struct)
  Models/
    Goal.swift                # Goal: a tracked goal, owns its todos (Codable class)
  ViewModels/
    GoalsViewModel.swift      # ObservableObject: CRUD, daily reset, JSON persistence
  Views/
    GoalsHomeView.swift       # top-level list of goals
    GoalCardView.swift
    GoalDetailView.swift
    GoalsTodoListView.swift
    AddGoalView.swift / EditGoalView.swift
    AddTodoInputView.swift / EditTodoView.swift
    Color+Extension.swift
mailmeilTests/                # Swift Testing (`@Test`) unit tests
mailmeilUITests/               # XCUITest UI tests
```

## Architecture

- **Persistence**: `GoalsViewModel` serializes `[Goal]` to a `goals.json` file
  in the app's Documents directory (see `saveToDisk`/`loadFromDisk`) — despite
  the `import SwiftData` in `GoalsViewModel.swift`, SwiftData is not actually
  used for storage. There's no `ModelContainer`/`@Model` anywhere in the app.
- **`Goal`** is a reference type (`class`, `ObservableObject`) with
  `@Published` arrays (`baseTodos`, `todos`, `completedHistory`,
  `deletedContents`). `Item` is a plain `Codable`/`Equatable` value struct.
- **Daily repeat logic**: goals marked `isDailyRepeat` keep a `baseTodos`
  template; `GoalsViewModel.resetDailyGoalsIfNeeded()` (called on launch)
  regenerates the day's `todos` from that template based on `repeatDays`
  (0–6, day-of-week) and `lastResetDate`.
- **Views** are one SwiftUI file per screen/component under `Views/`,
  driven by `@EnvironmentObject var GoalsViewModel` injected at the app root.

## Conventions

- UI strings, comments, and commit messages are frequently Korean — match
  the existing language when editing nearby code/comments rather than
  translating wholesale.
- No third-party dependencies (no CocoaPods/SPM packages) — keep it that way
  unless there's a strong reason to add one.
