# Northstar — iOS Port Research

**Status:** research complete (2026-09-06) · **council-amended** · **Conditional Phase 0 only**  
**Repo cross-checked:** `https://github.com/vusanaveen/NorthStar.git` (public fork @ `4d872c91`)  
**Goal:** same product as Android — phone-screen-**OFF** Tripper navigation over the bike Wi-Fi.  
**Council review:** [`LLM_COUNCIL_REVIEW.md`](LLM_COUNCIL_REVIEW.md) (2026-09-06) — accept direction; do not build from the first draft as written.

> Independent / unofficial interoperability with hardware the rider already owns.
> Validated Android reference target: Tripper firmware **11.63**.

### Council amendments (must-read before Phase 0)

1. **Multicast Networking entitlement** (`com.apple.developer.networking.multicast`) is a **day-zero gate** if control TX stays UDP **broadcast** to `192.168.1.255:2000`. File the Apple request immediately; latency is unbounded and refusal is possible. First desk-test whether the dash accepts **unicast** to `192.168.1.1:2000` — that may avoid the entitlement.
2. **`NSLocalNetworkUsageDescription`** (+ Local Network prompt) is required for local UDP RX on `:2002`.
3. Prefer a **persisted** `NEHotspotConfiguration` (`joinOnce = false`) plus explicit “Forget dash”. `joinOnce = true` drops the network when the app leaves foreground / sleeps and will fail a screen-off ride.
4. **Interface pinning is mandatory**, not optional: pin dash UDP to Wi-Fi via `NWParameters.requiredInterfaceType = .wifi` (or `IP_BOUND_IF`) so tiles/routing keep using cellular — same class of bug Android already fixed with `Network.bindSocket`.
5. **VideoToolbox ≠ MediaCodec framing.** Expect AVCC length-prefixed NALs + out-of-band SPS/PPS; convert to the dash’s Annex-B/RTP expectations. Width **526 is not 16-aligned** — spike must dump SPS and confirm the dash does not reject padded 528 / crop flags.
6. **Renderer strategy must match Android’s roadmap.** This doc’s “CPU forever” conflicts with `TODO.md` interest in offscreen MapLibre for the dash basemap. Pick one cross-platform approach before writing SwiftUI.
7. **Distribution blockers travel with the port:** unofficial Google raster tiles + public OSRM demo are App Review / ToS risks. Move basemap/router before any store/TestFlight push.
8. Effort tables below are **speculative** — treat as order-of-magnitude only.

---

## 1. Executive verdict

| Question | Answer |
|---|---|
| Can we reuse the dash protocol? | **Yes.** K1G + RSA/AES auth + H.264/RTP is platform-agnostic. |
| Is VideoToolbox a MediaCodec equivalent? | **Mostly**, for 526×300 Baseline @ 2–4 fps / 100–200 kbps — but bitstream framing/SPS shape must be spike-validated (not a line-for-line port). |
| Will silent Wi-Fi join work like Android? | **No.** Needs `NEHotspotConfiguration` (user prompt). Prefix `RE_*` discovery is weaker. |
| Will screen-off streaming work? | **Unknown — #1 risk.** Must spike before a full Swift UI port. |
| Can we use MapLibre Metal for the *dash* frames in background? | **No (likely).** iOS blocks background GPU. Until a shared renderer decision exists, assume **CPU-rendered** dash frames (CoreGraphics → CVPixelBuffer). |
| Recommended next step | File multicast entitlement + desk Phase 0 (unicast?, VT encode, interface pin). **No SwiftUI** until that passes. Android on-bike hardening still outranks iOS product work. |

---

## 2. What the Android repo actually is (cross-check)

Single-module Kotlin app (~12.4k LOC, 73 `.kt` files).

| Area | LOC (approx) | Portability |
|---|---|---|
| `dash/protocol` (K1G, commands) | ~420 | **Port as-is → Swift** |
| `dash` session/auth/socket/wifi | ~rest of ~3.0k dash | Auth/session/UDP portable; Wi-Fi Android-only |
| `dash/video` (encode + NAL + RTP) | ~340 | NAL/RTP portable; MediaCodec → VideoToolbox |
| `dash/map` (Canvas 526×300 + Google raster tiles) | ~690 | Reimplement with CoreGraphics + URLSession |
| `dash/nav` (OSRM, geometry, voice) | ~460 | Logic portable; TTS → `AVSpeechSynthesizer` |
| `data` (SQLite + optional Firebase) | ~2.0k | SQLite/GRDB + Firebase iOS SDK |
| `viewmodel` | ~1.9k | Rebuild against SwiftUI / Observation |
| `ui` | ~4.5k | Native SwiftUI rewrite |
| `media` (now-playing / calls) | ~285 | Different APIs; expect reduced call control |

### Dash wire contract (from code — source of truth)

