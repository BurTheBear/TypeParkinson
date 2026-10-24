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
