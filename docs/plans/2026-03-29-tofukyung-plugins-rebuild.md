# tofukyung-plugins Rebuild Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the tofukyung-plugins repository so it reads like a polished Korean plugin marketplace, relocates marketplace metadata into `.claude-plugin/`, and adds a lightweight plugin structure guide.

**Architecture:** Keep the repository shape minimal: submodules stay under `plugins/`, marketplace metadata moves to `.claude-plugin/marketplace.json`, and user-facing documentation is split between a landing-page README and a short docs guide. Favor direct rewrites over incremental edits because the current README and marketplace schema are both small and fully replaced.

**Tech Stack:** Markdown, JSON, git submodules, Claude Code plugin marketplace conventions

---

### Task 1: Rewrite landing README

**Files:**
- Modify: `README.md:1-36`
- Reference: `plugins/`
- Reference: `.gitmodules`

**Step 1: Write the target README structure**

Draft these sections in order:
- Title + 3-5 line intro narrative
- Quick Start
- Available Plugins table
- Synergy Guide
- Requirements
- Contributing
- License

**Step 2: Verify plugin inventory before writing**

Run: `ls -la /tmp/tofukyung-plugins/plugins`
Expected: 7 plugin directories matching the required plugin list

**Step 3: Rewrite `README.md` in Korean**

Include:
- Intro line with “AI를 업무에 녹이고 싶은 사람들을 위한 Claude Code 플러그인”
- Quick Start commands:
  - `/plugin marketplace add https://github.com/treylom/tofukyung-plugins.git`
  - `/plugin install {플러그인명}`
  - `/plugin update`
- Plugin table with 7 GitHub links and one-line Korean value descriptions in “~하는 도구” style
- Three synergy scenarios with concrete pipeline language
- Requirements mentioning Claude Code only and Windows WSL2 recommended
- MIT license note

**Step 4: Read the rewritten README for review**

Run: `sed -n '1,220p' /tmp/tofukyung-plugins/README.md`
Expected: All required sections appear in the correct order

### Task 2: Relocate marketplace metadata

**Files:**
- Modify: `marketplace.json:1-53`
- Create: `.claude-plugin/marketplace.json`

**Step 1: Create the target directory**

Run: `mkdir -p /tmp/tofukyung-plugins/.claude-plugin`
Expected: Directory exists

**Step 2: Rewrite plugin entries for local sources**

For each plugin object:
- Replace `repository` with `source: "./plugins/{name}"`
- Keep `name`, `description`, and `category`
- Add `tags` array with 2-4 concise tags per plugin

**Step 3: Write `.claude-plugin/marketplace.json`**

Preserve top-level fields:
- `name`
- `description`
- `version`
- `author`
- `plugins`

**Step 4: Remove the old root marketplace file**

Run: `rm /tmp/tofukyung-plugins/marketplace.json`
Expected: Root file removed, new file remains

**Step 5: Read the new marketplace file**

Run: `sed -n '1,240p' /tmp/tofukyung-plugins/.claude-plugin/marketplace.json`
Expected: Every plugin uses `source` and has `tags`

### Task 3: Add plugin structure guide

**Files:**
- Create: `docs/plugin-standard.md`

**Step 1: Create docs directory**

Run: `mkdir -p /tmp/tofukyung-plugins/docs`
Expected: Directory exists

**Step 2: Write a concise guide**

Document:
- Recommended repository layout
- Where `.claude-plugin/marketplace.json` lives
- Where each plugin directory lives
- What each plugin should usually contain (`skills/`, `commands/`, optional docs)
- Short writing principles for descriptions and tags

**Step 3: Read the guide back**

Run: `sed -n '1,220p' /tmp/tofukyung-plugins/docs/plugin-standard.md`
Expected: Short, practical, and aligned with this repo layout

### Task 4: Verify the rebuilt repo

**Files:**
- Verify: `README.md`
- Verify: `.claude-plugin/marketplace.json`
- Verify: `docs/plugin-standard.md`

**Step 1: List key paths**

Run: `ls -la /tmp/tofukyung-plugins /tmp/tofukyung-plugins/.claude-plugin /tmp/tofukyung-plugins/docs`
Expected: README, new marketplace file, and guide file all present

**Step 2: Check git status**

Run: `git -C /tmp/tofukyung-plugins status --short`
Expected: `README.md` modified, root `marketplace.json` deleted, `.claude-plugin/marketplace.json` added, `docs/` files added

**Step 3: Report completion to Lead**

Send a summary covering:
- Created files
- Rewritten sections
- Marketplace schema change
- Anything the main branch owner should review manually
