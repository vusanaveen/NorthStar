# Agent notes — Northstar

## Product

Unofficial Android (shipping) + **phased iOS** companion for Royal Enfield Himalayan 450 **Tripper** dash. Screen-off H.264 nav over bike Wi‑Fi.

## Current focus

1. Keep Android nav reliable.
2. **iOS Phase 0→2:** connect + navigation only (`docs/IOS_PHASED_PLAN.md`).
3. Future ideas live in `docs/FUTURE_FEATURES.md` — do not pull them into the active sprint.

## Layout

| Path | Role |
|---|---|
| `app/` | Android app (source of truth for wire protocol) |
| `ios/DashCore/` | SwiftPM portable core (K1G, RTP, geo) — test on Linux Swift |
| `ios/NorthstarApp/` | iOS app templates / checklists — needs Mac + Xcode |
| `docs/` | Research, plans, future features, council, brainstorms |
| `.cursor/skills/` | `brainstorm-six-hats`, `ios-northstar-dev` |

## Skills to use

- **iOS coding:** `.cursor/skills/ios-northstar-dev`
- **Ideation:** `.cursor/skills/brainstorm-six-hats`
- Do not start full iOS UI until Phase 1 gate (screen-off stream) is green.

## Environment reality

- **This Cloud Agent is Linux:** no Xcode, no iOS Simulator.
- Install **Swift toolchain** for `ios/DashCore` unit tests when missing.
- On-device Tripper validation requires the user’s **Mac + iPhone + bike**.

## Wire oracle

Always cross-check Swift against:

- `app/src/main/java/com/example/northstar/dash/DashSocket.kt`
- `.../DashAuth.kt`, `.../protocol/K1GPacket.kt`, `.../video/*`
