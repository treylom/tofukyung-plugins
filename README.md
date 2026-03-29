# tofukyung-plugins

Claude Code skills & agents by [tofukyung](https://github.com/treylom).

## Plugins

| Plugin | Category | Description |
|--------|----------|-------------|
| [prompt-engineering-skills](https://github.com/treylom/prompt-engineering-skills) | Prompt Engineering | Auto-prompt, GPTs/Gems generators, prompt sync |
| [knowledge-manager](https://github.com/treylom/knowledge-manager) | Knowledge Management | Web/PDF/social extraction to Obsidian/Notion |
| [tofu-at](https://github.com/treylom/tofu-at) | Agent Orchestration | Agent Teams with split-pane execution |
| [skills-2.0-upgrade](https://github.com/treylom/skills-2.0-upgrade) | Developer Tools | Skills 2.0 auto-diagnosis and guided upgrade |
| [qwen3-tts-claude-skill](https://github.com/treylom/qwen3-tts-claude-skill) | Audio | Text-to-speech with Qwen3 TTS |
| [writing-assistant](https://github.com/treylom/writing-assistant) | Writing | AI writing coach with persona carving loop |
| [lesson-skill](https://github.com/treylom/lesson-skill) | Education | Interactive lesson engine with adaptive pedagogy |

## Install

Each plugin is a standalone Claude Code skill. Install individually:

```bash
# Example: install knowledge-manager
git clone https://github.com/treylom/knowledge-manager
cp -r knowledge-manager/skills/ ~/.claude/skills/
cp -r knowledge-manager/commands/ ~/.claude/commands/
```

Or add as submodule to your project:

```bash
git submodule add https://github.com/treylom/knowledge-manager plugins/knowledge-manager
```

## License

MIT
