# Validation

Checked October 23, 2026, on branch `presentation`.

## Presentation

- `node presentation/tools/render.mjs test`: deterministic backward seeking passes for both illustrated and video scenes; arrow controls, Space pause/play, and Reduce Motion manual slides pass.
- Fifteen rendered review frames inspected, including every scene and each correction example. Text overlaps corrected before final export.
- Full 1080p export: H.264, 1920×1080, 30/1 fps, 2,820 frames, 94 seconds, 4,073,710 bytes, no audio stream.
- Full video decoded with ffmpeg; no decode errors.
- Website copy: H.264, 1280×720, 94 seconds, 1,945,749 bytes, no audio.
- All media is embedded in `animation.html`; no network requests or font downloads are needed. Packaged HTML is about 1.7 MB.

## Website

- `python3 presentation/tools/check-site.py`: four HTML pages pass local file, link and anchor checks, unique IDs and image alternative text/dimensions.
- `node --check docs/site.js`: passes.
- Real browser inspection at 1440, 390 and 320 CSS px. No horizontal overflow; demo keys are at least 44×44 px. Privacy and support also fit 320 px.
- All four correction examples and their undo paths pass. Physical Space changes `Tje` to `The ` with capitalization preserved.
- No browser console errors or broken loaded images observed.
- Activity gradient endpoints adjusted for white text contrast; smallest checked endpoint contrast exceeds 4.5:1.
- Reduced Motion disables the website Aura animation and smooth scrolling. Film has a full text transcript. Film media uses `preload="none"`.

## Native source changes

Native app builds and tests were **not run**, per the user's explicit instruction not to rebuild. Existing installed-app captures are not validation of the new Swift source.

Four export regression tests were added for empty history, sensor/dose inclusion, CSV punctuation/newlines and spreadsheet-formula protection. They still require execution in Xcode. Microphone startup error handling, countdown cancellation and the revised PDF layout require native verification.

Physical-device follow-up remains: keyboard in other apps, App Group sharing, real motion sensors, microphone input and failure handling, countdown cancellation, medication “Took it” action, PDF layout and CSV exports. Pranav must merge the PR and confirm GitHub Pages deployment from `main` /docs.

## Overnight keyboard review — October 24

Source-only update: Undo entries now retain the document ID and cursor context at the end of each edit. A mismatch, selection or unavailable non-empty context prevents stale Undo. Closing the keyboard clears the edit stack, touch sequence, correction suggestions and cached word-validity decisions. Selection replacement/deletion records retain the selected text for restoration. The numerical touch model remains intact. Proxy API names were checked against the installed UIKit SDK headers. One decoder cache/learning regression test was added, but was **not run**.

Manual native checks still required:

1. Type a short word and Undo repeatedly at the same cursor. Restore both one-character deletions and a full hold-delete, including deletion to an empty field.
2. Type in one field, switch to a second field with identical text, and tap Undo. Neither field should change from the stale Undo.
3. Move the caret or edit text through the host app, then tap Undo. It should leave unrelated text alone. New typing at that position should have its own Undo history.
4. Select a word, type a replacement or pick a suggestion, then Undo. Restore the selected text with neighboring text unchanged.
5. Select all text starting at the beginning of the field, use Delete word, then Undo. Remove the selection once and restore it in full.
6. Hide/reopen or switch away from the keyboard, then Undo. Previous-session text must not be restored. Verify personal touch learning still loads.

These changes are in draft PR #7 and remain unbuilt, per instruction. No claim is made that the native scenarios or added Swift tests have passed.

## Hold-to-delete grouping — October 24

Source-only change: the shared keyboard sends a repeat-start event after the hold delay, and both Speak and the extension use it to start a fresh Undo group. Speak now retains one pre-hold snapshot rather than one per deleted character. A later edit starts a fresh group, and repeated deletion clears the old correction chip. The four new Swift regression tests have **not been run**.

Before merging, test in Speak and in the system keyboard: one long hold followed by one Undo; two separate holds followed by two Undos; deletion all the way to an empty field; another edit while repeating; release or slide off before the hold threshold; slide off and back on; and disappearance while holding. Each completed hold must restore only its own deleted block. Confirm a normal tap still deletes exactly one character and no deletion continues after release.

## Reduce Motion controls — October 24

Source-only accessibility changes cover BigNumber updates, shared card/primary/glass/pressable button styles, the practice carousel, segmented choices, feeling selection and Aura mood changes. The Reduce Motion paths disable spring/scale/bounce/counting effects while retaining immediate value, colour and opacity feedback. API names for identity content transitions and removing symbol effects were checked in installed SwiftUI SDK interfaces. git diff --check passes; no native build or runtime verification was performed.

Before merge, enable iOS Reduce Motion and check Today, Progress and the daily check. Trigger changing values, scroll the practice carousel, press every shared button style, and choose a feeling/segment. Repeat with Liquid Glass both on and off. Toggle Reduce Motion while the app remains visible: numbers should show their current values without counting and controls should keep their size. Turn Reduce Motion off and confirm the ordinary entrance, press and selection animations remain.

## Medication editor controls — October 24

Source-only changes give Remove dose a 44×44-point minimum target and Add a time a 44-point minimum height. Save uses a synchronous in-flight guard; Save and schedule editing stay disabled until reminder scheduling returns, with a Saving… label. No native build or UI test was run.

Before merge, tap near the edges of both dose controls with normal and large text sizes; verify the correct time is removed and another time is added. Tap Save repeatedly, including while the notification permission prompt is open: only one save operation should start and the schedule should not remain editable during it. Check both allowed and denied notifications; denied permission must still show the existing saved-schedule notice, and finishing the operation must clear the saving state. Reopen the editor and confirm the saved schedule is intact.
