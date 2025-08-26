# Cookie Heist Game 
> Brackeys Game Jam 2025.2 submission with the theme: "Risk it for the Biscuit"

## Concept
Stealth based game where you steal some cookies from a bakery. You have a fixed time to steal whatever amount of cookies, but take too many and you will feel encumbered.

## Main Gameplay loop
The player spawns in a hallway filled with guards and traps, they need to make their way to the cookie jar at the end of the hallway while avoiding traps and distracting guards without getting spotted.   
   Once at the jar, the player will decide how many cookies they want to take, each cookie is worth a certain amount of points. These cookies reduce the stats of the player, so they have to decide if they should take multiple in one trip, or if they make multiple trips.

## Input controls
The game uses `WASD` for the top-down movement and mouse controls to shoot cookies. There will also be an input for sprinting / slowing down, likely the `shift key`.
The player can interact with objects using the `left mouse button` when within range.

**Player parameters:** The player needs to have a wide variety of stats that can be nerfed by carrying too many cookies\!

* Speed: Affects running speed and sneaking speed, taking too many slowdown cookies might make a section impossible\!\!  
* Noise: How close you can be walking to a guard outside of their line of sight without them hearing you.  
* Size: How big the player is, makes it easier to be spotted by guards and cameras (does not affect hitbox for traps)  
* Accuracy: Affects throwing accuracy, speed, and distance

Ways to lose: The player loses if they are unable to get the minimum amount of cookies per level (this amount is really low). The amount of cookies you collect will be converted into ammunition for the next level and a medal at the end of the level. 

Obstacles dont kill you, they slow you down severely, if you have cookies on your inventory.


## Game Machanics

### Player


### Interactable Button

- [ ] Can be interacted with left-click if the player is close enough
- [ ] Can be operated by security guards who are aiming to maintain a desired state (keeping security devices online)
- [ ] Can control a door (open / close)
- [ ] Can control a detection laser (turn on / off) 
- [ ] Can control a security camera (turn on / off)
- [ ] 🎨 Sprite for button (on state / off state)
- [ ] 🔊 SFX button clicked


### Sliding Door

- [ ] Can be opened / closed by the player
- [ ] Can be opened / closed by the guards
- [ ] The player can peek behind the door
- [ ] Can be locked with a key
- [ ] Can be controlled by a button
- [ ] 🎨 Sprite for sliding door
- [ ] 🔊 SFX for open / closing a door


### Detection Laser
<img width="251" height="100" alt="LazerBeam" src="https://github.com/user-attachments/assets/2747545b-b824-4184-98ac-20895cb3046a" />

- [x] Emit a laser beam in a straight line, with configurable length and angle
- [X] Can be moved in a loop (using AnimationPlayer or Tween)
- [X] The laser beam can switch back and forth between on and off (flicker) in a pattern. You can get past it if you choose the right moment
- [ ] The status is indicated by a control LED (half working)
- [X] An alarm is triggered upon contact with the player
- [x] Can be blocked by a thrown cookie
- [ ] Can be blocked by a passing guard
- [ ] Can be controlled by a button (on / off)
- [ ] 🎨 Sprite for dectection laser device
- [ ] 🎨 Sprite animation for laser beam (optional) [currently a simple red line]
- [ ] 🔊 SFX for laser hitting
- [ ] 🔊 SFX for turn on / off


### Security Camera
<img width="210" height="140" alt="SecurityCamera" src="https://github.com/user-attachments/assets/6810f867-5628-4b6d-b667-b545f56052e2" />

- [x] Observes an area in a cone shape with configurable radius and FOV (field of view)
- [X] The range of rotation of the camera can be limited
- [X] Has several camera positions that are run through in a loop
- [ ] The status is indicated by a control LED
- [X] An alarm is triggered when the player is spotted
- [X] A player who has been spotted is tracked by ~~all~~ cameras
- [X] A thrown cookie distracts the camera for a while
- [ ] When a key is spotted, a guard is sent to collect it
- [ ] Can be controlled by a button (on / off)
- [ ] 🎨 Sprite for security camera device
- [ ] 🔊 SFX for rotating camera
- [ ] 🔊 SFX for turn on / off
- [ ] 🔊 SFX when spotting player


### Security Guard
<img width="278" height="186" alt="SecurityGuard" src="https://github.com/user-attachments/assets/d2e03ff9-f7f4-41f7-a6d2-24084de9ef74" />

