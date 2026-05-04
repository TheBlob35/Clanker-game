# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Clanker-Game** — Godot 4.6 top-down 2D action game. Two collaborators working on the same repo.
- Engine: Godot 4.6, Forward Plus renderer, Direct3D 12 (Windows), Jolt Physics
- Main scene: `clanker-game/game.tscn`
- Boss fight scene: `clanker-game/Boss Fights/Fight 1/Fight1.tscn`

## Running the Game

Open the project in Godot 4.6 by loading `clanker-game/project.godot`. Run with F5 (main scene) or F6 (current scene). There is no CLI build step.

## Project Structure

```
clanker-game/
├── player/              # Player scene + script
├── Bosses/Boss 1/       # Boss 1 scene + script + projectiles
│   ├── Bullet/          # Gatling bullet (bullet.tscn / bullet.gd)
│   ├── Mortar/          # Mortar bullet, warning circle (mortar_bullet.tscn, mortar_warning.gd)
│   └── Tracker/         # Tracking shot (tracker.tscn / tracker.gd) — WIP
├── Boss Fights/Fight 1/ # Fight arena scene (Fight1.tscn / Fight1.gd)
└── assets/              # Sprites and tilesets
```

## Architecture

### Player (`player/player.gd`)
- `CharacterBody2D`, top-down movement (WASD), no gravity
- Added to group `"player"` in `_ready()` — all enemy scripts locate the player via `get_tree().get_first_node_in_group("player")`
- Health driven by `metadata/Health` set in the Inspector. Read via `get_meta("Health")` in `_ready()`
- `take_damage(amount: int)` is the public API — called by bullets on hit
- `die()` reloads the current scene

### Boss 1 (`Bosses/Boss 1/boss.gd`)
- `CharacterBody2D` locked to `initial_y` every frame (X-axis rails only)
- Three-phase state machine via `enum Phase { ONE, TWO, THREE }`
  - Phase 1 → Phase 2 at 66% HP lost; Phase 2 → Phase 3 at 70% HP lost
  - **Phase 1**: Stationary. Fires gatling bursts (30 shots, then 5s reload)
  - **Phase 2**: Sweeps left/right (`MoveState` machine), fires mortar bursts, shield active while moving
  - **Phase 3**: Same as Phase 2 but faster (`MOVE_SPEED_3`), 3 sweeps per cycle before reloading
- `MoveState { SWEEP_A, SWEEP_B, CENTERING, RELOADING }` — shared across phases 2 and 3
- Shield (`Area2D`) sets `invulnerable = true` while moving; `take_damage()` is a no-op when invulnerable
- Projectiles are spawned as children of `get_parent()` (the fight scene). **Set all bullet properties before `add_child()`** so `_ready()` fires with correct values

### Projectiles
- **Bullet** (`Bullet/bullet.gd`): Moves in fixed `direction`, calls `body.take_damage()` on player hit only, then `queue_free()`
- **Mortar** (`Mortar/mortar_bullet.gd`): Fires upward, snaps to `(target_pos.x, -300)` off-screen, falls to `target_pos`. On arrival checks distance < `BLAST_RADIUS`. Spawns a `mortar_warning.gd` node at `target_pos` that grows and reddens as the mortar falls
- **Tracker** (`Tracker/tracker.gd`): WIP — soft-homing shot, steers toward player each frame via `direction.lerp(desired, TURN_SPEED * delta)`

### Arena
- Static camera at `(576, 324)`, viewport `1152×648`, no player-follow in fight scene
- Arena bounds constants in `boss.gd`: `ARENA_LEFT=0`, `ARENA_RIGHT=1152`, `ARENA_TOP=0`, `ARENA_BOTTOM=648`
- Floor: `StaticBody2D` at y=350, width=1151

## Conventions

- `ALL_CAPS` = constants, `_underscore` prefix = private/internal variable or function, no prefix = public API callable from other scripts
- Properties set on instantiated scenes must be assigned **before** `add_child()` — `_ready()` fires at `add_child()` time
- Typed variables use `:=` for inference or `: Type` for explicit typing
- `.godot/` is gitignored — never commit it
