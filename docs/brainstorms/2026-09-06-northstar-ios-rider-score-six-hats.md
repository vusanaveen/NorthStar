# Six Hats — Northstar: iOS port + Rider Coaching Score

Date: 2026-09-06  
Question: Given Android Northstar (Tripper screen-off nav) and our research/council work, how should we think about (1) an iOS version and (2) a Tesla-like “how well am I riding?” score that might use RE’s digital gear — and what should we actually do next?

Skill used: `.cursor/skills/brainstorm-six-hats`

---

## Blue (process) — open

- **Primary question:** What is the smartest path for Northstar over the next ~30 days across iOS feasibility and a rider coaching score?
- **Success looks like:** Clear kill/continue gates; no wasted multi-week builds; Android nav stays reliable; any new feature earns its place with evidence.
- **Constraints:** Unofficial Tripper link; single Himalayan 450 rider (Nothing Phone today); screen-off is the product; K1G projection does not currently forward gear/instruments; App Review / tile ToS landmines if we distribute iOS carelessly.
- **Out of scope this session:** Writing SwiftUI or score UI; CAN dongles; community/social features; claiming safety/insurance value.
- **Agenda:** White → Red → Yellow → Black → Green → Blue close.

---

## White (facts)

- Android app already streams H.264 map to Tripper over Wi-Fi (control UDP 2000/2002, RTP 5000), RSA/AES auth, ~526×300 @ low fps.
- Firmware reference in docs: **11.63**; captures showed joystick/video ACKs; `0x0C` instruments ~zero; `0x0F` not observed → **gear not available on projection pipe today**.
- Himalayan cluster **does** show digital gear + upshift advisor (gear × RPM × TPS) locally via bike CAN — separate from phone Wi-Fi nav.
- iOS has no silent `RE_*` prefix join; needs `NEHotspotConfiguration` (prompt). Broadcast control likely needs **Multicast Networking entitlement** (Apple approval, uncertain).
- iOS background GPU/Metal for MapLibre dash frames is a known failure mode; CPU path or shared renderer strategy required.
- Phone has GPS + accel + gyro usable without dash telemetry.
- Tesla Safety Score v1 used behavior **rates** and thresholds like hard brake ~0.3g / turn ~0.4g; later versions changed; not a bike model.
- Coordinated motorcycle lean ≠ car lateral-g in the bike frame; council: prefer `a_lat ≈ v·ω_yaw`.
- Author device is Android (Nothing); iOS helps *other* riders first, not the author’s daily ride.
- Existing research: `docs/IOS_PORT_RESEARCH.md`, `docs/RIDER_SCORE_RESEARCH.md`, `docs/LLM_COUNCIL_REVIEW.md`.
- **Unknowns:** Does dash accept unicast `:2000`? Will Apple grant multicast? Soft tank-bag IMU noise floor? Will future FW forward gear on K1G?

---

## Red (feelings)

- Excitement about “Tesla-like score” — feels premium and sticky.
- Anxiety that iOS is a shiny distraction from the bike that already works half-broken on Android.
- Frustration that gear is *right there on the dash* but invisible to the app.
- Protective instinct: don’t gamify braking in a way that makes anyone hesitate in an emergency.
- Pride in the reverse-engineered protocol — don’t want to cheapen it with a fake score.
- Mild FOMO if iPhone riders ask “when iOS?”
- Gut: **logging ride feel soon would be fun**; **full iOS port right now would feel heavy**.

---

## Yellow (benefits)

- **Rider score (logging → coaching):** Turns rides we already record into a feedback loop; motivation without needing RE APIs; works phone-first; gear later is upside not a gate.
- Smoothness coaching fits ADV touring (the Himalayan use case) better than track heroics.
- Post-ride card is safe UX (no mid-corner nagging) and fits screen-off philosophy.
- **iOS:** Widens audience beyond Android; forces protocol purity (good for longevity); Phase 0 spike is cheap insurance if we ever care.
- Filing multicast entitlement early is almost free and unblocks future-you.
- Shared “desk tests” (unicast, SPS dump) improve Android understanding too.
- Getting off Google tiles / OSRM-demo helps **both** platforms and open-source credibility.

---

## Black (risks)

