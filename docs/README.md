# TypeParkinson static website

Deploy this folder directly; no build, framework or environment variables are required. The root netlify.toml publishes docs when importing the Git repository into Netlify. For a manual deployment, upload the contents of docs (index.html at the deployment root). Keep privacy.html and support.html at their existing paths.

Local preview from the repository root:

    node presentation/v2/tools/serve-site.mjs

Open http://127.0.0.1:8765/docs/. The server supports byte ranges for video seeking. It binds only to127.0.0.1 and serves this repository.

The landing page uses the existing Aura palette: #F3F4F8 ground, #0E1424 text, #2F5BFF action, white cards and activity colours. Rounded system display type, plain system body type and a large real phone image carry the hierarchy. The interactive tour reuses that visual system and actual captures, with quiet controls instead of extra decorative motion.

The45-second showcase has music/SFX and visible text, no student narration. demo.html is an interactive tour of real screenshots and recorded simulator exercises; it is not a live native iOS instance. A hosted running iOS simulator would require a separate service/account and is not included. All sensor/history samples are labeled. The keyboard illustration has four fixed correction examples, not the app's full Swift decoder.

The existing upstream GitHub Pages deployment still requires Pranav to merge draftPR7 and, if needed, select main /docs in Settings → Pages. Netlify can deploy the complete independent BurTheBear/TypeParkinson-CAC repository directly using its presentation branch. Neither action submits the CAC application.
