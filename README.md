# D&D Agents for OpenCode

Specialized AI agents and templates for running tabletop RPG campaigns via OpenCode.

## Agents

| Agent | Purpose |
|-------|---------|
| `CampaignStarter` | Initialize new campaigns with world-building |
| `DungeonMaster` | Run ongoing gameplay and sessions |
| `CharacterCreator` | Create player characters |
| `NPCCreator` | Generate non-player characters |
| `LocationCreator` | Build locations and settlements |
| `OrganizationCreator` | Create factions and guilds |
| `HookCreator` | Design adventure hooks and quests |
| `AdventureAgent` | Run individual adventures |
| `NameGenerator` | Generate unique names for entities |
| `ConsistencyChecker` | Validate campaign consistency |
| `LevelUp` | Handle character progression |

## Templates

- `NPC.md` - Character templates
- `Location.md` - Location/world templates
- `Organization.md` - Faction templates
- `Player.md` - Player character sheets
- `SessionNotes.md` - Game session notes

## Installation

```bash
./install.sh
```

Options:
1. System-wide (global) - Available to all OpenCode sessions
2. Legacy - Install to `~/.opencode`
3. Custom - Specify a directory

## Quick Start

1. Run `./install.sh` and select installation mode
2. Start with `@CampaignStarter` to create a new campaign
3. Use `@DungeonMaster` to run sessions

## Testing

```bash
npm test               # Run all tests
npm run test:quick     # Quick tests only
npm run test:npc      # NPC tests
npm run test:adventure # Adventure tests
```