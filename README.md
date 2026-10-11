# TypeParkinson
place for parkinson people to type

TypeParkinson measures how someone touches the screen, builds a keyboard around it, then checks that the keyboard actually helps.

## Project layout

- `TypeParkinson/` — the iOS app: touch exercises, touch profile, proposed keyboard, check, setup and everyday use.
- `KeyboardExtension/` — the system keyboard (custom keyboard extension) that types in any app.
- `Shared/` — code compiled into both: keyboard layout, touch interpretation, settings and theme.
- `Config/` — entitlements. App and keyboard share settings through the App Group `group.devplaceholder.J42KEV6W.TypeParkinson`; change it in both entitlements files and `Shared/KeyboardSettings.swift` if the bundle identifier changes.
- `typeparkinson-mockup/`, `TypeParkinson Website Design/` — design mockups.

## Running

Open `TypeParkinson.xcodeproj` and run the **TypeParkinson** scheme. Debug builds on the simulator start with **Simulate tremor (demo)** switched on, because mouse clicks are too precise to show much.

To open a screen directly with sample data, add a launch argument such as `-demoScreen proposal` (also `exercises`, `profile`, `check`, `compare`, `enable`, `home`, `recalResult`). Debug builds only.

To use the keyboard: Settings → Apps → TypeParkinson → Keyboards → turn on TypeParkinson. It doesn't need Full Access.

## First launch

Onboarding (four pages) → sign up → home. Sign-up is a placeholder: no account is created and nothing entered is stored or sent. It loads a sample touch profile so the app can be explored straight away; **Personalize my keyboard** on home runs the real exercises. Use `-demoScreen onboarding` or `-demoScreen signUp` to open those screens directly.
