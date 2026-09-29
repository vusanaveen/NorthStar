# Phase 1 — Connect checklist (Mac + bike)

Use after `DashCore` tests pass.

1. [ ] Create Xcode iOS App **Northstar**, add local package `../DashCore`
2. [ ] Team + bundle id; enable **Hotspot Configuration** capability
3. [ ] Merge `Info.plist.example` usage strings + background location
4. [ ] Apply Multicast entitlement *or* confirm unicast control works
5. [ ] Minimal UI: SSID field (default remembered), Connect button
6. [ ] On Connect: `NEHotspotConfiguration(ssid:password:isWEP:false)` with `joinOnce = false`
7. [ ] Open UDP RX `:2002` before TX; send auth burst; log TLVs
8. [ ] On auth OK: start VTCompressionSession 526×300; send RTP to `:5000`
9. [ ] Lock phone; confirm dash still updates 20+ minutes
10. [ ] Record: captive portal nags, kills, thermal — write into `docs/IOS_PORT_RESEARCH.md`
