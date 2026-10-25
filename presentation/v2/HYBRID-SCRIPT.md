# Record this version: animation + your real app

Target **2:45 total**, leaving 15 seconds below the official three-minute maximum. Use the **45-second showcase**, then **two minutes of your actual app and closing**. Do not append a demo to the separate 2:48 illustrated film. The showcase has music/SFX, no spoken voice; record the lines below yourselves. Rehearse once and trim pauses before exporting.

## 0:00–0:45 — revised 3D showcase

**Atharv:** Sending a short message should not mean fighting your keyboard. Parkinson’s can make precise taps difficult. An estimated 1.1 million Americans live with it, according to the Parkinson’s Foundation. We’re Atharv Sharma and Pranav Atreya, freshmen at Livingston High School in New Jersey. Our app is TypeParkinson.

**Pranav:** It’s an iPhone app and custom keyboard built with Swift and SwiftUI. Setup measures how your touches land, then adapts the keyboard around you. Correction helps recover intended words, and Undo keeps you in control. The real app also includes spiral and rhythm practice, a tremor meter and voice practice. The sensor clips here use labeled simulator samples.

## 0:45–1:10 — show Today → setup/profile → comparison

**Atharv:** Here is the actual app. Today brings the daily check and practice together. Setup records touch offset and spread in a two-dimensional Gaussian model. The comparison screen lets someone check their standard and personal keyboards. This displayed comparison is demo data, so we do not present these numbers as patient results.

**Record:** Move slowly enough to see each screen. If setup takes too long, show its instructions, one completed exercise and the resulting profile rather than waiting through the whole flow. Keep any sample-data label visible.

## 1:10–1:40 — show Speak, the app keyboard and Undo

**Pranav:** Here in Speak, the same keyboard helps compose a message. The decoder combines touch likelihood with word likelihood. Its dynamic-programming alignment considers repeated touches, missed letters and swaps. Our automated examples include tje to the and hellloo to hello. A correction can be undone with one tap. Speak can also read a message aloud or show it as a full-screen communication card.

**Record:** Tap the app’s own keys, enter a short example, press Space and show the actual result and Undo. Use a case you can reliably reproduce; describe only what happens in your take. Then show the Speak button or communication card. Do not substitute the illustrated 3D correction for a live app demonstration.

## 1:40–2:05 — show Practice and one exercise

**Atharv:** Practice offers different ways to work with touch, movement and voice. Spiral tracing and rhythm tapping record activity. Core Motion and a windowed Fourier analysis estimate shaking strength and frequency. Voice practice uses relative microphone volume. These are measurements and practice tools; they do not diagnose Parkinson’s. Simulator readings are samples.

**Record:** Show the Practice tiles, then demonstrate spiral tracing or rhythm tapping with your own input. The opening already includes the tremor and voice screens, so this section can show a different exercise. If recording on a simulator, keep sample labels visible and do not imply its microphone or movement readings came from a person.

## 2:05–2:25 — show Progress → export

**Pranav:** Progress brings the activity history together. Medication logs and PDF or CSV exports help someone share observations with their care team. The keyboard stores numerical touch parameters, never the words typed. Speak can save phrases and recent messages locally. There is no TypeParkinson server.

**Record:** Show a chart or insight, open the export action and briefly show the report. Label sample history. Do not wait for a long share-sheet interaction during the take.

## 2:25–2:45 — show real code / team closing

**Atharv:** The app and keyboard extension share numerical settings through an App Group. Our current simulator run passed 67 automated tests across 13 suites. Real-device integration and patient benefit still need validation. Our goal is practical: help people communicate with more control. TypeParkinson—a keyboard that learns your hands.

**Record:** Show the actual `Shared/IntentDecoder.swift` candidate-scoring code or the project, then both students for the close. Explain the code in your own words. Complete `AI-ASSISTANCE.md` with your actual individual contributions; disclose Claude Code/Codex assistance accurately in the application. Do not invent interviews, user testing or a personal origin story.

## Final export check

- The complete uploaded video must be **1–3 minutes**, including every intro, demonstration and credit. This script targets 2:45; measure your actual final export.
- Include both names, app name/purpose/audience, languages/tools and visible functionality. These are required by the [official 2026 CAC rules](https://www.congressionalappchallenge.us/wp-content/uploads/2026/05/2026-CAC-Rules.pdf), page 3.
- Caption your actual recorded narration in the video editor. The existing 2:48 SRT belongs to the alternative long film and does **not** match this hybrid script.
- Population source: [Parkinson’s Foundation](https://www.parkinson.org/understanding-parkinsons/statistics). No clinical effectiveness claim is made.