- [ ] Has a limited field of vision for viewing the player
- [ ] Chases the player to capture them. If captured the level is lost
- [ ] Guard behavior:
   - [ ] **Sleeping** Sleeps and wakes up when alarmed to chase players
   - [ ] **Patrolling** Patrols a specified path in a timed loop
      - [ ] Moves between control points
      - [ ] Looks in different directions
   - [ ] **Investigate** When the alarm is triggered and the guard is within range, he sprints to the player's last reported position
   - [ ] **Chasing** If the player is spotted by the security guard, he will pursue them
   - [ ] **Distracted** When a cookie is spotted, the security guard runs up to it and observes it for a while
- [ ] 🎨 Sprite animation for guard movement
- [ ] 🎨 Sprite animation for punching the player (capture him)
- [ ] 🔊 SFX punch hit / captured
- [ ] 🔊 SFX shout when distracted (Huuuh?)
- [ ] 🔊 SFX yell when spotting the player (STOP!!!)
- [ ] 🔊 SFX walking steps
- [ ] 🔊 SFX sleeping
- [ ] 🎶 Music when guards alerted
- [ ] 🎶 Music when beeing chased


### Cookie throw (bait to distract)
<img width="285" height="154" alt="CookieThrow_(Bait)" src="https://github.com/user-attachments/assets/17443bae-1725-4f0c-9a28-4f4e054ddc45" />

- [ ] Can be picked up by the player 
- [X] and thrown by holding right-mouse and aiming at mouse position
- [X]




# Cookie Heist Game 
> Brackeys Game Jam 2025.2 submission with the theme: "Risk it for the Biscuit"

## Concept
Stealth based game where you steal some cookies from a bakery. You have a fixed time to steal whatever amount of cookies, but take too many and you will feel encumbered.

## Main Gameplay loop
The player spawns in a hallway filled with guards and traps, they need to make their way to the cookie jar at the end of the hallway while avoiding traps and distracting guards without getting spotted.   
   Once at the jar, the player will decide how many cookies they want to take, each cookie is worth a certain amount of points. These cookies reduce the stats of the player, so they have to decide if they should take multiple in one trip, or if they make multiple trips.

## Input controls
The game uses `WASD` for the top-down movement and mouse controls to shoot cookies. There will also be an input for sprinting / slowing down, likely the `shift key`.
The player can interact with objects using the `left mouse button` when within range.

**Player parameters:** The player needs to have a wide variety of stats that can be nerfed by carrying too many cookies\!

* Speed: Affects running speed and sneaking speed, taking too many slowdown cookies might make a section impossible\!\!  
* Noise: How close you can be walking to a guard outside of their line of sight without them hearing you.  
* Size: How big the player is, makes it easier to be spotted by guards and cameras (does not affect hitbox for traps)  
* Accuracy: Affects throwing accuracy, speed, and distance

Ways to lose: The player loses if they are unable to get the minimum amount of cookies per level (this amount is really low). The amount of cookies you collect will be converted into ammunition for the next level and a medal at the end of the level. 

Obstacles dont kill you, they slow you down severely, if you have cookies on your inventory.


## Game Machanics

### Player

- [X] Move with `WASD`
- [ ] There will also be an input for sprinting / slowing down, likely the `shift key`.
- [X] Limited vision of guards and security devices
- [ ] Sprinting causes noises that can be heard by guards
- [ ] 🎨 Sprite animation for movement
- [ ] 🎨 Additional design when fully loaded with loot
- [ ] 🎨  Sprite animation on interaction with door / button
- [ ] 🔊 SFX steps


### Cookie throw (bait to distract)
<img width="285" height="154" alt="CookieThrow_(Bait)" src="https://github.com/user-attachments/assets/17443bae-1725-4f0c-9a28-4f4e054ddc45" />

- [ ] Can be picked up by the player 
- [X] Can be thrown by the player: aim with the mouse, throw with the left mouse button
- [X] Can distracts guards
- [X] Can distracts security cameras
- [X] Can block laser beams
- [ ] Can be thrown at guards to temporarily slow them down (when escaping)
- [X] 🎨 Sprite for thrown cookie (placeholder?)
- [ ] 🔊 SFX throw sound


## Player Hideout

- [X] Serves as the starting position for the player in the level
- [X] Serves as a base for loot and must be delivered there
- [ ] Is a safe place to hide from guards
- [ ] 🔊 SFX dropping loot off
- [ ] 🎨 Sprite for hideout


## Cookie stash

