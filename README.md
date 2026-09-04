# Hotel Hermes 🏨

> A multiplayer roguelite survival horror experience on Roblox.

---

## 📖 Features
* **Atmospheric 1920s Art Deco World**: Handcrafted and procedurally generated modular hotel environments.
* **Procedural Floor Generation**: Unique floor layouts with corridors, guest suites, service kitchens, and secret libraries.
* **Push-Your-Luck Elevator Mechanics**: Decide after every cleared floor whether to risk your collected coins to ascend higher, or check out to safety.
* **Full Luau Architecture**: Strict server-authoritative state machine, anti-exploit velocity validation, ProfileStore persistence, and external Supabase analytics.
* **Interactive Tooling**: Handheld flashlight with dynamic battery drain, throwables, keycards, and safe code clues.

---

## 📁 Repository Structure
```
hotel-hermes/
├── assets/
│   └── blender/               # Exported 3D FBX assets
├── database/
│   └── migrations/            # Supabase PostgreSQL schema migrations
├── docs/                      # Game concept and technical architecture
├── scripts/                   # Studio build, query, and automation scripts
├── server/                    # Python analytics bridge and external server
├── src/                       # Master Luau source code
│   ├── ReplicatedStorage/     # Shared modules and Remotes
│   ├── ServerScriptService/   # Server managers and state controllers
│   ├── StarterGui/            # UI layout builders
│   └── StarterPlayer/         # Client controller scripts
├── .gitignore
├── task.md
└── README.md
```

---

## 🛠️ Tech Stack
* **Roblox Studio** (Luau 5.1 / Luau Typed)
* **Blender 5.2.1 LTS** (Headless 3D procedural modeling)
* **Supabase** (PostgreSQL database with Row Level Security)
* **Python 3.14** (MCP bridge & proxy tools)
