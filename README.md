# Perfection UI (ArcheAge Classic)

[![GitHub Release](https://img.shields.io/badge/version-1.0.0-gold.svg)](https://github.com/mikimatsub/aa-perfection)
[![ArcheAge Classic](https://img.shields.io/badge/game-ArcheAge%20Classic%201.3.5+-blue.svg)](https://aa-classic.com)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Perfection UI** is the definitive, zero-setup, performance-engineered interface overhaul addon for **ArcheAge Classic (AAClassic)**.

Built from the ground up on verified AAClassic Addon API mechanics, it replaces dated legacy elements with the obsidian-and-gold **Apex Obsidian** tactical design system, engineered for 140+ FPS performance in 100v100 siege warfare, open naval combat, and sandbox trade.

---

## Complete Feature Matrix

### 1. Next-Gen Smart Inventory
- **Automatic Smart Categorization**: Instant segmentation into **Gear**, **Consumables**, **Regrade & Enchant**, **Crafting Materials**, and **Trade / Cargo**.
- **Real-Time Keyword Search**: Instant slot filtering as you type.
- **Capacity & Currency**: Free slot capacity indicator and clean formatted Gold, Silver, and Copper tokens.
- **Stock Bag Replacement**: Automatically intercepts default keybinds (`I`) and suppresses legacy bag windows.

### 2. Apex Obsidian Unit Frames
- **Player Frame**: Sleek obsidian frame with smooth health bar, mana bar, level badge, and player name.
- **Target Frame**: Reactive Hostile (Red) vs. Friendly (Cyan) health gauge, distance in meters, character class, and Gear Score (GS).
- **Secondary Frames**: Compact Target-of-Target (`targettarget`) and dedicated Focus / Watch Target (`watchtarget`) frames.
- **50-Man High-Performance Raid Grid**: 5x10 dynamic grid with role coloring (Attacker Crimson, Defender Gold, Healer Pink), priority debuff tracking (Petrify, Enervate, Bubble, Leech, Telekinesis), missing HP badges, and offline/dead states.
- **Party Frames**: Clean 5-man party layout with individual HP, MP, and distance indicators.

### 3. Combat HUD
- **Player Cast Bar**: Animated casting bar with spell icon, current/total timers, and completion flash.
- **Crowd Control Danger Banner**: High-contrast alert badge surfacing active CC debuffs (Stun, Trip, Sleep, Bubble, Silence, Fear).
- **Abyssal Charge Tracker**: 4-orb luminous display tracking active Abyssal power.
- **Aura & Buff/Debuff Manager**: Clean buff rows with formatted remaining durations (`12s`, `4m`, `1h`) and red debuff outlines.

### 4. Trade, Naval & Gameplay Systems
- **Live Speedometer**: Real-time 3D movement velocity calculation in `m/s` for gliders, mounts, and vehicles.
- **Labor Power Engine**: Live tracking of current labor points (0 to 5,000 LP).
- **Trade Pack Assistant**: Detects equipped packs/cargo and displays live seller payout share percentage.
- **Quick-Swap Equipment Bar**: Floating bar for fast 1-click weapon, shield, and gear set swapping.
- **Modernized Quest Tracker**: Compact, collapsible objective tracker with auto-formatting.
- **Obsidian Chat Styler**: Minimalist translucent backing for chat windows.

### 5. In-Game Settings & Edit Mode
- **Interactive Settings GUI (`/pui settings`)**: Toggle any module on or off in real-time without reloading the client.
- **Performance Presets**:
  - **Balanced (Default)**: Full visual fidelity across all systems.
  - **Zerg / Raid Mode**: Maximum combat FPS optimization for 50v50 mass PvP.
- **Visual Edit Mode (`/pui edit`)**: Highlight boxes appear over all frames. Drag and drop anywhere on screen, with persistent coordinate saving across sessions.

---

## Installation Guide

### Option 1: Via Classic Addon Manager (Recommended)
1. Open the **Classic Addon Manager**.
2. Search for `Perfection UI` (or `aa-perfection`).
3. Click **Install**.
4. Launch ArcheAge Classic.

### Option 2: Manual Installation
1. Download or clone this repository to your ArcheAge Classic addons directory:
   ```text
   Documents\AAClassic\addons\aa-perfection\
   ```
2. Open or create `addons.txt` inside `Documents\AAClassic\addons\`.
3. Add the line:
   ```text
   aa-perfection
   ```
4. Launch ArcheAge Classic. On character login, you will see `[Perfection UI] Loaded successfully` in the chat window.

---

## Chat Commands

| Command | Action |
| :--- | :--- |
| `/pui settings` (or `/pui config`) | Opens the in-game interactive settings GUI with module checkboxes and presets. |
| `/pui edit` (or `/pui move`) | Toggles visual Edit Mode. Drag frames anywhere on screen. Run again to lock and save. |
| `/pui bag` | Toggles the Next-Generation Smart Inventory window (also bound to default 'I'). |
| `/pui quest` | Collapses or expands the objective tracker. |
| `/pui swap` | Refreshes the Quick-Swap equipment bar from bag contents. |
| `/pui` | Displays in-game help and active module status. |

---

## Architecture & Codebase Map

```
aa-perfection/
├── aa-perfection.yaml            # Classic Addon Manager manifest
├── README.md                     # Documentation & user guide
├── main.lua                      # Root entry point, lifecycle hooks & command router
├── core/
│   ├── api_guard.lua             # Defensive pcall wrappers for all AAClassic APIs
│   ├── theme.lua                 # Apex Obsidian design system, colors & drawing helpers
│   ├── settings.lua              # Persistent settings and coordinate storage
│   ├── settings_page.lua         # Interactive settings GUI with module toggles & presets
│   ├── events.lua                # Throttled update pipeline & event dispatcher
│   ├── mover.lua                 # Edit Mode visual drag handles & positioning
│   └── logger.lua                # Chat logger with isolated error catching
└── modules/
    ├── inventory/
    │   ├── categories.lua        # Item classification engine (Gear, Mats, Regrade, Trade)
    │   ├── bag_scanner.lua       # Deep slot and item type scanner
    │   └── bag_view.lua          # Next-gen smart categorized inventory UI
    ├── actionbars/
    │   ├── bar_skinner.lua       # Stock action bar declutterer & styler
    │   └── swap_bar.lua          # Fast equipment loadout quick-swap bar
    ├── combat_hud/
    │   ├── castbar.lua           # Smooth animated casting gauge
    │   ├── cc_tracker.lua        # High-visibility crowd control alert banner
    │   └── combo_hud.lua         # Abyssal charge and combo tracker
    ├── unitframes/
    │   ├── player_frame.lua      # Modern player health and resource frame
    │   ├── target_frame.lua      # Target health, class, gearscore, and distance frame
    │   ├── secondary.lua         # Target-of-Target & Focus/Watch Target frames
    │   ├── raid_frames.lua       # 50-man zerg-optimized raid frame grid
    │   ├── party_frames.lua      # 5-man party unit frames
    │   └── auras.lua             # Player & target buff/debuff aura tracker
    ├── gameplay/
    │   ├── labor_hud.lua         # Real-time labor capacity and regen monitor
    │   ├── speed_glider.lua      # Travel speedometer and glider duration tracker
    │   └── trade_assist.lua      # Trade pack detector & seller profit share ratio
    └── chat_quest/
        ├── quest_tracker.lua     # Compact collapsible quest tracker
        └── chat_styler.lua       # Minimalist obsidian chat enhancer
```

---

## Author & Credits

- **Author**: mikimatsub ([GitHub](https://github.com/mikimatsub))
- **Server**: ArcheAge Classic (AAClassic)
- **License**: MIT
