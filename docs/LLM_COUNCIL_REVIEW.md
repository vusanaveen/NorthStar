# LLM Council Review — Northstar Research Package

**Date:** 2026-09-06  
**Method:** Karpathy-style 3-stage council (independent reviews → anonymized peer rank → chairman synthesis)  
**Scope:** `docs/IOS_PORT_RESEARCH.md`, `docs/RIDER_SCORE_RESEARCH.md`, priorities vs Android core

## Council

| Seat | Model | Role |
|---|---|---|
| A | GPT-5.6 Terra | Stage 1 review |
| B | Claude Opus 5 | Stage 1 review |
| C | Gemini 3.8 Flash | Stage 1 review |
| D | Grok 4.6 | Stage 1 review |
| Peers | Claude Opus 5 + GPT-5.6 Terra | Stage 2 anonymized ranking |
| Chair | Claude Opus 5 (xhigh) | Stage 3 synthesis |

### Peer ranking (best → worst)

| Ranker | Order |
|---|---|
| Claude | B → D → C → A |
| GPT | D → B → C → A |

**Consensus top tier:** B and D · **Middle:** C · **Weakest but still useful:** A  
(Note: A ranked last on review polish but carried a load-bearing physics catch that the chair upheld.)

---

## Chairman verdict

**Sound direction, unsafe in the details. 6.5/10 — accept the research, do not build from it as written.**

Protocol archaeology is strong and spike-gating is correct. Both docs are over-confident where they should be conditional: the iOS doc omits hard Apple gates, and the Rider Score doc ports car physics onto a leaning motorcycle.

---

## MUST-FIX (applied or tracked)

### iOS port doc

1. Multicast Networking entitlement is a **§0 gate** for UDP broadcast `:2000`
2. `NSLocalNetworkUsageDescription` required for local UDP
3. `joinOnce = true` is wrong for screen-off rides → persisted hotspot + Forget dash
4. Interface pinning (`NWParameters.requiredInterface`) is mandatory (dash Wi-Fi + cellular tiles)
5. VideoToolbox ≠ MediaCodec framing (AVCC vs Annex-B; 526 width padding/SPS risk)
6. Resolve CPU-dash vs Android MapLibre-dash TODO contradiction cross-platform
7. Google scraped tiles + OSRM demo are distribution/App Review blockers
8. Delete false-precision effort table (or mark speculative)

### Rider Score doc

9. Cornering model: use `a_lat ≈ v·ω_yaw` + gyro; do not low-pass “gravity” during leaned turns
10. Do **not** penalize hard braking magnitude on a bike — score brake modulation/jerk post-ride
11. Tesla `115.38 − 22.53×PCF` / 0.3g / 0.4g are **v1.0 historical**, not “v3.x”
12. Rename to coaching / smoothness; no Tesla branding; no safety/insurance claims

---

## Agreed priorities (this month)

1. **Instrumented Android ride** — 50 Hz accel **+ gyro** + GPS, screen-off, tank-bag mount (data only)
2. **Android reliability hardening** — reconnect / Wi-Fi settings / open dash items
3. **File iOS multicast entitlement request now** (unbounded latency, zero build cost)
4. **Get basemap + router off Google tiles / OSRM-demo**
5. **Rider Score v1** only after thresholds come from your own logs (post-ride card)
6. **iOS Phase 0** — desk tests before bike; no SwiftUI until pass

---

## Go / no-go

| Item | Ruling |
|---|---|
| **iOS Phase 0** | **CONDITIONAL GO** — entitlement filed; doc fixes 1–7; desk unicast/VT/pinning pass first; no SwiftUI yet |
| **Rider Score logging** | **GO** — gyro-inclusive capture now |
| **Rider Score UI / levels** | **NO-GO** until physics + naming fixed and thresholds from real rides |

---

## Residual uncertainties

- Does the dash accept **unicast** control on `:2000`? (Would sidestep multicast entitlement.)
- Will Apple grant multicast for this use case?
- Does VideoToolbox SPS for width 526 survive the dash whitelist?
- Does soft tank-bag mounting destroy `v·ω` lean estimates?
- Will `0x0C` / `0x0F` ever populate on a future firmware?

---

## Crisp recommendation

Fix the twelve doc items, file the Apple multicast request the same day, then spend build time on **one instrumented Android screen-off ride that logs gyro + accel + GPS**. You are the only user, on a Nothing Phone; without that log, score and iOS work are guesses.

---

## Stage-1 scorecard

| Member | Score | One-line |
|---|---|---|
| A | 6/10 | Right Android-first instinct; thinner on entitlements |
| B | 7/10 | Best source verification + MapLibre divergence catch |
| C | 6/10 | Sharp safety/physics warnings; less implementable detail |
| D | 6.5/10 | Best iOS mechanics (`joinOnce`, SPS pad, device context) |
| Chair | 6.5/10 overall package | Accept research; patch before building |