| Item | Value | File |
|---|---|---|
| Dash AP | `192.168.1.1` | `DashSocket.kt` |
| Control TX | UDP broadcast `192.168.1.255:2000` | `DashSocket.kt` |
| Control RX | UDP `:2002` (open **before** first TX) | `DashSocket.kt` |
| Video | H.264/RTP UDP `192.168.1.1:5000` | `DashSocket.kt` |
| SSID | prefix `RE_`, factory pwd `12345678` | `DashConfig.kt` |
| Frame | **526 × 300**, Baseline L4.1, IDR every 1 s | `DashEncoder.kt` |
| Cadence | **4 fps / ~200 kbps** active · **2 fps / ~100 kbps** idle | `DashEncoder.kt` / ViewModel |
| Auth | RSA-1024 PKCS#1 + AES-256 session (`ssid ‖ aesKey`) | `DashAuth.kt` |
| Packet | K1G TLV framing (outgoing vs incoming headers differ) | `K1GPacket.kt` |
| Reference | [better-dash](https://github.com/norbertFeron/better-dash) (Apache-2.0) | NOTICE / comments |

### Two map pipelines (important for iOS)

1. **In-app UI map** — MapLibre + OpenFreeMap (phone screen).
2. **Dash stream map** — custom **Canvas** + raster tiles → MediaCodec. This is the product path.

On iOS, (1) can be MapLibre Native iOS. (2) must **not** depend on Metal while the app is backgrounded.

---

## 3. Cross-check vs existing repo notes

`TODO.md` already flagged iOS as “much later” with the right instincts:

- Protocol is the durable asset.
- Blockers are Wi-Fi join + screen-off background work.
- Spike those **before** a UI port.

`CLAUDE.md` still says **“Android only. No iOS.”** — treat that as the *current product constraint*, not a ban on research. This doc is the research track; shipping iOS still requires flipping that decision after the spike.

`README.md` is Android-only (Obtainium / APK). No contradiction.

**Nothing about a prior diffusion / ML research plan exists in this repo** (searched tree, commits, cloud-agent history for this environment). This iOS work is a fresh track.

---

## 4. Platform gap analysis

### 4.1 Wi-Fi join — HIGH risk, workable with UX cost

| Android today | iOS equivalent |
|---|---|
| `WifiNetworkSpecifier` + prefix `RE_*` | `NEHotspotConfiguration(ssid:password:)` — **exact SSID**, system prompt |
| `bindProcessToNetwork(dash)` | No full equivalent; join dash Wi-Fi, keep cellular for internet where OS allows |
| Scan for `RE_*` | No general Wi-Fi scan API for 3rd-party apps |

**Implications**

- First connect: user must confirm the dash network (acceptable once per ride if `joinOnce = true`).
- Prefer **remembered exact SSID** after first pair (mirror Android’s learn-and-save behaviour).
- No-internet AP will trigger captive-portal / “no internet” behaviour — expect a Settings fallback path and clear in-app copy.
- Optional Hotspot Helper entitlement is **not** a realistic dependency for a community app.

### 4.2 Screen-off / background streaming — CRITICAL unknown

Android keeps a `connectedDevice|location` FGS + Wi-Fi/wake locks.

iOS options to evaluate in the spike:

| Lever | Role | Caveat |
|---|---|---|
| Background **Location** (`location` mode) | Keep process alive while riding | Must be legitimate GPS use (it is — nav) |
| Background **Audio** | Sometimes used as a keep-alive | App Review risk if there’s no real audio product need; prefer real voice prompts instead of silent hacks |
| `beginBackgroundTask` | Seconds only | Useless for a multi-hour ride alone |
| VoIP / PushKit | Not applicable | Don’t fake it |

**GPU trap:** MapLibre Metal rendering in background hits  
`kIOGPUCommandBufferCallbackErrorBackgroundExecutionNotPermitted`.  
→ Dash frames = **CPU path** (CoreGraphics or pre-rasterized tiles → `CVPixelBuffer` → `VTCompressionSession`).

### 4.3 Encode / RTP — LOW risk

`VTCompressionSession` H.264 Baseline, 526×300, 2–4 fps, low bitrate is well within VideoToolbox.  
Port `NalProcessor` + `RtpPacketizer` almost line-for-line (SPS constraint-byte rewrite included — dash-critical).

### 4.4 Everything else — MEDIUM, boring

| Feature | iOS approach |
|---|---|
| In-app map | MapLibre Native iOS |
| Routing | Same public OSRM HTTP API (plan online) |
| TTS | `AVSpeechSynthesizer` + system sounds |
| Garage / fuel / rides | GRDB or SQLite.swift; same schema |
| Sync | Firebase Auth + Firestore iOS SDKs (optional) |
| Share destination | Share Sheet / URL schemes (`maps.apple.com`, Google Maps share) |
| Now playing | `MediaPlayer` / Notification Center — read OK; control limited |
| Calls | Display + limited actions; no reliable answer/end like Android Telecom |
| Updates | TestFlight or AltStore/IPA — not Obtainium |

---

## 5. Proposed architecture (if spike passes)

```
┌─────────────────────────────────────────────┐
│ SwiftUI app (native UI)                     │
│  Home · Route · Dash · Garage · Rides · Set │
└───────────────┬─────────────────────────────┘
                │
┌───────────────▼─────────────────────────────┐
│ Shared dash core (Swift package)            │
│  K1G framing · Auth · Session FSM           │
│  NAL / RTP · Nav math · Tile URL logic      │
└───────────────┬─────────────────────────────┘
                │
     ┌──────────┼──────────┐
     ▼          ▼          ▼
 NEHotspot   NWConnection  VTCompressionSession
 Config      UDP 2000/02   + CoreGraphics map
             + RTP 5000    (CPU, background-safe)
```

**Do not** start with Kotlin Multiplatform for v1 — the risky surface is Apple platform APIs, not sharing business logic. A clean Swift port of the ~1k LOC protocol/video/nav core is faster to validate. Revisit KMP only if Android+iOS both stay active long-term.

---

## 6. Phased plan

### Phase 0 — Feasibility spike (1–2 ride days) ✅ gate

Build a minimal iOS test harness (even a single screen):

1. `NEHotspotConfiguration` join to a known Tripper SSID / `12345678`.
2. Open RX `:2002`, TX broadcast `:2000`, run RSA/AES auth (port `DashAuth` + `K1GPacket`).
3. CPU-draw a static 526×300 test pattern → VideoToolbox → RTP `:5000`.
4. Lock phone, screen off, ride 20–30 min with continuous GPS + encode + UDP.
5. Record: join UX, captive-portal nags, background kills, thermal, battery.

**Pass criteria:** stream stays up screen-off for a real ride without manual foregrounding.  
**Fail:** either Wi-Fi or background encode is a hard wall → stop; keep Android-only.

### Phase 1 — Dash nav MVP (only if Phase 0 passes)

- Port session FSM, joystick TLVs, motion-adaptive 2/4 fps.
- CoreGraphics map + raster tiles + OSRM route overlay.
- Location + reroute + ETA pill.
- Voice: off / chime / full.

### Phase 2 — Parity features

- Garage, fuel, rides (SQLite).
- Optional Firebase sync.
- Share-to-Northstar from Maps.
- Settings (SSID remember / forget).

### Phase 3 — Polish

- Media overlay (best-effort).
- Background reliability hardening across iOS versions.
- TestFlight distribution.

---

## 7. Effort snapshot (order-of-magnitude)

| Work | Estimate |
|---|---|
| Phase 0 spike | 3–5 focused days + bike time |
| Protocol/video/nav Swift port | ~1–2 weeks |
| Dash map CPU renderer | ~1 week |
| SwiftUI shell + route flow | ~1–2 weeks |
| Garage/rides/sync parity | ~1–2 weeks |
| Hardening / TestFlight | ongoing |

Totals assume Phase 0 is green. If Phase 0 fails, stop.

---

## 8. Decisions to lock before coding the full app

1. **Spike-first** — no full SwiftUI port until Phase 0 passes on firmware 11.63.
2. **CPU dash renderer** — never rely on background Metal/MapLibre for the stream.
3. **Exact SSID pairing** — accept one system prompt; persist SSID like Android.
4. **Same unofficial scope** — display + joystick only; never touch ECU / safety systems.
5. **Keep Android as the reference** — iOS must match wire behaviour, not reinvent TLVs.

---

## 9. Immediate checklist

- [ ] Create empty iOS spike Xcode project (local; not required in this Android repo yet)
- [ ] Port `K1GPacket` + `DashAuth` + static RTP test to Swift
- [ ] On-bike: Wi-Fi join + auth + static frame screen-off
- [ ] On-bike: 20–30 min background endurance
- [ ] Write pass/fail into this doc and flip `TODO.md` iOS section from research → build or abandon

---

## 10. References (in-repo)

- `app/.../dash/DashSocket.kt` — ports / bind behaviour  
- `app/.../dash/DashAuth.kt` — RSA/AES handshake  
- `app/.../dash/protocol/K1GPacket.kt` — framing  
- `app/.../dash/video/DashEncoder.kt` — 526×300 / bitrate envelope  
- `app/.../dash/DashWifiManager.kt` — Android join (what iOS must approximate)  
- `TODO.md` § “iOS (much later…)” — prior notes this research supersedes in detail  
- External: better-dash, Apple TN3111 (Wi-Fi API overview), VideoToolbox WWDC21 low-latency encode
