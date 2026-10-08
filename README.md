# Perfection UI (ArcheAge Classic)

**Perfection UI** is the definitive, zero-setup, performance-engineered interface overhaul addon for **ArcheAge Classic (AAClassic)**.

Built on verified AAClassic 1.3.5+ Addon API mechanics, it replaces dated legacy elements with the obsidian-and-gold **Apex Obsidian** tactical design system, engineered for 140+ FPS performance in 100v100 siege warfare, open naval combat, and sandbox trade.

---

## Features

- **Next-Gen Smart Bag**: Complete replacement of the stock bag window. Automatic categorization into **Gear**, **Consumables**, **Regrade & Enchant**, **Crafting Materials**, and **Trade / Cargo**. Real-time keyword search filter, free slot capacity gauge, and clean gold display.
- **Apex Obsidian Unit Frames**: High-contrast, minimalist Player and Target unit frames. Displays current/max HP and %, MP, Target Level, Class name, Gear Score (GS), Distance in meters, and reactive Hostile (Red) vs Friendly (Cyan) health colors.
- **Combat HUD**: Smooth animated player Cast Bar with spell name, duration, and completion glow. Dynamic Abyssal Charge tracker (1-4 charges) and instant high-priority Crowd Control (Stun, Trip, Sleep, Bubble, Silence) warning banners.
- **Quick-Swap Floating Bar**: Fast 1-click gear-swapping bar for situational weapon, shield, and instrument swapping.
- **Trade & Naval Assistance**: Real-time travel speedometer (m/s) for mounts and gliders, live Labor Power tracker, and trade pack detection surfacing current seller payout percentages.
- **Zero-Setup & Edit Mode**: Perfect default positioning out of the box. Type `/pui edit` anytime to visually drag, position, and snap any module, saving positions persistently across sessions.

---

## Installation Guide

### Option 1: Via Classic Addon Manager (Recommended)
1. Open the **Classic Addon Manager**.
2. Search for `Perfection UI` (or `aa-perfection`).
3. Click **Install**.
4. Launch ArcheAge Classic.

### Option 2: Manual Installation
1. Navigate to your ArcheAge Classic documents folder:
   `Documents/AAClassic/addons/`
2. Create or copy this folder as `aa-perfection` inside `addons/`:
   `Documents/AAClassic/addons/aa-perfection/`
3. Open or create `addons.txt` inside `Documents/AAClassic/addons/`.
4. Add the line:
   ```
   aa-perfection
   ```
5. Launch ArcheAge Classic. On character login, you will see `[Perfection UI] Loaded successfully` in the chat window.

---

## Chat Commands

| Command | Action |
| :--- | :--- |
| `/pui edit` (or `/pui move`) | Toggles visual Edit Mode. Drag frames anywhere on your screen. Run again to lock and save. |
| `/pui bag` | Toggles the Next-Generation Smart Inventory window (also bound to default 'I'). |
| `/pui swap` | Refreshes the Quick-Swap equipment bar from bag contents. |
| `/pui` | Displays in-game help and active module status. |

---

## File Structure

```
aa-perfection/
├── aa-perfection.yaml            # Addon manager manifest
├── README.md                     # Documentation & user guide
├── main.lua                      # Root entry point & lifecycle manager
├── core/
│   ├── api_guard.lua             # Defensive pcall wrappers for all AAC APIs
│   ├── theme.lua                 # Apex Obsidian design system & color palette
│   ├── settings.lua              # Persistent settings and coordinate storage
│   ├── events.lua                # Throttled update pipeline & event dispatcher
│   ├── mover.lua                 # Edit Mode visual drag handles & positioning
│   └── logger.lua                # Chat logger with isolated error catching
└── modules/
    ├── inventory/
    │   ├── categories.lua        # Item classification engine
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
    │   └── target_frame.lua      # Target health, class, gearscore, and distance frame
    └── gameplay/
        ├── labor_hud.lua         # Real-time labor capacity and regen monitor
        ├── speed_glider.lua      # Travel speedometer and glider duration tracker
        └── trade_assist.lua      # Trade pack detector & seller profit share ratio
```
