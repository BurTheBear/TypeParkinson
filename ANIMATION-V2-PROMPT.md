Rebuild the TypeParkinson presentation film from scratch as a v2 that is dramatically better than v1. This is the single most important deliverable left. The Congressional App Challenge submission window closes **October 26, 2026**, so plan the work to finish with time to review.

Work in `~/Desktop/TypeParkinson-CAC` on branch `presentation`. Keep v1 untouched (move it to `presentation/v1/`). Put everything new in `presentation/v2/`.

---

## 0. Why v1 isn't good enough (fix all of this)

I reviewed v1 (`presentation/TypeParkinson.mp4`, 94 s) frame by frame. Problems:
- **It's a slide deck, not a film.** Nearly every shot is a centered headline on the same dark navy gradient, with little camera movement and no depth. Scenes cut instead of flowing.
- **Weak 3D.** The phone back, the tilted keyboard and the key grid are flat and unlit, with no materials, reflections, depth of field or parallax.
- **Text is unreadable from a room.** Captions like "Illustrated touches. The keys stay in place." and "Simulator sample reading" are tiny. The app screenshots are small.
- **The opening "See you soon." is confusing,** and the end card is shown twice.
- **No sound,** no rhythm, and nothing synced to beats or events.
- **Inconsistent look.** It jumps from dark scenes to flat light-grey scenes ("Built around your day") with no transition logic.
- **Missing judge-critical content:** no human story, no clear proof that the keyboard works (the A/B check results), and nothing that shows the engineering (code, architecture, tests).
- **Unsourced stat.** "1.1 million" needs a citation on screen or in the captions, with the exact figure matching the source.

## 1. Research first (mandatory, before writing any animation code)

Use web search and browsing as much as you can. Write `presentation/v2/RESEARCH.md` with what you learned and every source URL. Research at least:
1. **Congressional App Challenge rules and judging.** Official criteria (2025 rules): quality of the idea (creativity, originality); implementation (user experience, design); demonstrated excellence of coding and programming skills. Demo videos should be no longer than 3 minutes. Look at past national and district winners and their demo videos (congressionalappchallenge.us). Note what made them stand out, and how videos cover what the app does, who it's for, the tools used and how it works.
2. **Apple-style product film language.** Keynote device reveals, macro close-ups, light sweeps over materials, slow orbiting cameras, kinetic typography, match cuts, and how they pace one idea per shot.
3. **Motion design craft.** The 12 principles adapted for UI motion (anticipation, follow-through, overlapping action, easing, arcs, staging); spring physics; match cuts and continuity; and avoiding "PowerPoint transitions".
4. **Three.js / WebGL showcase techniques.** Award-winning product sites (Awwwards / FWA), PBR materials, environment lighting (`RoomEnvironment` + `PMREMGenerator`, no external HDR needed), `MeshPhysicalMaterial` (clearcoat, transmission for glass), `VideoTexture` for a live phone screen, post-processing (`UnrealBloomPass`, `BokehPass` depth of field, subtle film grain and vignette), instanced meshes for particles, a custom fragment shader for a flowing mesh-gradient background, and crisp 3D text (`troika-three-text` or `TextGeometry`).
5. **Parkinson's facts, with citations** (Parkinson's Foundation, NINDS, peer-reviewed sources). Cover: how many people live with it in the U.S. (use the exact current figure and its source), the typical frequency of resting tremor (around 4–6 Hz), quiet voice (hypophonia), and difficulty with fine motor tasks such as typing. Do not use any number you can't cite.
6. **Accessibility for video.** Readable caption sizes, contrast, no flashing above 3 times per second (WCAG 2.3.1), and a reduced-motion option in the live player.

## 2. Creative direction: one continuous 3D world

Build the film in **Three.js** (vendor a pinned version into `presentation/v2/vendor/` so it works offline, e.g. `three@0.170.0` and its `examples/jsm` addons). Make **everything 3D** with real lighting and materials, and make it feel like one continuous camera move through a single world. The **iPhone is the hero object**: it persists across scenes and transforms between them instead of cutting.

