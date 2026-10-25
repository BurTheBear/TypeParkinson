# TypeParkinson — two-presenter pitch

Atharv Sharma & Pranav Atreya · Livingston High School, New Jersey · Freshmen

Use this with the **94-second silent film**. Start at 0:00; the timestamps are delivery windows, not extra pauses. Speak conversationally and leave the visual reveals a little breathing room. Approximately 210 spoken words. These are draft words for you to own and rehearse, not a claim that you have already recorded narration.

| Film time | Speaker | Say |
| --- | --- | --- |
| 0:00–0:07 | Atharv | A simple message: “See you soon.” You know what to say. Your hands don’t always cooperate. |
| 0:07–0:14 | Pranav | About 1.1 million Americans live with Parkinson’s. Tremor and stiffness can make typing harder. |
| 0:14–0:22 | Atharv | TypeParkinson personalizes typing for people with Parkinson’s. It’s an iPhone and iPad app, built with Swift, SwiftUI and Xcode. |
| 0:22–0:34 | Pranav | Setup measures where taps land. A two-dimensional Gaussian captures offset and spread. The app builds a personal keyboard, then compares it with a standard one. |
| 0:34–0:48 | Atharv | Our decoder combines touch likelihood with word frequency. Dynamic programming handles repeated touches, missing letters and swaps. These examples illustrate the logic. If a correction is wrong, one tap restores the original. |
| 0:48–1:00 | Pranav | Daily checks keep the keyboard personal. Spiral, tapping and typing activities track practice. Voice practice and Speak support communication. Large controls and saved phrases reduce effort. |
| 1:00–1:10 | Atharv | Motion sensors and Fourier analysis measure shake strength and rate. These recordings are simulator samples. They describe movement, and never diagnose a condition. |
| 1:10–1:20 | Pranav | Progress brings practice and medication records together. PDF and CSV exports give someone a record to discuss with their care team. |
| 1:20–1:26 | Atharv | Corrections run on-device. No servers. The keyboard never saves what you type. |
| 1:26–1:34 | Pranav | We’re Atharv Sharma and Pranav Atreya, Livingston High School freshmen. A keyboard that learns your hands. |

The population estimate is from the [Parkinson’s Foundation](https://www.parkinson.org/understanding-parkinsons/statistics). It is context about the condition, not a count of potential app users or a claim that everyone with Parkinson’s has typing difficulty.

## Delivery

- Trade speakers at scene boundaries. Avoid speaking over each other or reading the entire screen aloud.
- Emphasize **personal**, **compares**, and **one tap restores the original**. These explain what makes the approach useful.
- Pronounce Gaussian “GOW-see-un.” Explain it as a cloud showing where touches tend to land if asked. Don’t rush through the technical section to sound sophisticated.
- For a live presentation, open animation.html, press F, and use Space if you need to pause. Reduce Motion provides settled slides and arrows for a slower presentation.
- For the CAC submission, record your own voices with this film, then check the final duration and that speech is audible. The supplied MP4 is silent and is not a completed narrated submission. Stay within the official 1–3 minute window.
- Do not add an invented family story, user study, patient endorsement, percentage improvement, or claim that either of you independently wrote AI-assisted code. Add your actual inspiration and individual contributions to the written application in your own words.

## Questions judges may ask

**What does the Gaussian actually do?**

It models the horizontal and vertical offset and spread of touches around an intended key. A touch a little to the right can still be likely under that person’s model. The key layout stays familiar. See Shared/TouchModel.swift.

**Why isn’t this just spellcheck?**

The decoder scores candidate words using both their word prior and how likely the observed touches are under the personal model. A dynamic-programming alignment accounts for matches, extra contacts, missed letters and swaps. A dictionary remains part of the system. This does not establish superiority over another keyboard. See Shared/IntentDecoder.swift and Shared/WordList.swift.

**How do you know it helps?**

The app has a within-person check: type one phrase on a standard layout, then another on the personal keyboard, and compare mistakes, corrections and time. It can also report when the personal settings perform worse. That short check is not a clinical trial; different phrases and practice/order effects limit what it proves. The four animated corrections illustrate existing decoder test cases, not patient outcomes. See TypeParkinson/Views/CheckScreens.swift.

**What data leaves the phone?**

There is no project server. The system keyboard does not save typed text and works without Full Access. Optional sign-in sync uses the person’s own iCloud for approved profile/settings. Speak intentionally saves phrases and recent spoken phrases locally; practice and dose history are local too. Don’t say the whole app stores no text. See docs/privacy.html.

**Is the tremor meter a diagnosis?**

No. The app samples motion, applies a Hann window, and uses a discrete Fourier transform to describe shake rate and strength. The presentation uses labeled simulator samples and an illustrative spectrum. Microphone practice measures relative loudness, not calibrated clinical decibels. Neither identifies a disease or recommends medication.

**What was technically difficult?**

A source-backed example is distinguishing an intended repeat from a rapid extra contact without corrupting a real word. The alignment combines touch likelihood, word priors and timing-sensitive bounce penalties; Undo leaves the person in control. Explain the implementation you personally understand and your actual contribution. Do not present an AI-suggested solution as an unaided personal story.

**What would you improve next?**

Validate the current keyboard on physical iPhones in other apps, verify App Group sharing and real sensor/microphone behavior, and test accessibility with people who choose to participate. Evaluate correction errors and the within-person check before making effectiveness claims. The new native fixes on this branch still need Xcode and hardware verification.

**Did you use AI?**

Yes. Claude Code and OpenAI Codex assisted with code, debugging, reviews, presentation, website and draft writing. See AI-ASSISTANCE.md for the scope known from the handoff and this work. Explain your own decisions and contributions accurately; add any other assistance before submission.
