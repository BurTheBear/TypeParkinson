# TypeParkinson presentation

Continue the existing app; do not rebuild it. Presentation first, then the existing GitHub Pages site, then focused improvements to the existing app. Work on `presentation`, push to the fork, open an upstream PR; Pranav merges.

## Film
94 seconds, silent, 1920×1080 at 30 fps. Self-contained HTML uses Canvas with a deterministic `window.__render(t)` and real embedded simulator footage. Space pauses, arrow keys change scene, F enters fullscreen. Reduced motion opens in manual slide mode. Offline system typography.

Aura palette: ink #0A0F1F, ground #F3F4F8, accent #2F5BFF, purple #6E4DFF, cyan #16B8C8. Rounded heavy display type, restrained body text, generous margins. Touch dots carry the narrative: missed intent becomes understood intent. No stock imagery or decorative icons.

Scenes: 0–7 typing slips; 7–14 problem; 14–22 Aura reveal; 22–34 personal touch distribution; 34–48 correction; 48–60 real app toolkit; 60–70 motion measurement; 70–80 care-team patterns; 80–86 privacy; 86–94 final credit.

Credits confirmed: Atharv Sharma & Pranav Atreya. Source checked: Parkinson's Foundation currently estimates 1.1 million Americans living with Parkinson's; use that sourced figure instead of the older handoff estimate. Any sensor charts and app histories are explicitly labeled illustrative or sample data. No diagnostic or clinical-outcome claims.

## Website
Build within docs/. Hero combines the Aura and the actual personal keyboard screen. Clear product story, four setup steps, interactive illustrated correction demo with revert, practice toolkit, care-team reports, privacy, team. Keep privacy.html and support.html. Use optimized local images, a small film preview, and a link to the full presentation. Mobile has 16px gutters, accessible controls, keyboard focus, and reduced motion.

## Validation
Seek every film scene, inspect contact sheet, test deterministic backward seeking and playback controls, render full MP4 and check duration/codec/size. Inspect website at desktop and 390/320px widths, check demo controls and local links. No native build per user instruction. Document device testing still required.
