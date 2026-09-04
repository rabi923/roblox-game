# Hotel Hermes — Technical Architecture & Considerations

## Architecture Overview
* **Engine**: Roblox Studio (Luau) with `StreamingEnabled = true` for memory-efficient multi-floor rendering.
* **Backend Database**: Supabase PostgreSQL (`obxymjtkwjbrqwcslmpk`) with Row Level Security (RLS) and real-time analytics.
* **3D Asset Pipeline**: Headless Blender 5.2.1 procedural generation exporting standard `.fbx` assets directly into `assets/blender/`.
* **Automation & Integration**: Custom MCP proxy bridging Roblox Studio WebSocket RPC (`127.0.0.1:13469`).

---

## Server Authority & Anti-Exploit
1. **Movement & Physics Sanity**:
   - `AntiExploit.lua` continuously evaluates character horizontal and vertical velocity.
   - Sudden coordinate jumps trigger rubberbanding to the last confirmed valid cell.
   - Raycast line-of-sight checks prevent noclip wall clipping.

2. **Network Security**:
   - `RemoteValidator.lua` validates all remote arguments with strict type and rate-limit enforcements (max 10 requests/sec per client).
   - All critical transactions (purchases, puzzle completions, elevator transitions) are 100% server-authoritative.

3. **Data Persistence**:
   - `DataManager.lua` utilizes ProfileStore session locking to prevent duplicate item duplication or data race conditions.
   - `APIBridge.lua` transmits run records, floor records, and global leaderboard telemetry asynchronously to Supabase.

---

## Performance & Optimization
* Modular prefab rooms align to a 32-stud grid coordinate system (`Constants.Architecture.CellSize = 32`).
* Shadow-casting lights are throttled to active player rooms.
* SoundService acoustics are dynamically altered based on zone tags using `StoneRoom` and `Hallway` reverb profiles.
