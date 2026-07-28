# Tasks: Bare-Bones SotN 2D Platformer Prototype

## Phase 1: Project Setup & Environment
- [x] Initialize Godot 4.5 project (`project.godot`) in workspace.
- [x] Configure input actions (`move_left`: A/Left/Stick, `move_right`: D/Right/Stick, `jump`: Space/Pad-X, `backdash`: L/Pad-Triangle, `attack`: J/X/Pad-Square).
- [x] Configure display settings (1280x720, viewport stretch mode).

## Phase 2: Player Character Mechanics (SotN Inspired)
- [x] Create `Player` scene with `CharacterBody2D`, `CollisionShape2D` (Capsule), and `Polygon2D` visual placeholder.
- [x] Implement responsive movement physics (acceleration, deceleration, max speed).
- [x] Implement SotN variable height jump and fall gravity multiplier.
- [x] Implement SotN signature **Backdash** mechanic (quick backward momentum boost with blue ghost trail).
- [x] Implement placeholder **Attack / Whip Swipe** (visual arc polygon & hitbox).
- [x] Implement Player state machine (Idle, Run, Jump, Fall, Backdash, Attack).

## Phase 3: Level & Platforming Challenge
- [x] Create `Level` scene with `StaticBody2D` platform blocks (ground, floating platforms, gap jump).
- [x] Set up Start point ("Partida") with visual indicator.
- [x] Set up Goal/Finish trigger (`Area2D` "Chegada") with collision detection and victory UI popup.
- [x] Add smooth `Camera2D` tracking the player.
- [x] Create HUD overlay with health bar, controls guide, and restart button.

## Phase 4: Verification & Web Build
- [x] Test movement, jumping, backdash, attack, and goal completion in headless Godot runner.
- [x] Configure Web export preset (`export_presets.cfg`).

## Phase 5: GitHub Pages Deployment
- [x] Initialize Git repository in workspace (`git init`).
- [x] Create GitHub Actions deployment workflow (`.github/workflows/deploy.yml`).
- [x] Connect remote repository (`https://github.com/Asderek/MarcusGodot.git`) & push to GitHub Pages.
