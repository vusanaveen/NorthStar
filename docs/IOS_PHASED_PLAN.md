# Northstar iOS — Phased Plan (Connect + Nav First)

**Goal:** basic **working connect + navigation** on iPhone → Tripper, same product shape as Android.  
**Not yet:** Garage parity, rider score UI, community, polish media/calls.

Aligned with `docs/IOS_PORT_RESEARCH.md` + LLM council + Six Hats.

---

## Phase map

| Phase | Outcome | Gate |
|---|---|---|
| **0 — Desk / entitlement** | Can talk to dash from iOS APIs | Unicast-or-multicast proven; Local Network prompt OK |
| **1 — Connect + stream** | Join Wi‑Fi, auth, static/test H.264 on dash, screen-off hold | Stream survives lock 20–30 min |
| **2 — Nav MVP** | Destination → OSRM route → CPU map on dash + voice + joystick | Real ride works |
| **3 — Parity later** | Garage, rides sync, delayed guidance, coaching | Only after 1–2 green |

**This sprint focus = Phase 0 → 1 → 2.** Stop if Phase 0/1 fails.

---

## Phase 0 — Setup gates (before UI)

- [ ] Apple Developer account (paid) for Hotspot Configuration capability
- [ ] File **Multicast Networking** entitlement (or prove unicast to `192.168.1.1:2000`)
- [ ] Xcode project on a Mac (Cloud Linux agents cannot run `xcodebuild` / Simulator)
- [ ] Info.plist: Local Network, Location (When In Use → Always for screen-off), Wi‑Fi
- [ ] Desk harness: join SSID, RX `:2002`, TX control, print TLVs

**Cloud agent role in Phase 0:** port/test **DashCore** (pure Swift SPM) on Linux Swift; you/Mac run the Xcode harness on device.

---

## Phase 1 — Connect + video (basic working link)

1. `NEHotspotConfiguration` persisted (`joinOnce = false`) + Forget dash
2. Port session FSM: auth → enter nav → projection heartbeats
3. VideoToolbox encode 526×300 + AVCC→Annex-B + RTP `:5000`
4. Interface pin dash UDP to Wi‑Fi; keep cellular for tiles/OSRM
5. Background: location mode + verify screen-off

**Done when:** map or test pattern shows on Tripper with phone locked.

---

## Phase 2 — Navigation MVP

1. Share / enter destination (URL / maps share)
2. OSRM route + polyline on dash map (CPU CoreGraphics / redistributable tiles)
3. GPS snap, next-turn banner, ETA pill
4. Voice: off / chime / full (`AVSpeechSynthesizer`)
5. Joystick pan/zoom mapping (from Android codes)
6. Off-route reroute (needs cellular while on dash Wi‑Fi)

**Done when:** one real ride with turn-by-turn on the dash.

---

## Repo layout (prepared)

```
ios/
  README.md                 # how to open on Mac
  DashCore/                 # SwiftPM — protocol, nav math, RTP (Linux-testable)
  NorthstarApp/             # Xcode app scaffold notes / sources to drop in
.cursor/skills/ios-northstar-dev/
docs/IOS_PHASED_PLAN.md     # this file
```

---

## Efficiency rules for agents

1. Prefer changing **DashCore** first (unit-testable) before UI.
2. Mirror Android wire behaviour — do not invent TLVs.
3. No Garage / score / community work until Phase 2 green.
4. Use skill `ios-northstar-dev` for every iOS coding session.
5. Mac-required steps: call out explicitly; do Linux-safe work in Cloud Agent.
