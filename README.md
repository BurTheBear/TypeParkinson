# TypeParkinson
place for parkinson people to type

TypeParkinson measures how someone touches the screen, builds a keyboard around it, then checks that the keyboard actually helps. It's an iPhone and iPad app plus a system keyboard that works in any app.

## Project layout

- `TypeParkinson/` — the app: onboarding, account, touch exercises, touch profile, proposed keyboard, check, everyday use and settings.
- `KeyboardExtension/` — the system keyboard (custom keyboard extension). Letters, numbers, symbols and number pads; follows each text field's keyboard type and return key. Runs without Full Access.
- `Shared/` — compiled into both: keyboard layout, touch interpretation, settings, theme and the privacy manifest.
- `TypeParkinsonTests/` — unit tests (Swift Testing) for layouts, touch interpretation, settings and profiles.
- `Config/` — entitlements. The app and keyboard share settings through the App Group `group.com.pranavatreya.typeparkinson` (change it in both entitlements files and `Shared/KeyboardSettings.swift` together). The app also has Sign in with Apple and iCloud key-value storage.
- `docs/` — privacy policy and support pages, served by GitHub Pages.
- `AppStore/` — listing text, review notes, release checklist and a screenshot script. Start with [AppStore/README.md](AppStore/README.md).
- `typeparkinson-mockup/`, `TypeParkinson Website Design/` — design mockups.

## Running

Open `TypeParkinson.xcodeproj` and run the **TypeParkinson** scheme. Run the tests with ⌘U, or:

```bash
xcodebuild test -project TypeParkinson.xcodeproj -scheme TypeParkinson -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

To use the keyboard: Settings → Apps → TypeParkinson → Keyboards → turn on TypeParkinson. It doesn't need Full Access.

## How it fits together

First launch: onboarding (four pages) → account (Sign in with Apple, or continue without one) → touch exercises → profile → proposed keyboard → check → turn on the keyboard → home.

- **Accounts are optional.** Signing in with Apple saves the touch profile and approved keyboard to the person's own iCloud key-value store (`CloudStore`), keyed by their Apple user ID, so their other devices pick it up. There is no server. Settings has sign out and delete account and data.
- **The keyboard only reads.** The app writes approved settings to the App Group; the keyboard reads them each time it appears. Without Full Access it can't write there or use the network.

## Debug-only aids

- **Simulate tremor (demo)** — mouse clicks are too precise to show much, so simulator Debug builds add an offset, jitter and occasional extra contact to touches. Toggle it on the setup screen or in Settings › Developer.
- **`-demoScreen <name>`** launch argument opens a screen with sample data: `onboarding`, `account`, `welcome`, `exercises`, `profile`, `proposal`, `check`, `compare`, `enable`, `home`, `recalResult`, `settings` (add `-demoSignedIn YES` to show Settings signed in).

Neither is compiled into Release builds.
