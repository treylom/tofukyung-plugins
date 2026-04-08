# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-03-15

### Added
- `scripts/diagnose.sh`: Zero-token bash diagnostic engine with 12-item weighted checklist
  - Supports `--markdown`, `--json`, `--verbose` output modes
  - Color output with `--no-color` option
  - Single skill or directory-wide scanning
- `scripts/backup.sh`: Skill directory backup utility
  - Timestamped tar.gz backups
  - `--list` and `--restore` options
- `skills/skills-2.0-upgrade/SKILL.md`: Core upgrade skill
  - Anthropic writing-skills spec compliant frontmatter
  - CSO-optimized description
  - <200 words core with Progressive Disclosure to references/
- `skills/skills-2.0-upgrade/references/`: 4 reference files
  - `diagnostic-criteria.md`: Detailed 12-item checklist with scoring formula
  - `upgrade-actions.md`: P1-P7 prioritized fix procedures
  - `skills-2.0-spec.md`: Skills 2.0 education document with 1.0 vs 2.0 comparison
  - `trigger-optimization.md`: Description optimization guide (skillers-suda patterns)
- `commands/skills-upgrade.md`: `/skills-upgrade` slash command
  - Interactive default + `--diagnose` (read-only) and `--dry-run` (preview) modes
  - Target selection: single skill, multiple skills, or all
  - 4-phase pipeline: Target → Scan → Report → Plan → Execute
- `install.sh`: One-click installer
  - Cross-platform: WSL, macOS, Linux
  - curl-pipe support: `curl -fsSL ... | bash`
  - Bilingual output (English/Korean)
- `README.md`: English documentation
- `README-ko.md`: Korean documentation

### Acknowledgments
- [superpowers:writing-skills](https://github.com/obra/superpowers) (obra) — TDD methodology, CSO, frontmatter spec
- [fivetaku/skillers-suda](https://github.com/fivetaku/skillers-suda) (MIT) — Structural validation, Auto Eval, trigger optimization
