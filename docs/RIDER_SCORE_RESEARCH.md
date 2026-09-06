# Rider Score Research — “How well am I riding?” for Northstar / Himalayan 450

**Status:** research (2026-09-06) · not scheduled for build yet  
**Prompt:** Tesla-style driving score / levels, and whether RE’s **digital gear** display helps us do the same.

This is **two engineering problems**:

1. **Scoring model** — what “good riding” means mathematically (Tesla already solved a car version of this).
2. **Signal acquisition on RE** — what sensors/fields we can actually read from phone + Tripper + (maybe) gear.

---

## 1. How Tesla does it (the reference design)

Tesla’s **Safety Score** (now v3.x) is **not** a vibe meter. It is a **risk model**:

1. Measure a few **behavior rates** from vehicle sensors while driving manually.
2. Plug them into a **Predicted Collision Frequency (PCF)** formula (fleet-trained).
3. Map PCF → a **0–100 score** shown in the app (historically ≈ `115.38 − 22.53 × PCF`).
4. Optionally blend with “perfect” assisted miles (FSD) — irrelevant for us.

### Classic factors & thresholds (public Tesla definitions)

| Factor | What they measure | Typical threshold |
|---|---|---|
| **Hard braking** | Longitudinal deceleration | **> 0.3 g** (~6.7 mph drop in 1 s) |
| **Aggressive turning** | Lateral acceleration | **> 0.4 g** (~8.9 mph sideways in 1 s) |
| **Unsafe following** | Time gap to lead car | **< ~1.0 s** headway (mostly at higher speeds) |
| **Excessive speeding** | Absolute / relative speed | e.g. **> 85 mph**, or **>20% faster** than car ahead |
| Forward collision warnings / seatbelt / late-night / forced AP disengage | Car-stack specific | Skip or remap for motorcycle |

Hard braking / aggressive turning are stored as **ratios** (time above harsh threshold ÷ time above a mild threshold), not raw event counts — that normalizes for stop‑and‑go city traffic.

**Product UX Tesla teaches us (steal this shape, not the insurance bit):**

- One headline **0–100** (or letter grade / level).
- Per-factor breakdown (“braking · cornering · speed · smoothness”).
- Trend across trips (“this week vs last”).
- Coaching copy tied to the worst factor — not a wall of charts mid-ride.

We do **not** need Tesla’s insurance PCF constants. We need the **same architecture**:  
`sensors → event rates → weighted score → levels + coaching`.

---

## 2. Problem A — scoring model for a motorcycle

Cars ≠ bikes. Copying Tesla’s weights blindly is wrong (lean is normal; “0.4 g lateral” on a bike can be a clean corner).

### Recommended Northstar factors (v1)

| Factor | Definition (phone-first) | Why it maps to “good riding” |
|---|---|---|
| **Smooth accel** | Peak / p95 longitudinal `+a` while moving | Rewards progressive throttle |
| **Smooth brake** | Peak / p95 longitudinal `−a`; harsh if **> ~0.35–0.45 g** | Same idea as Tesla hard brake, slightly retuned for bikes |
| **Corner composure** | Lateral-g vs speed; jerk (Δa/Δt); lean symmetry L/R | Smooth inputs, not max lean heroics |
| **Speed discipline** | GPS speed vs road limit (OSM maxspeed when known) **or** vs own p85 cruise | Without radar we can’t do “following distance” |
| **Consistency** | Variance of accel / speed in steady segments | Separates calm touring from twitchy inputs |
| **Gear fitness** *(if gear available)* | See §4 | Huge coaching unlock unique to manuals |

### Score shape (proposal)

```
RideScore ∈ [0, 100]
  = 100 − Σ (w_i × penalty_i)

penalty_i = clamp( rate_i / rate_cap_i , 0..1 )   // Tesla-like ratio thinking
levels:   0–59 Bronze · 60–74 Silver · 75–89 Gold · 90–100 Platinum
```

Start with equal-ish weights; tune after 10–20 of *your* rides (single-user app — calibrate to the author, not a fleet).

**Mid-ride:** optional quiet “level chip” or voice tip only on sustained bad patterns (never nag every brake).  
**Post-ride:** full breakdown + one coaching sentence (“braking was choppy in the last 8 km”).

---

## 3. Problem B — where do the signals come from on RE?

### What Tesla has that we don’t

| Tesla | Northstar / Himalayan 450 Tripper |
|---|---|
| Wheel-speed, IMU, radar/cameras fused in vehicle | Phone GPS + phone IMU (today) |
| Canonical CAN telemetry always on | Gear/RPM/speed live on **cluster via CAN**, not clearly on Wi‑Fi projection |
| Fleet ML for PCF | N=1 rider — heuristic score is enough |

### Evidence already in *this* repo

From live captures (fw **11.63**) documented in `TODO.md`:

- Projection session gets joystick + video ACKs.
- **`0x0C` instrument TLVs exist but stayed ~zero** with ignition on.
- **`0x0F` encrypted vehicle telemetry: not observed** in those captures.
- Conclusion so far: **Tripper does not appear to forward speed/odo/fuel/gear to a projection client** the way Tesla streams car telemetry to the phone.

Decrypt/logging for `0x0F` / `0x0C` stays in `DashSession` (good) — if a future firmware ever forwards fields, gear becomes free. **Do not block Rider Score on that.**

### Three acquisition tiers

