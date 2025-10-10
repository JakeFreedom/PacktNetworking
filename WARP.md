# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is "Packt's Multiplayer Online Games", a Godot 4.4 project featuring multiple networked multiplayer games and components. The project demonstrates various networking patterns in game development including client-server architecture, authentication systems, and real-time multiplayer gameplay.

## Common Development Commands

### Building and Running
```bash
# Open project in Godot Editor
godot --editor .

# Run the project directly
godot --main-pack . 

# Export to Windows (using configured preset)
godot --headless --export-release "Windows Desktop" "../../../MultiPlayer Trivia/game.exe"

# Run project in debug mode
godot --debug .
```

### Project Management
```bash
# Import/re-import assets
godot --headless --import .

# Check project for errors
godot --headless --check-only .

# Script validation
godot --headless --script-check .
```

### Testing Individual Scenes
The project doesn't use traditional unit tests but relies on scene-based testing:
```bash
# Run specific scene for testing
godot --debug --path . res://path/to/scene.tscn
```

## Code Architecture

### Core Networking Structure

**Authentication System**: Centralized authentication using `AuthNetCredentials` autoload
- Global session management across all game modules
- Token-based authentication with simple user database
- Located in `Network/Authentication/`

**Client-Server Architecture**: ENet-based multiplayer with consistent patterns:
- Server components handle game logic and state
- Client components manage UI and player input
- All networking uses port 3000 by default
- RPC system for client-server communication

### Main Components

**Quiz Game System** (`QuizGame/`):
- `QuizServer.gd`: Manages trivia game sessions and question databases  
- Modular question system with JSON files (various trivia categories)
- Support for multiple question databases loaded dynamically

**Checkers Game** (`Checkers/`):
- Complete turn-based multiplayer implementation
- `CheckerBoard.gd`: Core game logic with piece movement, capture rules, and win conditions
- Authority-based multiplayer with turn synchronization
- King promotion system and complex capture mechanics

**Chat System** (`Network/Chat_System/`):
- Real-time messaging between connected players
- Integrated with authentication system
- Avatar support with user profiles

**Lobby System** (`Network/Lobby/`):
- Player matchmaking and session management
- Avatar display and user presence
- Session token validation

### Data Management

**Question Databases**: JSON files containing trivia questions
- Structured format: `{"question_id": {"text": "...", "alternatives": [...], "correct_answer_index": N}}`
- Categories include music, gaming, anatomy, programming, and more
- `FakeDB.json` contains user authentication data

**Asset Management**: Standard Godot .import system
- SVG graphics for game pieces and UI elements
- PNG sprites for avatars and game assets
- Scene files (.tscn) for UI components and game objects

### Key Networking Patterns

**RPC Usage**:
- `@rpc("any_peer", "call_remote")` for client-to-server calls
- `@rpc("authority", "call_local")` for server authoritative actions
- `@rpc` for bidirectional communication

**Multiplayer Authority**:
- Server maintains game state authority
- Individual teams/pieces can have separate authorities
- Authority validation in game logic

**Session Management**:
- Token-based session tracking
- User state persistence across game modes
- Centralized credential management via autoload

## Development Patterns

### Scene Organization
- Main menu system routes to different game modes
- Server/Client scene separation for each game type
- UI components in dedicated `UI/` directory with reusable elements

### Script Naming
- Server scripts typically end with `Server.gd`
- Client scripts may include `Client` or descriptive names
- Scene naming uses PascalCase with matching .gd files in snake_case

### Multiplayer Implementation
- Each game mode has dedicated server and client scenes
- Consistent port usage (3000) across all network components
- Standardized authentication flow before game access

## File Structure Context

- Root JSON files are question databases for the trivia system
- `Network/` contains all multiplayer infrastructure
- `UI/` houses reusable interface components
- Game-specific directories (`QuizGame/`, `Checkers/`) contain complete implementations
- `.gd.uid` files are Godot's unique identifiers - avoid editing manually

## Development Notes

The project uses Godot's ENet networking with a focus on educational multiplayer patterns. Each game demonstrates different networking approaches:
- Quiz games show database-driven content delivery
- Checkers implements complex turn-based synchronization  
- Chat system demonstrates real-time communication
- Lobby system shows user presence and matchmaking

When adding new features, follow the established client-server patterns and ensure proper authentication integration through the `AuthNetCredentials` autoload.