- iOS screen-off stream may simply be impossible / unreliable → weeks burned.
- Multicast entitlement refused → broadcast control dead unless unicast works.
- `joinOnce = true` style hotspot config silently fails multi-hour rides.
- Cellular starve when associated to no-internet Tripper AP → nav tiles/reroute die mid-ride.
- Soft tank-bag IMU → false “bad rider” scores → user distrust or unsafe behavior changes.
- Penalizing hard brakes on a bike is ethically and practically bad.
- Calling it a “Safety Score” invites legal/moral overclaim; Tesla naming is baggage.
- Building score UI before thresholds = decorating noise.
- Parallel iOS + score epics starve Android verification (thermals, joystick-in-nav, reconnect).
- Tile scraping carried into TestFlight/App Review → rejection / ToS risk.
- CPU vs MapLibre dash renderer strategy fork = double maintenance.
- Gear obsession delays a useful phone-only v0 forever.

---

## Green (ideas)

**Boring (good):**
1. One instrumented Android ride: 50 Hz accel+gyro+GPS CSV, screen-off, no UI.
2. Post-ride “smoothness” card with 3 factors only (brake modulation, corner composure via v·ω, speed consistency) after thresholds exist.
3. iOS desk harness only: join Wi-Fi, try unicast ping, VT encode one SPS dump — no SwiftUI.

**Practical variants:**
4. “Trip diary” instead of score: timeline of notable events (harsh brake, smooth canyon) without 0–100 ego number.
5. Optional voice one-liner at standee only (“choppy braking on NH6”) — never while moving.
6. Mount calibration wizard: 10 seconds upright + 10 seconds rolling straight to fix phone axes.
7. If unicast works, document “iOS-friendly control mode” and maybe use it on Android too.

**Provocations:**
8. Score the **route**, not the rider (surface roughness, grade) — removes ego/shame.
9. “Bike coach” that only unlocks tips after N calm rides — anti-gamification.
10. Ignore iOS entirely until Obtainium Android users hit a real request threshold.
11. Gear fitness via **audio**: listen for upshift advisor chime / cluster? (probably awful — note and discard unless proven).
12. Separate tiny “Northstar Labs” APK for sensors so main nav app stays lean.

**Combinations:**
13. Same ride captures council’s Android P0 metrics **and** IMU/gyro — one tank of fuel, two questions answered.
14. Basemap migration (off Google) as the bridge task that helps iOS later without starting iOS now.

---

## Blue (process) — close

### Decisions
1. **Android evidence first.** No full iOS app and no score badges this month.
2. **Rider feature = coaching/smoothness, not safety.** No Tesla branding; no hard-brake magnitude penalty.
3. **Gear is deferred upside**, not a dependency.
4. **iOS stays Phase-0 shaped:** entitlement + desk tests only; SwiftUI gated.
5. **One ride, many sensors:** combine reliability observation with gyro/accel/GPS logging.

### Experiments / spikes
| Spike | Pass looks like | Fail looks like |
|---|---|---|
| Instrumented Android ride | Usable accel/gyro traces; can see real brake vs vibration by eye | Noise swallows events → delay scoring indefinitely |
| iOS unicast desk test | Dash answers unicast `:2000` | Broadcast-only → multicast entitlement becomes hard gate |
| Hotspot persistence | Screen-off hold ≥20–30 min on Android (baseline) before judging iOS | Can’t hold Android screen-off → iOS irrelevant |
| Tile/router legality | Candidate OpenFreeMap/OSRM self-host or public compliant source chosen | Still on scraped Google at “ship” time |

### Kill / defer
- Full SwiftUI Northstar
- Rider levels/Bronze–Platinum UI
- CAN dongle / Wingman clone
- Mid-ride nags
- Silent-audio keep-alive hacks as a product strategy
- KMP “share everything” rewrite

### Next actions (ranked)
1. **This week:** Add gyro+accel+GPS logging behind a lab flag; do one real screen-off ride; keep notes on thermals/reconnect/joystick.
2. **Same week:** File Apple Multicast Networking entitlement (parallel, low effort).
3. **Next:** Analyze the log; either draft smoothness thresholds or write “IMU not viable in tank bag” and stop.
4. **Next:** Pick non-Google basemap path (helps future iOS + distribution).
5. **Only then:** iOS desk Phase 0 (joinOnce=false, unicast try, VT SPS dump, interface pin).
6. **Only after thresholds:** Post-ride coaching card (no levels required for v0).

### One-line Blue summary
**Instrument the Android ride you already take; treat iOS as paperwork + desk physics; treat the “Tesla score” as post-ride smoothness coaching that must earn its numbers — gear can wait.**