- [X] Can be looted by the player after a certain amount of uninterrupted searching time
- [X] Is the goal to complete the level
- [X] When looted the player decides how many cookies he wants to take (How many do you risk?)
- [ ] Each cookie taken has a different effect on the level and makes it more difficult to return to the hideout


### Interactable Button

- [ ] Can be interacted with left-click if the player is close enough
- [ ] Can be operated by security guards who are aiming to maintain a desired state (keeping security devices online)
- [ ] Can control a door (open / close)
- [ ] Can control a detection laser (turn on / off) 
- [ ] Can control a security camera (turn on / off)
- [ ] 🎨 Sprite for button (on state / off state)
- [ ] 🔊 SFX button clicked


### Sliding Door

- [ ] Can be opened / closed by the player
- [ ] Can be opened / closed by the guards
- [ ] The player can peek behind the door
- [ ] Can be locked with a key
- [ ] Can be controlled by a button
- [ ] 🎨 Sprite for sliding door
- [ ] 🔊 SFX for open / closing a door


### Hidden spot

- [ ] Can be entered by the player to hide
- [ ] Hides from guard vision
- [ ] Hides from security camera vision
- [X] 🎨 Sprite for hidden spot
- [ ] 🔊 SFX enter / exit


### Detection Laser
<img width="251" height="100" alt="LazerBeam" src="https://github.com/user-attachments/assets/2747545b-b824-4184-98ac-20895cb3046a" />

- [x] Emit a laser beam in a straight line, with configurable length and angle
- [X] Can be moved in a loop (using AnimationPlayer or Tween)
- [X] The laser beam can switch back and forth between on and off (flicker) in a pattern. You can get past it if you choose the right moment
- [ ] The status is indicated by a control LED (half working)
- [X] An alarm is triggered upon contact with the player
- [x] Can be blocked by a thrown cookie
- [ ] Can be blocked by a passing guard
- [ ] Can be blocked by other laser (both stop at intersection point)
- [ ] Can be controlled by a button (on / off)
- [ ] Slows down hit players and guards
- [ ] 🎨 Sprite for dectection laser device
- [ ] 🎨 Sprite animation for laser beam (optional) [currently a simple red line]
- [ ] 🔊 SFX for laser hitting
- [ ] 🔊 SFX for turn on / off


### Security Camera
<img width="210" height="140" alt="SecurityCamera" src="https://github.com/user-attachments/assets/6810f867-5628-4b6d-b667-b545f56052e2" />

- [x] Observes an area in a cone shape with configurable radius and FOV (field of view)
- [X] The range of rotation of the camera can be limited
- [X] Has several camera positions that are run through in a loop
- [ ] The status is indicated by a control LED
- [X] An alarm is triggered when the player is spotted
- [X] A player who has been spotted is tracked by ~~all~~ cameras
- [X] A thrown cookie distracts the camera for a while
- [ ] When a key is spotted, a guard is sent to collect it
- [ ] Can be controlled by a button (on / off)
- [ ] 🎨 Sprite for security camera device
- [ ] 🔊 SFX for rotating camera
- [ ] 🔊 SFX for turn on / off
- [ ] 🔊 SFX when spotting player


### Security Guard
<img width="278" height="186" alt="SecurityGuard" src="https://github.com/user-attachments/assets/d2e03ff9-f7f4-41f7-a6d2-24084de9ef74" />

- [ ] Has a limited field of vision for spotting the player
- [ ] Chases the player to capture them. If captured the level is lost
- [ ] Guard behavior:
   - [ ] **Sleeping** Sleeps and wakes up when alarmed to chase players
   - [ ] **Patrolling** Patrols a specified path in a timed loop
      - [ ] Moves between control points
      - [ ] Looks in different directions
   - [ ] **Investigate** When the alarm is triggered and the guard is within range, he sprints to the player's last reported position
   - [ ] **Chasing** If the player is spotted by the security guard, he will pursue them
   - [ ] **Distracted** When a cookie is spotted, the security guard runs up to it and observes it for a while
- [ ] 🎨 Sprite animation for guard movement
- [ ] 🎨 Sprite animation for punching the player (capture him)
- [ ] 🔊 SFX punch hit / captured
- [ ] 🔊 SFX shout when distracted (Huuuh?)
- [ ] 🔊 SFX yell when spotting the player (STOP!!!)
- [ ] 🔊 SFX walking steps
- [ ] 🔊 SFX sleeping
- [ ] 🎶 Music when guards alerted
- [ ] 🎶 Music when beeing chased



