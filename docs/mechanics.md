# Mechanics

## Core Mechanic: Harm Causes Mitosis

Mitosis Mike is built around an inversion of the usual platform-game failure state. When Mike is harmed, the result is not death. Instead, he divides into smaller versions of himself.

Design consequences:

- Damage can create new options instead of ending an attempt.
- The player is encouraged to think about where and when to get hit.
- Hazards and enemies are not only threats; they are puzzle tools.
- The game becomes more spatial as Mike's total mass is distributed across multiple bodies.

## Player Readable Rules

- Mike starts as a single full-size body.
- Each harmful event can split him into smaller bodies.
- Smaller Mike bodies can reach places that a larger Mike cannot.
- Multiple surviving Mike bodies are part of the same puzzle state.
- The player wins by using the right amount of Mike in the right places, not by preserving a single untouched character.

## Current Implemented Direction

These points reflect the current intended or already-prototyped design direction, with status notes based on current project planning.

### Size And Mobility

- Smaller Mike can fit into smaller spaces. Status: Implemented.
- Bigger Mike can jump higher. Status: Not implemented.
- Smaller Mike can run faster and therefore jump farther. Status: Not implemented.

### Elemental And Hazard Interactions

- Mike can catch fire and spread fire to other things. Status: Not implemented.
- Water extinguishes Mike when he is on fire. Status: Not implemented.

### Consumables And Status Effects

- Growth Potions double Mike's size. Status: Not implemented.
- Confusion Potions invert Mike's controls. Status: Not implemented.

## Practical Puzzle Use Cases

- Intentionally shrink Mike so a smaller body can pass through a tight route.
- Use enemy attacks or environmental hazards to change Mike's form at the right time.
- Split before a traversal challenge so different bodies can occupy different parts of the room.
- Trade mass for access, then recover the whole through the level exit system.

## Current Prototype Notes

The current codebase already supports the heart of the idea:

- Mike can split into smaller descendants instead of ending the run.
- Multiple Mike bodies can coexist at once.
- The camera adapts to keep surviving Mike bodies in view.
- Enemies already provide distinct movement or attack patterns that can pressure puzzle execution.

This makes the project's next design step less about proving the central gimmick and more about building levels that force the player to use it deliberately.
