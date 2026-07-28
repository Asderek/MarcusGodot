# Tasks: Bare-Bones SotN 2D Platformer Prototype

## Phase 1: Project Setup & Environment
- [ ] Initialize Godot 4.5 project (`project.godot`) in workspace.
- [ ] Configure input actions (`move_left`: A/Left/Stick, `move_right`: D/Right/Stick, `jump`: Space/Pad-X, `backdash`: L/Pad-Triangle, `attack`: J/X/Pad-Square).
- [ ] Configure display settings (1280x720, viewport stretch mode).

## Phase 2: Player Character Mechanics (SotN Inspired)
- [ ] Create `Player` scene with `CharacterBody2D`, `CollisionShape2D` (Capsule), and `Polygon2D` visual placeholder.
- [ ] Implement responsive movement physics (acceleration, deceleration, max speed).
- [ ] Implement SotN variable height jump and fall gravity multiplier.
- [ ] Implement SotN signature **Backdash** mechanic (quick backward momentum boost with state lock).
- [ ] Implement placeholder **Attack / Whip Swipe** (visual arc polygon & hitbox).
- [ ] Implement Player state machine (Idle, Run, Jump, Fall, Backdash, Attack).

## Phase 3: Level & Platforming Challenge
- [ ] Create `Level` scene with `StaticBody2D` platform blocks (ground, floating platforms, gap jump).
- [ ] Set up Start point ("Partida") with visual indicator.
- [ ] Set up Goal/Finish trigger (`Area2D` "Chegada") with collision detection and victory UI popup.
- [ ] Add smooth `Camera2D` tracking the player.
- [ ] Create HUD overlay with health bar, controls guide, and restart button.

## Phase 4: Verification & Web Build
- [ ] Test movement, jumping, backdash, attack, and goal completion locally.
- [ ] Export Godot project to Web (HTML5/WASM export format).

## Phase 5: GitHub Pages Deployment
- [ ] Initialize Git repository in workspace (`git init`).
- [ ] Configure GitHub remote / GitHub Pages setup or deployment action.
- [ ] Publish web build to GitHub Pages and verify online access.
