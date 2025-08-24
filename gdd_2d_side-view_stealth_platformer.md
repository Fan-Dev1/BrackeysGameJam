# 🍪 Game Design Document (GDD)
**"Risk it for the Biscuit"**

## Core Concept
A **2D side-view stealth platformer** where the player sneaks through a house/kitchen guarded by patrolling guards to steal cookies from the cookie jar.

The game balances **safe sneaking** with **temptation**: grab one cookie and leave, or risk going for more to increase your score — and danger.

---

## Gameplay & Mechanics

### Player Abilities
- **Movement:** Walk, crouch, climb ladders, jump.
- **Shadows:** Standing in dark areas reduces visibility to guards.
- **Cover Objects:** Hide behind boxes/furniture to break line-of-sight.
- **Stealth Kill (Melee):** Perform a silent takedown from behind a guard (optional).
- **Throwing Knife (Ranged):** Limited-use ranged takedown tool.
- **Cookie Toss (Lure):** Toss a cookie to create a noise distraction → guards investigate.
- **Crouch Walk:** Slower movement, nearly silent.

### Guards (AI)
- **Patrol:** Move left/right between waypoints.
- **Vision Cones:** Detect player if visible and not in shadows or cover.
- **States:**
  - **Patrol:** Idle walking along route.
  - **Suspicious:** Hear noise or see movement → investigate.
  - **Alert:** Spot player clearly → chase.
- **Chase:** Guards pursue player; contact = player caught → Game Over.

### Win Condition
- Steal **at least 1 cookie** and return to the exit.

### Lose Condition
- Caught by a guard → Game Over.

---

## Level Design
- **Side-view, tile-based rooms.**
- Player starts near entrance → must reach kitchen with cookie jar.
- Cookie jar contains **multiple cookies** → player chooses how many to grab.
- Escape may be harder with more cookies (e.g., heavier footsteps, louder crunch sounds).

### Example Layout
1. **Room 1:** Guard patrolling corridor; shadows along walls for hiding.
2. **Room 2:** Kitchen with cookie jar in center; two guards patrolling.
3. **Exit:** Back at entrance.

---

## Art & Style
- 2D side-view platformer sprites (simple pixel art).
- **Lighting/Shadows:** Dark areas = safe zones; player silhouette fades.
- **Tone:** Lighthearted and sneaky, not grim; guards are cartoonish/goofy.
- Cookie jar glows with cartoon sparkle effect.

---

## Sound
- **Footsteps:** Quiet when crouching, louder when running.
- **Crunch sound:** Picking a cookie; may alert guards if nearby.
- **Guard chatter:** Mumbling sounds while patrolling.
- **Music:** Soft stealth theme; intensifies if player is spotted.

---

## Scope for 7-Day Jam

### Core MVP Features
- One short level (1–2 minutes to complete).
- Basic guard patrol AI with vision cones.
- Player movement with crouch and hide mechanics.
- Cookie jar interaction (take cookies → triggers win).
- Game Over if caught.

### Stretch Goals
- Stealth kills and throwing knives.
- Multiple cookies with risk/reward system.
- Noise system (lure with cookie toss).
- Multiple levels with varying layouts.
- Score/ending variations:
  - “You took 1 cookie… coward!”
  - “You emptied the jar… legend!”

---

## Core Gameplay Loop
1. Enter house → sneak past first patrol.
2. Use shadows and cover to avoid detection.
3. Reach cookie jar → decide how greedy to be.
4. Escape back to exit.
5. End screen → # of cookies stolen = player score.
