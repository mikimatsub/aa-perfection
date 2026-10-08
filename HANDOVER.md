# Perfection UI (`aa-perfection`) - Agent Handover & Architecture Guide

## 1. Executive Summary
**Perfection UI** is an ElvUI / Tukui-grade total interface overhaul addon for **ArcheAge Classic (AAClassic)**.
- **Repository**: [https://github.com/mikimatsub/aa-perfection](https://github.com/mikimatsub/aa-perfection)
- **Author**: `mikimatsub`
- **Branch**: `main`
- **Target Game Engine**: CryEngine 3 / XLGames Lua 5.1 client runtime.

---

## 2. File Locations & Environment Map

### Local Filesystem Paths
| Purpose | Path | Notes |
| :--- | :--- | :--- |
| **Git Working Tree** | `d:\Repos\Github\aa-perfection\` | Main development repository |
| **Active Installed Addon** | `C:\AAClassic\Documents\Addon\aa-perfection\` | Junction to `C:\Users\chewy\OneDrive\Documents\AAClassic\Addon\aa-perfection\`. Game reads here! |
| **Addon Manifest** | `C:\AAClassic\Documents\Addon\addons.txt` | Must contain `aa-perfection` |
| **Addon Enabled Config** | `C:\AAClassic\Documents\Addon\addon_settings` | Lua table containing `aa_perfection = { enabled = true }` |
| **Game Installation** | `C:\Games\AAClassic\` | Client binary at `bin32\archeage.exe` |
| **Game Live Logs** | `C:\Users\chewy\OneDrive\Documents\AAClassic\ArcheAge.log` | Lua print / error logs appear here |
| **Reference Addon Catalog** | `C:\Users\chewy\.gemini\antigravity\brain\4f32a52d-1f93-4b15-aebf-da660faa1285\scratch\ref\` | Complete raw source of 8 working AAC addons (BetterBars, WorldSatNav, nuzi-ui, ESCMenu, etc.) |
| **API Whitelist Extraction** | `C:\Users\chewy\.gemini\antigravity\brain\4f32a52d-1f93-4b15-aebf-da660faa1285\scratch\api_whitelist.json` | Extracted ground-truth API functions, events, and UIC constants |

### Syncing Workflow
Any changes made in `d:\Repos\Github\aa-perfection\` must be mirrored to the game directory using robocopy:
```powershell
robocopy "d:\Repos\Github\aa-perfection" "C:\AAClassic\Documents\Addon\aa-perfection" /MIR /XD .git
```
Then commit and push:
```powershell
git add .
git commit -m "feat/fix: description"
git push origin main
```

---

## 3. Engine Realities & Critical Gotchas (Read Carefully)

1. **No `_G` in Addon Sandbox**:
   - The AAC addon environment executes chunks with private environments (`setfenv`). Attempting to index global `_G` throws `attempt to index global '_G' (a nil value)`.
   - Access globals directly or verify `if _G ~= nil then ... end`.

2. **Slash Command Limitations ("Not in raid" error)**:
   - When a player types `/pui edit` into general chat, ArcheAge's engine parser intercepts any command starting with `/` before addons receive it. Because `/p` or `/p...` can be parsed as party/raid commands by the native client, typing `/pui` can result in the engine message `"Not in raid"`.
   - **Recommended access**:
     - Provide interactive UI buttons for controls (e.g. `[ Edit ]` and `[ Settings ]` on the Micro-Bar).
     - Hook `OnSettingToggle()` which fires when the player clicks the native addon settings button in the game's ESC menu / Addon Manager.
     - If using chat commands, allow `!pui` instead of `/pui`, as `!` is passed to `CHAT_MESSAGE` without client-side interception.

3. **Quest API Quirk (Why the tracker showed random quests)**:
   - `api.Quest:GetActiveQuestTitle(qId)` returns a non-nil title for **any valid quest in the entire game database** (even IDs 1 to 250 that the player is not currently on).
   - Iterating `for qId = 1, 250` will populate hundreds of unrelated quests.
   - To get active player quests, either read the active quest list via `UIC.QUEST_WATCH` / `UIC.QUEST_LIST` content widgets or hook native quest watch events (`QUEST_TASK_READY`, `CHAT_MSG_QUEST`).

4. **Screen Resolution & Fixed Offsets**:
   - Hardcoded coordinates like `x = 1630, y = 1040` (designed for 1920x1080) cause frames to be cut off or positioned off-screen on different resolutions or windowed modes.
   - Always query screen dimensions dynamically:
     ```lua
     local screenW = api.Interface:GetScreenWidth()
     local screenH = api.Interface:GetScreenHeight()
     ```
   - Anchor elements relative to `UIParent` edges (`TOPRIGHT`, `BOTTOMRIGHT`, etc.) rather than absolute top-left offsets.

5. **Stock Frame Banishment**:
   - ArcheAge engine C++ calls `Show(true)` on `UIC.TARGET_UNITFRAME` whenever a new unit is targeted.
   - Simply calling `wnd:Show(false)` at startup is overridden on target change.
   - Solution already in place in `modules/unitframes/target_frame.lua`: move to `TOPLEFT -3000, -3000`, set `alpha = 0`, and attach an `OnShow` callback that re-hides and moves it offscreen.

---

## 4. Codebase Directory Map & Module Responsibilities

```
d:\Repos\Github\aa-perfection\
├── addon.txt                     # Addon metadata declaration
├── main.lua                      # Addon entrypoint (OnLoad, OnUnload, OnSettingToggle, tickers)
├── HANDOVER.md                   # This document
│
├── core/
│   ├── api_guard.lua             # Defensive pcall wrappers for all api.Unit / api.Bag / api.Map calls
│   ├── events.lua                # Normalized ticker engine (fast_hud, unit_frames, slow_gameplay)
│   ├── logger.lua                # Colored in-game logging (api.Log:Info, api.Log:Err)
│   ├── mover.lua                 # Edit Mode drag & repositioning overlay framework
│   ├── settings.lua              # JSON/Table persistence (api.File:Read/Write, GetSettings)
│   ├── settings_page.lua         # Interactive in-game settings modal with module toggle pills
│   └── theme.lua                 # Obsidian palette, ApplyBackdrop, ApplyBorder, StyleLabel, FormatMoney
│
└── modules/
    ├── actionbars/
    │   ├── bar_skinner.lua       # Discovers and skins native action bar slots & hotkey typography
    │   ├── micro_menu.lua        # Sleek 6-pill bottom shortcut bar ([Char], [Bag], [Skills], [Quest], [Map], [Menu])
    │   └── swap_bar.lua          # 6-slot floating situational weapon quick-swap bar
    │
    ├── chat_quest/
    │   ├── chat_styler.lua       # Skins chatTabWindow with dark glass backing, modern tab pills, and edit box
    │   └── quest_tracker.lua     # Collapsible ElvUI-grade objectives tracker panel
    │
    ├── combat_hud/
    │   ├── castbar.lua           # 60 FPS player spell casting bar with latency & icon
    │   ├── cc_tracker.lua        # Crowd control alert banner
    │   ├── combo_hud.lua         # Combo points / charges monitor
    │   └── target_nameplate.lua  # 3D floating overhead target nameplate using GetUnitScreenNameTagOffset
    │
    ├── gameplay/
    │   ├── labor_hud.lua         # Live labor power display and generation timer
    │   ├── minimap_styler.lua    # Minimap radar HUD with live coordinates and zone peace/war status
    │   ├── speed_glider.lua      # Dynamic mount and glider speedometer
    │   └── trade_assist.lua      # Specialty trade pack value & percentage HUD
    │
    ├── inventory/
    │   ├── bag_scanner.lua       # Scans bag slots for items, types, and stats
    │   ├── bag_view.lua          # Skins native ADDON:GetContent(UIC.BAG) with obsidian styling
    │   └── categories.lua        # Item categorization logic
    │
    └── unitframes/
        ├── auras.lua             # Buff and debuff display icons with timers
        ├── party_frames.lua      # 5-man party health grid
        ├── player_frame.lua      # Player obsidian health and mana frame
        ├── raid_frames.lua       # 50-man raid grid
        ├── secondary.lua         # Target-of-Target and Focus target frames
        └── target_frame.lua      # Target obsidian health, mana, distance, and gearscore frame
```

---

## 5. Current Component Status & Immediate Tasks

| Component | Status | Next Agent Action Needed |
| :--- | :--- | :--- |
| `bar_skinner.lua` | **Fixed** | Fixed `_G` check at line 26. Ready for testing in-game. |
| `quest_tracker.lua` | **Needs Revision** | Remove raw `for qId = 1, 250` database scan. Re-anchor to use `UIC.QUEST_WATCH` or filter by actual active status. |
| `minimap_styler.lua` | **Working** | Zone name and coordinates work; needs responsive anchor (`TOPRIGHT`, not fixed `x = 1700`). |
| `micro_menu.lua` | **Working** | Ensure anchor uses screen height (`screenH - 30`), not hardcoded `y = 1040`. |
| `mover.lua` & Slash Commands | **Needs Revision** | Add `!pui` support and ensure settings/mover can be toggled directly from the `[ Menu ]` and `[ Edit ]` UI buttons. |
| `bag_view.lua` | **Working** | Skins native bag cleanly without locking interaction. |
| `player_frame.lua` & `target_frame.lua` | **Working** | Stock frames banished, no text overlaps, health & mana responsive. |
| `target_nameplate.lua` | **Working** | Elevated 3D plate hovers cleanly above native nametag. |

---

## 6. Local Test Environment

A Python 3.11 environment with `lupa` (Lua 5.1 runtime) is available on this machine at:
`C:\Python311\python.exe`

You can run automated syntax and block balance verification across all 30 project files at any time:
```powershell
C:\Python311\python.exe "C:\Users\chewy\.gemini\antigravity\brain\4f32a52d-1f93-4b15-aebf-da660faa1285\scratch\check_lua.py"
```
Ensure all files report `OK` before deploying!
