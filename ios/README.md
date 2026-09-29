# Northstar iOS

Phased port of Northstar for iPhone → Royal Enfield Tripper Dash.

**Plan:** [`docs/IOS_PHASED_PLAN.md`](../docs/IOS_PHASED_PLAN.md)  
**Research:** [`docs/IOS_PORT_RESEARCH.md`](../docs/IOS_PORT_RESEARCH.md)

## What lives here

| Path | Purpose | Runs on |
|---|---|---|
| `DashCore/` | SwiftPM package: K1G, auth helpers, RTP, geo/nav math | **Linux Swift** (tests) + Mac |
| `NorthstarApp/` | App sources / plist templates to drop into an Xcode project | **Mac + Xcode only** |

## Phase focus

**Phase 1–2 only:** connect + navigation. Not Garage, not rider score UI.

## Mac setup (required for device/Simulator)

1. Xcode 16+ (or current stable), paid Apple Developer team
2. Capabilities: **Hotspot Configuration**, **Access Wi‑Fi Information** (as needed), Location
3. Request **Multicast Networking** entitlement if broadcast TX is required
4. Create an iOS App target, add local package `DashCore`
5. Copy `NorthstarApp/` sources into the target
6. Set bundle id, team, Info.plist usage strings from `NorthstarApp/Info.plist.example`

## Linux / Cloud Agent

```bash
# After Swift toolchain is on PATH:
cd ios/DashCore && swift test
```

Protocol + nav math can be developed and unit-tested here without Xcode.

## Wire contract (do not invent)

- Control TX: UDP broadcast `192.168.1.255:2000` (or unicast `192.168.1.1:2000` if proven)
- Control RX: UDP `:2002`
- Video: H.264/RTP → `192.168.1.1:5000`
- Frame: 526×300, ~2–4 fps, Baseline
- Auth: RSA-1024 PKCS#1 + AES-256 (`ssid ‖ sessionKey`)
- SSID prefix `RE_`, factory password often `12345678`