3D elements to build (procedurally, no paid assets):
- **A realistic iPhone**: rounded titanium frame (`RoundedBoxGeometry` or extruded shape), glass front with clearcoat, camera bump, and an emissive screen that plays **real app footage** as a `VideoTexture`. Slow orbits, a light sweep across the frame, and depth of field.
- **3D keyboard**: instanced rounded keys floating in space with soft shadows. Keys depress with spring physics when "tapped", and touch ripples spread on the keycap.
- **Touch cloud and personal touch model**: glowing instanced particles land low-right of the "h" key with tremor jitter. A translucent 3D Gaussian bell surface rises out of the cloud ("your personal touch model"), then the particles flow back onto the right key and it lights up blue.
- **Smart correction in 3D type**: extruded letters "t j e" press into place, then on space the "j" flips and morphs to "h" with a spring and a check mark. A fast montage follows: "hellloo → hello", "tomorow → tomorrow", "teh → the".
- **Tremor meter**: a 3D waveform ribbon traced by a moving phone, which morphs into a 3D frequency "bar city" where the peak at about 5 Hz glows.
- **Aura background**: a full-screen shader mesh gradient that slowly flows, using the app's palette. It's the signature look, so keep it consistent in every scene. No flat grey scenes.
- **Daily rings** as 3D tori that fill up; **insight cards** and the **PDF report** as floating frosted-glass panels (`MeshPhysicalMaterial` with transmission).
- **For the programming-excellence criterion**: a short, beautiful sequence that shows real engineering. A floating glass panel shows a few lines of the actual Swift alignment code from `Shared/IntentDecoder.swift`. A 3D architecture diagram links App → App Group → Keyboard Extension, with "on-device" emphasised. A counter ticks up to "55 automated tests passing".
- Use the real app's screens (record fresh simulator footage, see §5) on the phone screen and on floating panels, big enough to read.

Palette and type: match the app's "Aura" design system. Ink `#0A0F1F`; accent `#2F5BFF`; aura colours `#2F5BFF`, `#6E4DFF`, `#16B8C8`, `#3FE0B5`, `#3D7BFF`; activity colours spiral `#00A0A0`, tapping `#FF5F33`, typing `#DB2F78`, tremor `#6E4DFF`, voice `#E89400`, speak `#0F9D63`, medication `#168BD0`. Display type in a rounded heavy face (SF Pro Rounded, falling back to Nunito ExtraBold/Black, which you vendor locally).

## 3. Story (cover everything judges look for)

Write `presentation/v2/STORYBOARD.md` with a shot list, timings, camera moves, on-screen words and the sound cue for each shot before animating. Suggested arc (improve it):
1. **Hook (0–10 s):** a macro shot of a single key with a finger's touches trembling around it; the word "hello" tries to type and comes out "hellloo". Silence, then one soft tone.
2. **Problem (10–25 s):** who it's for, with the cited U.S. figure. "For many people with Parkinson's, every tap is a guess." Show a quiet voice too (hypophonia), briefly, as the reason for Speak.
3. **Reveal (25–35 s):** the Aura blooms, the iPhone rises and orbits into frame, wordmark "TypeParkinson", tagline "A keyboard that learns your hands."
4. **How it works, 3 pillars (35–85 s):** (a) the personal touch model from 3D touch particles; (b) Bayesian smart correction in 3D type; (c) the on-device touch-pattern model plus the tremor meter's Fourier analysis. One strong visual idea per pillar.
5. **Proof (85–105 s):** the app's A/B check, standard keyboard vs yours (errors 4 → 1, fixes 6 → 2, from the app's comparison screen), with a clear "demo data" label. Then the engineering sequence: code panel, architecture, 55 tests.
6. **The whole app (105–130 s):** the phone flies through the real tabs (Today with rings, Practice with gradient tiles, Speak with the communication card, Progress with insights and the care-team PDF). Floating labels for each feature use its activity colour.
7. **Impact and privacy (130–150 s):** "Steadiest 1–3 hours after a dose — worth showing your doctor." "On-device. No servers. Never saves what you type." "Not a diagnosis — a record you can share."
8. **End card (150–165 s):** the Aura, wordmark, tagline, "Atharv Sharma & Pranav Atreya · Livingston High School, New Jersey · Congressional App Challenge 2026", website URL. Shown once.

