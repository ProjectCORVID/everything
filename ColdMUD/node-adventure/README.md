# Tackling the CORVID problem from another direction

Attempting to make an old-style interactive fiction engine in order to better
understand the CORVID problem space.

# Design goals and anti-goals

- It should be easy both to compose and consume the pieces this engine supports.
- The engine operates entirely via stdio (no networking, etc)
- There is only one "save slot" and it is updated after each event
- Events can only be triggered by user input (directly or indirectly)
  - no timers
  
# Design

## Objects

- player
  - session
- world
  - entity
  - vocabulary
- command

- 