| Tier | Source | Fields | Effort | Verdict |
|---|---|---|---|---|
| **T0 — Phone only (ship first)** | GPS + `Sensor.TYPE_LINEAR_ACCELERATION` / game rotation | speed, heading, long/lat g, lean estimate, jerk | Low — we already record GPS in `RideRecorder` | **Do this** |
| **T1 — Dash telemetry if unlocked** | K1G `0x0C` / `0x0F` | speed, RPM, gear?, fuel, temps | Medium — field map unknown; may stay dead | Keep logging; opportunistically parse |
| **T2 — Hardware tap** | CAN/OBD / aftermarket ECU bridge | true gear, RPM, throttle, brake switch | High — extra device, not “just the app” | Out of scope unless you want a garage project |

External RE research (Bear 650 / Visteon K‑Dash stack) agrees: **cluster gets gear/RPM/speed from CAN; phone↔dash Wi‑Fi is mostly nav/settings**, while odo/fuel “connected” data often comes from a **Wingman → cloud** path — not from the nav projection pipe Northstar uses.

---

## 4. Why digital gear *would* help (and how far we can fake it)

Himalayan 450 already shows **gear position** + **upshift advisor** (gear × RPM × TPS) on the cluster. That’s exactly the signal a rider-coach wants.

### If we ever get live `gear` (+ ideally RPM)

Add a **Gear Fitness** factor:

- Detect **lugging** (high gear + low speed + rising longitudinal demand).
- Detect **revving / late upshift** (low gear + high speed or high RPM).
- Score **shift smoothness**: time from clutch/accel dip to settle (proxy without clutch switch: longitudinal jerk spike + speed plateau).
- Align with RE’s own upshift-advisor intent: reward being in the gear the bike “wants.”

### Without gear (T0) — still useful proxies

| Proxy | Method | Quality |
|---|---|---|
| Shift events | Sudden accel hole + speed continuity (clutch blip pattern) | Weak/medium |
| “Wrong gear feel” | Accel efficiency: Δspeed / long-g over windows | Weak |
| Engine braking vs friction braking | Decel with low long-g vs spike long-g | Medium |
| True gear 1–6 / N | **Needs T1 or T2** | — |

**Bottom line:** digital gear is **high leverage for coaching quality**, but **not required** to ship a Tesla-like score. Ship T0 smoothness/speed score; treat gear as a **v2 multiplier** if telemetry or CAN ever lands.

---

## 5. Concrete architecture for Northstar

```
LocationTracker (1 Hz GPS) ──┐
Phone IMU (25–50 Hz) ────────┼──► RideDynamicsEngine ──► RideScore (0–100)
Dash 0x0C/0x0F (optional) ───┘         │                 + FactorBreakdown
                                       ▼
                              RideRecorder / Ride entity
                                       │
                              Post-ride UI + optional level badge on Home
```

### New pieces (when we build)

| Component | Responsibility |
|---|---|
| `RideDynamicsEngine` | Buffer IMU+GPS; compute long/lat g in bike frame; detect harsh events; rolling rates |
| `RideScore` model | Weighted penalties → 0–100 + level enum |
| `Ride` DB fields | `score`, `scoreVersion`, JSON factor bag |
| UI | Post-ride card first; optional glanceable level after disconnect |

### Sensor notes (phone in tank bag)

- Mount attitude unknown → estimate gravity vector over 2–3 s windows; project accel into long/lat.
- Prefer `LINEAR_ACCELERATION` + rotation vector; discard when GPS accuracy bad (same gate as `RideRecorder`).
- Tank-bag soft mount adds vibration → **low-pass** (~2–5 Hz) before thresholds or you’ll false-flag every gravel patch.
- Never use this for safety-critical warnings that could distract mid-corner; post-ride first.

### Battery / thermal

Northstar’s whole point is screen-off efficiency. IMU at 50 Hz is cheap vs the H.264 path; still:

- Run dynamics only while `DashState.STREAMING` or an explicit “record ride” flag.
- Downsample stored traces; keep event list, not raw 50 Hz forever.

---

## 6. What we will *not* copy from Tesla

- Insurance / PCF marketing claims.
- Following-distance / FCW (no forward radar on phone).
- Seatbelt / FSD disengagement factors.
- Punishing **lean itself** — lean is the point of a bike; punish **jerky** lean / panic upright / trail-brake spikes instead.

---

## 7. Suggested build order (when prioritized)

1. **Spike (half day):** log IMU long/lat g on a short ride; verify tank-bag noise vs real brake events; pick thresholds.
2. **v1 score:** smoothness (accel/brake) + corner composure + speed variance → post-ride 0–100 + level.
3. **v1.1:** OSM speed-limit overlay when map match knows the road.
4. **v2:** if `0x0C`/`0x0F` ever yields gear/RPM → Gear Fitness factor + shift coaching.
5. **Explicit non-goal unless requested:** CAN dongle / Wingman clone.

---

## 8. Decision summary

| Question | Answer |
|---|---|
| How does Tesla do it? | Sensor event **rates** → risk formula → **0–100** + factor breakdown |
| Can we do that on RE? | **Yes, phone-first**, same product shape |
| Does digital gear help? | **Yes, a lot for coaching** — but it’s on CAN/cluster; **not proven on K1G projection** |
| Blocker? | None for v1. Telemetry gear is a **bonus path**, keep decrypt logs alive |
| Fit with Northstar? | Post-ride analytics on sessions we already record; don’t fight the screen-off nav core |

---

## References

- Tesla Safety Score factor definitions / PCF writeups (public app explanations; ETH Risk Day slides summarizing Tesla’s published formulas).
- In-repo: `TODO.md` P1b telemetry notes; `DashSession` `0x0C`/`0x0F` logging; `RideRecorder` GPS session capture.
- RE Himalayan 450 manual: gear position + gear upshift indicator (RPM × gear × TPS).
- Community RE connected-stack notes: cluster Wi‑Fi ≠ CAN instrument bus; Wingman/cloud for some connected fields.
