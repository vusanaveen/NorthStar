---
name: ios-northstar-dev
description: Use when developing Northstar iOS, DashCore Swift package, Tripper connect/nav on iPhone, or Phase 0/1/2 iOS port work.
---

# iOS Northstar Development

## Overview

Develop the **phased** iOS port: **connect + navigation first**. Prefer `ios/DashCore` (testable) before UI. Mirror Android wire behaviour — never invent TLVs.

## Phase focus (do not skip)

| Now | Later |
|---|---|
| Phase 0 desk/entitlements | Garage / fuel |
| Phase 1 connect + H.264 stream | Rider score UI |
| Phase 2 nav MVP | Community / delayed guidance |

Plan: `docs/IOS_PHASED_PLAN.md` · Research: `docs/IOS_PORT_RESEARCH.md`

## Hard rules

1. **Android is the wire oracle.** Read `app/.../dash/` before changing Swift protocol code.
2. **DashCore first.** Pure Swift logic + `swift test` on Linux when toolchain available.
3. **Mac for Xcode / device.** Cloud Linux cannot run Simulator or `xcodebuild`. Say so; don’t fake it.
4. **No SwiftUI feature creep** until Phase 1 stream works screen-off.
5. **Tiles:** prefer redistributable sources (OpenFreeMap etc.), not scraped Google, for anything headed to TestFlight.
6. **Safety:** display + joystick only; never ECU / brakes.

## Workflow per task

1. Identify phase (0 / 1 / 2).
2. If protocol/nav math → edit `ios/DashCore`, add/adjust tests, run `swift test`.
3. If platform API (Wi‑Fi, VT, background) → edit `ios/NorthstarApp` notes/sources; note Mac validation steps.
4. Update `docs/IOS_PHASED_PLAN.md` checkboxes when a gate passes/fails.
5. Commit with `ios(dashcore):` / `ios(app):` / `docs(ios):` prefixes.

## Key constants (must match Android)

- Dash `192.168.1.1` · broadcast `.255` · TX `2000` · RX `2002` · RTP `5000`
- Video `526×300` · ~2–4 fps · 100–200 kbps · Baseline
- Auth RSA-1024 + AES-256 · SSID in ciphertext must be exact AP name
- Hotspot: persist config (`joinOnce = false`); pin dash sockets to Wi‑Fi

## Anti-patterns

- Building Garage screens before Connect works
- Copying MediaCodec Annex-B path into VideoToolbox without AVCC conversion
- Silent-audio keep-alive hacks as a shipping strategy
- Assuming multicast entitlement is already granted
- Calling Cloud Agent “done” for on-device stream without Mac/bike proof
