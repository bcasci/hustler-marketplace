# Hustle Plugin Marketplace

Development marketplace for the hustle-plugin Claude Code extension.

## Structure

```
hustler-marketplace/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace configuration
└── hustle-plugin/               # The plugin itself
    ├── .claude-plugin/
    │   └── plugin.json          # Plugin manifest
    ├── commands/                # Slash commands
    ├── agents/                  # Custom agents
    ├── skills/                  # Agent skills
    ├── hooks/                   # Event handlers
    ├── scripts/                 # Hook scripts
    └── mcp-config.json         # MCP server configuration
```

## Installation

To install this marketplace in Claude Code:

1. Add this repository to your Claude Code configuration
2. The hustle-plugin will be available for installation

## Development

The `hustle-plugin/` directory contains the actual plugin. Edit components there:

- Add commands in `hustle-plugin/commands/`
- Create agents in `hustle-plugin/agents/`
- Build skills in `hustle-plugin/skills/`
- Configure hooks in `hustle-plugin/hooks/`
- Add MCP servers to `hustle-plugin/mcp-config.json`

## License

MIT
