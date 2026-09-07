# doDot (mailmeil)

A native iOS app for gamified daily productivity: todos (split into
morning/afternoon/evening), important one-off events, and recurring
routines all feed XP into a leveling-up character. SwiftUI + Swift Testing,
no external dependencies or package manager — everything lives in the
single `mailmeil.xcodeproj`.

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
  mailmeilApp.swift          # @main entry point: TabView (오늘/루틴/캐릭터)
  Models/
    PlayerCharacter.swift     # level + XP, addXP/removeXP (named to avoid
                               # shadowing Swift's built-in Character type)
    TodoItem.swift             # TodoItem + Difficulty (XP value) + TimeOfDay enums
    ImportantEvent.swift       # dated event shown alongside today's todos
    Routine.swift               # recurring task; "done today" is derived from
                               # lastCompletedDate, not a separately-reset flag
  ViewModels/
    AppViewModel.swift         # single source of truth: character, todos,
                               # events, routines; JSON persistence; awards/
                               # revokes XP on toggle; reschedules the
                               # reminder notification on every save
  Views/
    TodayView.swift             # 오늘 tab: important events + todos by time of day
    AddTodoView.swift / AddEventView.swift
    RoutineView.swift           # 루틴 tab: today's recurring routines
    AddRoutineView.swift
    CharacterView.swift         # 캐릭터 tab: level + XP bar + stats + history link
    CharacterAvatarView.swift   # chibi student illustration (AvatarGirl/AvatarBoy
                               # assets) + level-tiered glow ring + crown at Lv.10+
    LevelUpOverlayView.swift    # confetti celebration shown on level-up
    HistoryCalendarView.swift   # month calendar of completion history
    SettingsView.swift          # reminder time picker
  Services/
    NotificationManager.swift   # local "N routines left today" reminder,
                               # user-configurable time (UserDefaults)
mailmeilTests/                # Swift Testing (`@Test`) unit tests
mailmeilUITests/               # XCUITest UI tests
```

## Architecture

- **Persistence**: `AppViewModel` serializes character/todos/events/routines
  to a single `appstate.json` file in the app's Documents directory
  (`save`/`loadFromDisk`). No SwiftData/CoreData.
- **XP flow**: completing a todo or a routine calls
  `PlayerCharacter.addXP(_:)` with the item's `Difficulty.xp` (쉬움=10,
  보통=30, 어려움=50); un-completing calls `removeXP(_:)` to reverse it.
  Leveling is a flat `xpPerLevel = 100` per level — no escalating curve yet.
- **Todos** (`TodoItem`) are one-off, dated (`date`), and shown for "today"
  only (`AppViewModel.todaysTodos`), split into `.morning`/`.afternoon`/`.evening`.
- **Routines** repeat on selected weekdays (`repeatDays`, 0=Monday...6=Sunday,
  see `AppViewModel.todayWeekdayIndex()`). Whether one is done "today" is
  derived from `lastCompletedDate` rather than a stored flag that needs an
  explicit daily reset — toggling just sets/clears that date.
- **Reminder**: `AppViewModel.updateDailyReminder()` runs after every save,
  counting today's incomplete todos + routines and asking
  `NotificationManager` to reschedule (or cancel, if nothing's left).
- **Avatar**: two chibi-student illustrations (`AvatarGirl`/`AvatarBoy` in
  Assets.xcassets) stand in for a full per-level sprite set — the user picks
  one in a segmented control on the 캐릭터 tab (`avatarChoice` in
  UserDefaults via `@AppStorage`, shared with `CharacterAvatarView`). Growth
  reads as "studying harder" rather than a redrawn character: `studyTier(for:)`
  maps level to a glow color, a desk-prop badge (📖 → 📚✏️ → 📚🔥), and a
  caption (새싹 학습자 → 집중 모드 → 열공 모드 → 학습 마스터), plus a crown
  at level 10+.
- **Level-up celebration**: `PlayerCharacter.addXP(_:)` returns how many
  levels were gained; `AppViewModel` turns a nonzero result into a
  `levelUpEvent`, shown as a confetti overlay (`LevelUpOverlayView`) at the
  app root (`mailmeilApp.swift`) so it appears regardless of which tab
  triggered it.
- **App display name**: `INFOPLIST_KEY_CFBundleDisplayName` is `doDot`
  (English) in the Xcode build settings.

## Conventions

- UI strings, comments, and commit messages are frequently Korean — match
  the existing language when editing nearby code/comments rather than
  translating wholesale.
- No third-party dependencies (no CocoaPods/SPM packages) — keep it that way
  unless there's a strong reason to add one.
