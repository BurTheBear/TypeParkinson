# Overnight progress — October 23, 2026

Continue in this repository on branch `presentation`; do not create another app or run xcodebuild. The installed simulator app was used for all captures. The initial rebuild was stopped after the user said no rebuilds. No app installation or native rebuild was completed during the task.

## Completed

- Deterministic 94-second film in `animation.template.html`, packaged offline `animation.html` (about 1.7 MB), and render tools with no npm dependencies.
- Real captures: Today, Practice, Progress, Speak, onboarding, tremor sample session and voice sample session. System keyboard correction is illustrated using cases from existing tests; accessibility activation deliberately provides no raw touch locations and therefore does not demonstrate spatial autocorrection. Do not present the failed AX-driven `tje` capture as correction footage.
- Final MP4 verified by ffprobe and full decode: H.264, 1920×1080, 30 fps, 2,820 frames, 94 seconds, 4,073,710 bytes, no audio. Privacy wording is explicitly scoped to the keyboard.
- Existing docs website replaced with Aura landing page, WebP screenshots, film, interactive correction demo, transcript, preserved privacy/support URLs, revised privacy details.
- Browser checks so far: 390px and 320px no horizontal overflow; no broken loaded images or console errors; all four demo examples and undo pass; actual keyboard Space preserves capitalization; all demo keys >=44px in both dimensions.
- Existing app improvements in source: CSV includes tremor/voice/dose records, stable decimal points, quoted user-entered medication details, spreadsheet formula protection; PDF adds sensor/dose summaries and counts those practice sessions. Regression tests added to existing SmartFeatureTests.swift (not run: user prohibits native rebuild).
- VoiceMeter startup failures now return failure instead of creating synthetic results, and VoiceSession displays a retry notice. Voice/tremor countdown tasks cancel when their screens close. Sample voice sessions are labeled. These native changes remain unbuilt/unverified on hardware.

## Current publication state

Final film and website checks are complete; details are in VALIDATION.md. The final 1080p film is 94 seconds and 4,073,710 bytes, with a 1,945,749-byte 720p website copy. Playback controls, video backward seeking and reduced-motion slides pass. Native changes remain deliberately unbuilt. Published to the fork and opened draft upstream PR #7: https://github.com/pranav-atreya10/TypeParkinson/pull/7. It targets main from BurTheBear:presentation. Pranav must review, validate native changes and merge. Update this same PR during overnight follow-ups.

Keep following the user's overnight request after publication: inspect the existing app for concrete correctness/accessibility issues and update the same branch/PR when justified. Avoid speculative features, new apps, native builds, duplicate PRs and routine status messages. Stop this overnight heartbeat after 7 AM October 24 America/New_York. Check usage before substantial work; preserve allowance to save progress.

Credits confirmed: **Atharv Sharma & Pranav Atreya**. Population source checked: Parkinson's Foundation currently estimates 1.1 million Americans. All displayed clinical-looking histories are sample data, labeled; no diagnostic or effectiveness claims.

Automation: heartbeat id `typeparkinson-overnight-work`, hourly in this chat, continues until 7 AM October 24 America/New_York. Usage last checked: 53% current window used, 9% weekly used. Check again before substantial final work.

## October 24, shortly after midnight — keyboard review

- PR #7 remains open, draft and mergeable, with no new comments. Working tree was clean on presentation before this pass.
- Found source evidence that system-keyboard Undo retained old edits across dismissal and replayed them without document/cursor checks. Added per-edit document ID and before/after context guards, stale-edit invalidation before keyboard actions, and transient-text clearing on appearance/disappearance. Word-validation caches are also cleared while the numerical touch model is preserved.
- Selection replacements/deletions now remember the actual selected text; Delete word removes a selection once rather than continuing left of it. Hold-delete also records a selected range correctly.
- Confirmed the proxy documentIdentifier, selectedText and context API names against the installed Apple UIKit SDK headers. Added one decoder cache/learning regression test. No native compilation or test execution occurred. Manual device scenarios are appended to VALIDATION.md.
- Website local links/assets check, JavaScript syntax and git diff whitespace checks still pass. Presentation/video/site media preserved.
- Hold-delete boundary issue was investigated and addressed in the following pass.

## October 24, 1 AM — hold-delete review

- Source confirmed two grouping problems: Speak recorded every repeated deletion separately; the extension kept its hold flag across separate gestures because the repeated gesture suppresses the final ordinary press.
- Added an explicit onRepeatDeleteStart signal after the hold threshold. Speak and the extension start a new Undo group from that signal. TextComposer remembers the pre-hold text once, clears obsolete correction chips during repeated deletion, and breaks the group if another edit occurs. Short taps and cancellation before the threshold do not signal a repeat start.
- Added four regression cases for one-hold restoration, independent holds, an intervening edit and clearing a stale correction chip. All new native tests remain unrun, and no native rebuild/installation occurred. Changes target the same draft PR #7.
- Reviewed all callback wiring and changed source paths; git diff --check passes. Film, website and media are untouched.
- Next narrow review candidate: BigNumber in DesignKit guards its entrance animation for Reduce Motion but its onChange(value) path still animates; check that and related shared press feedback against the existing accessibility setting.