Hard content rules: never say or imply the app detects or diagnoses Parkinson's or a subtype (it measures and describes touches, movement and voice). Label sample or demo data. Every statistic is cited.

## 4. Smoothness and polish (non-negotiable)

- **60 fps** output. Build the film as a deterministic `render(t)` (seeded PRNG, no wall-clock timers, no CSS transitions) so every frame is exact. Expose `window.__render(t)`.
- **Real motion blur**: render 4–8 sub-frames per output frame and blend them (accumulate in a render target, or capture sub-frames and use `ffmpeg -vf tmix`).
- Every movement is eased or sprung; nothing pops on or off. Every entrance and exit animates for at least 300 ms, and the camera never moves linearly.
- Continuity: carry objects between scenes (the phone, the keyboard, the particles) using match cuts and morphs, not hard cuts.
- Readability: in the presenter cut, nothing smaller than **48 px at 1080p**, and headlines at 120–200 px with at most 8 words on screen at once. Move disclaimers into the captions or the end card.
- Pacing: hold each key idea long enough to read twice; vary rhythm (fast montage against slow reveal).
- **Sound** (procedural, so there are no licensing issues): use the Web Audio API's `OfflineAudioContext` to render a soft ambient pad, subtle whooshes on camera moves, and soft key clicks synced to the on-screen taps. Export WAV and mux it with ffmpeg. Also make a version with no music, in case we narrate live.

## 5. Production pipeline

1. Record fresh, clean app footage first. Build the app (see `HANDOFF.md`). Run `xcrun simctl status_bar <udid> override --time 9:41 ...` for a clean status bar, then record with `xcrun simctl io <udid> recordVideo --codec=h264 --force`. Get clips of Today (scroll), Speak typing "tje" then space → "The", the tremor meter result, the voice meter rising into the loud zone, the Practice tiles, the Progress hero, the check comparison and onboarding. Convert to 60 fps H.264, sized to the screen texture.
2. Build a low-fi **animatic** of the whole film first (blocks and timings), then render each scene as a 10-second test clip.
3. Render to video: launch headless Chrome with `--remote-debugging-port`, `--window-size=1920,1080` and `--use-angle=metal` (or swiftshader if needed), connect over the DevTools Protocol with a small Node script (Node has a built-in `WebSocket`), and for each frame call `__render(t)`, then `Page.captureScreenshot`. Encode with `ffmpeg -framerate 60 -i frames/%06d.png -c:v libx264 -preset slow -crf 16 -pix_fmt yuv420p -movflags +faststart`. Also produce a 4K master if render time allows.
4. **Self-review loop, at least 3 passes:** after each render, make a contact sheet (`ffmpeg -vf "fps=1/4,scale=480:-1,tile=5x5"`). Watch the whole film and grade it against this checklist: cinematic or slide-like? 3D depth on every shot? Readable from 10 m? Smooth with no jank or pops? Each criterion clearly covered (idea, implementation and design, programming)? Accurate claims and citations? Fix every issue, re-render and repeat. Write each pass's findings to `presentation/v2/REVIEW.md`.

## 6. Deliverables

- `presentation/v2/animation.html`: live real-time player, 16:9, scales to any screen. **Space** pause, **← / →** scenes, **F** fullscreen, **R** reduced motion. Works offline.
- `presentation/v2/TypeParkinson-presenter.mp4`: 90–120 s, big on-screen words, music + SFX (plus a silent copy) for playing during a live presentation.
- `presentation/v2/TypeParkinson-submission.mp4`: **2:30–2:55 (must be under 3:00)**, with burned-in captions and a matching `.srt`. It covers what the app does, who it's for, the tools used (Swift, SwiftUI, a custom keyboard extension, Core Motion, AVFoundation, on-device Bayesian decoding and naive Bayes, Fourier analysis) and how it works, and names both team members. Include `VOICEOVER.md`, a narration script timed to the cut.
- `RESEARCH.md`, `STORYBOARD.md`, `REVIEW.md`, and contact sheets.
- Commit on `presentation`, push to the `fork` remote, and update or open the PR to `pranav-atreya10/TypeParkinson`. Keep the MP4s under about 50 MB each (re-encode if needed).

Before finishing, tell me in a short summary what changed from v1, the final durations and file sizes, and anything you could not verify.
