# Northstar — Future Features

**Status:** living backlog of ideas that are **not** current build work.  
**Rule:** capture the idea clearly; don’t implement until Android nav core is solid and the idea earns a spike.

Related: `TODO.md` (active backlog) · `docs/RIDER_SCORE_RESEARCH.md` · `docs/IOS_PORT_RESEARCH.md` · `docs/brainstorms/`

---

## Nav — Delayed / auto-start guidance (“I know until X”)

**Captured:** 2026-09-29 · **Priority:** future (post P0 nav verification)

### Problem
On familiar stretches you don’t need turn-by-turn from the start. Example: destination is **2B**, but you already know the road until about **km 8.3 / 8.5** (or some landmark). Full guidance from point A is noise — voice, banners, mental load — for a segment you don’t need help on.

### Idea
Plan the full route to the destination as usual, but **don’t engage active guidance** until the rider reaches a chosen **activation point**. After that point, Northstar automatically starts / unmutes turn-by-turn (and dash nav cards) toward the destination.

### User flow (sketch)
1. Share / set destination (e.g. 2B).
2. Route previews as today.
3. Optional: set **“Start guidance after…”**
   - pick a point on the polyline, or
   - type/search a landmark / chainage (e.g. “8.5”), or
   - “skip first N km / until I leave this familiar corridor”
4. Tap Send to Dash / start ride.
5. Until the activation point: free-roam / quiet mode (map can still show, voice off, minimal banners).
6. On approaching the point (geofence / distance-along-route): **auto-trigger** active nav (voice mode respected, dash nav packet live).

### Why it helps
- Less nagging on roads you know
- Saves attention (and possibly TTS / UI churn)
- Still have a full precomputed route + offline tile prefetch for the whole trip
- Feels like “meet me at the hard part,” not “hold my hand from the gate”

### Design notes / open questions
- Activation metric: distance-along-route vs lat/lng geofence vs “first time off familiar road”
- What shows on dash before activation — blank free-roam map vs muted route line vs standby
- Reroute behaviour if the rider never hits the activation point (timeout? manual Start?)
- Persist “I know until here” presets for common home→highway joins
- Interaction with existing off-route / heading-aware recalculation (probably armed only after activation, or always armed but silent)

### Non-goals (for this idea)
- Not a second destination; one destination, delayed guidance
- Not “don’t compute the route” — still plan + prefetch; only **guidance engagement** is delayed

### When to spike
After on-bike nav verification (joystick, glyphs, screen-off hold). Small spike: geofence on route polyline + VoiceManager mute until trigger.

---

## Rider smoothness / coaching score

See `docs/RIDER_SCORE_RESEARCH.md` + LLM council amendments.

- Phone GPS + accel **+ gyro** logging first
- Post-ride coaching card; **not** a “safety score”
- Digital gear = later upgrade if telemetry ever appears
- No hard-brake magnitude penalty; no badges until thresholds from real rides

---

## iOS port (gated)

See `docs/IOS_PORT_RESEARCH.md` + council.

- Conditional Phase 0 only (entitlement, desk tests)
- No SwiftUI until screen-off stream proven
- Android remains shipping platform

---

## Community / social riding (long horizon)

Already noted in `TODO.md` — shared rides, live presence, public Himalayan routes/POIs, ride feed. Revisit only after core is solid. Don’t pre-build backend for it.

---

## Other deferred product ideas (parked)

| Idea | Note |
|---|---|
| Offline map region downloads | Distribution / mountain no-signal |
| Dash basemap → OpenFreeMap (not unofficial Google raster) | Power + ToS |
| Routing off public OSRM demo | Reliability for distribution |
| Media / call overlay design | Post-root capture; dash has its own section |
| Mid-ride voice tips for coaching | Prefer post-ride first (safety) |

---

## How to add ideas

Append a short section: **problem → idea → rough flow → open questions → when to spike**. Keep this file for “someday”; put committed work in `TODO.md`.
