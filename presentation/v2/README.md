# TypeParkinson v2 — in production

The exact brief is BRIEF.md. Research and shot plan were written before animation code. Source is src/, offline generated player is animation.html, Three.js 0.170.0 and Nunito are vendored with their licenses. Rebuild using npm ci then npm run build. No network is needed for the generated player.

Current status: initial physical 3D prototype; final cuts, narration/captions and three review passes remain in progress. Do not mistake this checkpoint for an approved final film. See REVIEW.md and VALIDATION.md.

Render examples:

    node tools/render.mjs --width=960 --stills=2,21,44,68 --prefix=review
    node tools/render.mjs --width=960 --fps=15 --output=preview/animatic.mp4
    node tools/render.mjs --width=1920 --fps=60 --samples=4 --output=preview/presenter-picture.mp4
    node tools/render.mjs --cut=submission --audio=score-submission.wav

Space pauses, arrows select chapters, F fullscreen, R reduced motion. Submission/player cut selector shares deterministic poses. __render(t,{samples:4}) accumulates actual shutter-time camera/object poses. Preview paths are ignored in Git; review contact sheets are retained.
