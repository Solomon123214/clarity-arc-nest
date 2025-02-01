# ArcNest
A decentralized application for writers to organize and plan their creative writing projects. ArcNest allows writers to create project timelines, character maps, and story arcs in a secure and collaborative environment.

## Features
- Create and manage writing projects
- Build interactive timelines
- Create character profiles and relationships
- Track story arcs and plot points
- Collaborate with other writers

### Character Relationship System
The new character relationship system allows writers to:
- Define relationships between characters (family, friends, rivals, etc.)
- Add detailed descriptions of character dynamics
- Track relationship changes throughout the story
- Map complex character networks and interactions
- Visualize character connections and dependencies

## Usage
Characters can be connected using the `add-character-relationship` function:
```clarity
(add-character-relationship project-id character1-id character2-id relationship-type description)
```

Relationship details can be retrieved using:
```clarity
(get-character-relationship relationship-id project-id)
```
