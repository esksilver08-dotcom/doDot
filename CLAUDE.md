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
    CharacterAvatarView.swift   # level -> one of 7 StudyStage illustrations
                               # (Assets.xcassets), each its own drawn artwork
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
  XP needed per level escalates (`xpRequired(for:) = 100 + (level-1)*20`),
  capped at `maxLevel = 30` — `addXP` no-ops once `isMaxLevel`, and
  `CharacterView`/`LevelUpOverlayView` swap to a "MAX" / "만렙 달성!"
  display instead of the usual level number + XP bar.
- **Todos** (`TodoItem`) are one-off, dated (`date`), and shown for "today"
  only (`AppViewModel.todaysTodos`), split into `.morning`/`.afternoon`/`.evening`.
- **Routines** repeat on selected weekdays (`repeatDays`, 0=Monday...6=Sunday,
  see `AppViewModel.todayWeekdayIndex()`). Whether one is done "today" is
  derived from `lastCompletedDate` rather than a stored flag that needs an
  explicit daily reset — toggling just sets/clears that date.
- **Reminder**: `AppViewModel.updateDailyReminder()` runs after every save,
  counting today's incomplete todos + routines and asking
  `NotificationManager` to reschedule (or cancel, if nothing's left).
- **Avatar**: a real 7-stage illustration set (`StudyStage1`...`StudyStage7`
  in Assets.xcassets — cropped from one commissioned grid image, one panel
  per stage) drawn specifically for this progression: 공부 허수 → 학습
  입문자 → 학구적 몰입 → 지식 체계화 → 학문 융합가 → 탐구의 완성 → 학문의
  초월자. `CharacterAvatarView`'s private `studyStage(for:)` maps level to a
  stage (Lv 1-5/6-10/11-15/16-20/21-25/26-29, stage 7 from Lv 30+), so
  leveling up actually swaps the artwork rather than re-tinting one image.
  Replaced once already with a higher-quality single-variant-per-stage
  source image (~400-590px native per panel) once the first source's
  linework read as muddy even after correction. Each imageset's @1x/@2x/@3x
  are real half/native/1.5x-upscaled (plain Lanczos, no sharpening — a
  sharpen pass was tried and made rough linework look harsher, not cleaner)
  variants of the crop, not the same file three times (the original bug).
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
