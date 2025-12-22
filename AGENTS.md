# AGENTS.md

## Build/Test Commands
- `npm test` - Run all tests via test-runner.sh
- `npm run test:quick` - Run quick tests
- `npm run test:performance` - Run performance tests
- `npm run test:npc` - Run NPC tests only
- `npm run test:hooks` - Run hook tests only
- `npm run test:locations` - Run location tests only
- `npm run test:organizations` - Run organization tests only
- `npm run test:campaign` - Run campaign tests only
- `npm run test:names` - Run name generation tests only
- `npm run test:adventure` - Run adventure tests only

## Code Style Guidelines
- Use YAML frontmatter with `---` delimiters for all template files
- Follow the established template structure in `/template/` directory
- Use snake_case for file names and entity IDs
- Maintain entity ID tracking in `template/entity_ids.yml`
- Use markdown formatting with proper headers (`##`, `###`)
- Include created_date and last_modified in YYYY-MM-DD format
- Use consistent indentation (2 spaces for YAML, 4 spaces for markdown lists)
- Follow game system conventions as defined in GameSystem.md for campaign content
- Use the ConsistencyChecker agent to validate content before finalizing