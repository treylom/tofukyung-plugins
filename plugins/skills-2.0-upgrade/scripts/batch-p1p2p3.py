#!/usr/bin/env python3
"""Batch P1-P3 auto-fix for Skills 2.0 compliance."""

import os
import re
import sys

targets = [a for a in sys.argv[1:] if not a.startswith("--")]
SKILLS_DIR = targets[0] if targets else os.path.expanduser("~/.claude/skills")
EXTRA_TARGETS = targets[1:]  # additional individual files
DRY_RUN = "--dry-run" in sys.argv

# Files to skip (not real skills)
SKIP_FILES = {"BUGS.md", "CHANGELOG.md", "README-global.md", "README.md"}

stats = {"p1": 0, "p2": 0, "p3": 0, "skipped": 0, "files": 0}


def normalize_name(filepath):
    """Derive kebab-case name from filepath."""
    base = os.path.basename(filepath)
    if base == "SKILL.md":
        base = os.path.basename(os.path.dirname(filepath))
    else:
        base = os.path.splitext(base)[0]
    # Convert to kebab-case: lowercase, replace non-alphanum with hyphens
    name = re.sub(r'[^a-zA-Z0-9-]', '-', base).lower()
    name = re.sub(r'-+', '-', name).strip('-')
    return name


def smart_lower_first(s):
    """Lowercase first char only if ASCII letter. Preserve Korean, acronyms, proper nouns."""
    if not s:
        return s
    # Don't lowercase if first char is non-ASCII (Korean, etc.)
    if ord(s[0]) > 127:
        return s
    # Don't lowercase if it looks like an acronym (2+ uppercase like AI, OCR, PDF)
    if len(s) > 1 and s[0].isupper() and s[1].isupper():
        return s
    # Don't lowercase if next word is also capitalized (proper noun like "Knowledge Manager")
    words = s.split()
    if len(words) >= 2 and words[0][0].isupper() and words[1][0].isupper():
        return s
    return s[0].lower() + s[1:]


def transform_description_to_use_when(desc):
    """Transform an existing description to start with 'Use when'."""
    if not desc:
        return None

    desc = desc.strip().strip('"').strip("'")

    # Already starts with "Use when" - skip
    if re.match(r'^[Uu]se when\b', desc):
        return None

    # Common verb mappings (imperative → gerund, 3rd person → gerund)
    verb_map = {
        'create': 'creating', 'creates': 'creating',
        'build': 'building', 'builds': 'building',
        'generate': 'generating', 'generates': 'generating',
        'convert': 'converting', 'converts': 'converting',
        'analyze': 'analyzing', 'analyzes': 'analyzing',
        'manage': 'managing', 'manages': 'managing',
        'search': 'searching', 'searches': 'searching',
        'find': 'finding', 'finds': 'finding',
        'run': 'running', 'runs': 'running',
        'test': 'testing', 'tests': 'testing',
        'check': 'checking', 'checks': 'checking',
        'validate': 'validating', 'validates': 'validating',
        'extract': 'extracting', 'extracts': 'extracting',
        'process': 'processing', 'processes': 'processing',
        'handle': 'handling', 'handles': 'handling',
        'implement': 'implementing', 'implements': 'implementing',
        'configure': 'configuring', 'configures': 'configuring',
        'set': 'setting', 'sets': 'setting',
        'add': 'adding', 'adds': 'adding',
        'remove': 'removing', 'removes': 'removing',
        'update': 'updating', 'updates': 'updating',
        'deploy': 'deploying', 'deploys': 'deploying',
        'install': 'installing', 'installs': 'installing',
        'download': 'downloading', 'downloads': 'downloading',
        'merge': 'merging', 'merges': 'merging',
        'split': 'splitting', 'splits': 'splitting',
        'parse': 'parsing', 'parses': 'parsing',
        'render': 'rendering', 'renders': 'rendering',
        'display': 'displaying', 'displays': 'displaying',
        'show': 'showing', 'shows': 'showing',
        'automate': 'automating', 'automates': 'automating',
        'optimize': 'optimizing', 'optimizes': 'optimizing',
        'enhance': 'enhancing', 'enhances': 'enhancing',
        'debug': 'debugging',
        'diagnose': 'diagnosing', 'diagnoses': 'diagnosing',
        'monitor': 'monitoring', 'monitors': 'monitoring',
        'sync': 'syncing', 'syncs': 'syncing',
        'export': 'exporting', 'exports': 'exporting',
        'import': 'importing', 'imports': 'importing',
        'write': 'writing', 'writes': 'writing',
        'read': 'reading', 'reads': 'reading',
        'save': 'saving', 'saves': 'saving',
        'load': 'loading', 'loads': 'loading',
        'fetch': 'fetching', 'fetches': 'fetching',
        'crawl': 'crawling', 'crawls': 'crawling',
        'scrape': 'scraping', 'scrapes': 'scraping',
        'capture': 'capturing', 'captures': 'capturing',
        'record': 'recording', 'records': 'recording',
        'define': 'defining', 'defines': 'defining',
        'design': 'designing', 'designs': 'designing',
        'plan': 'planning', 'plans': 'planning',
        'review': 'reviewing', 'reviews': 'reviewing',
        'evaluate': 'evaluating', 'evaluates': 'evaluating',
        'assess': 'assessing', 'assesses': 'assessing',
        'transform': 'transforming', 'transforms': 'transforming',
        'format': 'formatting', 'formats': 'formatting',
        'style': 'styling', 'styles': 'styling',
        'teach': 'teaching', 'teaches': 'teaching',
        'guide': 'guiding', 'guides': 'guiding',
        'help': 'helping', 'helps': 'helping',
        'provide': 'providing', 'provides': 'providing',
        'specify': 'specifying', 'specifies': 'specifying',
        'describe': 'describing', 'describes': 'describing',
        'track': 'tracking', 'tracks': 'tracking',
        'log': 'logging', 'logs': 'logging',
        'trace': 'tracing', 'traces': 'tracing',
    }

    # "Verb-ing something" → "Use when verb-ing something"
    if re.match(r'^[A-Z][a-z]*ing\b', desc):
        return f"Use when {smart_lower_first(desc)}"

    # Check first word against verb map (imperative or 3rd person)
    first_word = desc.split()[0].lower()
    if first_word in verb_map:
        rest = desc[len(desc.split()[0]):].strip()
        return f"Use when {verb_map[first_word]} {rest}"

    # "A/An/The noun..." → "Use when working with noun..."
    if re.match(r'^(A|An|The)\s', desc):
        cleaned = re.sub(r'^(A|An|The)\s+', '', desc)
        return f"Use when working with {smart_lower_first(cleaned)}"

    # "For doing X" → "Use when doing X"
    if desc.lower().startswith('for '):
        return f"Use when {desc[4:]}"

    # Non-ASCII start (Korean etc.) — prepend without lowercasing
    if ord(desc[0]) > 127:
        return f"Use when needing {desc}"

    # Fallback for English noun phrases — prepend "Use when needing"
    return f"Use when needing {smart_lower_first(desc)}"


def process_file(filepath):
    """Process a single skill file for P1-P3 fixes."""
    basename = os.path.basename(filepath)
    if basename in SKIP_FILES:
        stats["skipped"] += 1
        return []

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    changes = []
    modified = False

    # Check for frontmatter
    has_frontmatter = False
    fm_start = -1
    fm_end = -1
    if lines and lines[0].strip() == '---':
        for i in range(1, len(lines)):
            if lines[i].strip() == '---':
                fm_end = i
                has_frontmatter = True
                break

    if not has_frontmatter:
        # P1: Add frontmatter
        name = normalize_name(filepath)
        # Try to extract a description from first heading + paragraph
        desc_candidate = None
        for line in lines:
            if line.startswith('# ') and not desc_candidate:
                heading = line[2:].strip()
                desc_candidate = heading
                break

        if desc_candidate:
            desc = transform_description_to_use_when(desc_candidate)
            if not desc:
                desc = f"Use when working with {desc_candidate.lower()}"
        else:
            desc = f"Use when working with {name.replace('-', ' ')}"

        new_fm = f"---\nname: {name}\ndescription: {desc}\n---\n\n"
        content = new_fm + content
        modified = True
        changes.append(f"P1: Added frontmatter (name={name})")
        changes.append(f"P3: Set description to '{desc}'")
        stats["p1"] += 1
        stats["p3"] += 1
    else:
        # Extract existing frontmatter fields
        fm_lines = lines[1:fm_end]
        fm_text = '\n'.join(fm_lines)

        # P2: Check name field
        name_match = re.search(r'^name:\s*(.+)$', fm_text, re.MULTILINE)
        if name_match:
            current_name = name_match.group(1).strip().strip('"').strip("'")
            if not re.match(r'^[A-Za-z0-9-]+$', current_name):
                new_name = normalize_name(filepath)
                old_line = name_match.group(0)
                new_line = f"name: {new_name}"
                content = content.replace(old_line, new_line, 1)
                modified = True
                changes.append(f"P2: Normalized name '{current_name}' → '{new_name}'")
                stats["p2"] += 1
        else:
            # No name field at all
            new_name = normalize_name(filepath)
            # Insert name after first ---
            content = content.replace('---\n', f'---\nname: {new_name}\n', 1)
            modified = True
            changes.append(f"P2: Added name field '{new_name}'")
            stats["p2"] += 1

        # P3: Check description field
        desc_match = re.search(r'^description:\s*(.+)$', fm_text, re.MULTILINE)
        if desc_match:
            current_desc = desc_match.group(1).strip().strip('"').strip("'")
            if not re.match(r'^[Uu]se when\b', current_desc):
                new_desc = transform_description_to_use_when(current_desc)
                if new_desc:
                    old_line = desc_match.group(0)
                    new_line = f"description: {new_desc}"
                    content = content.replace(old_line, new_line, 1)
                    modified = True
                    changes.append(f"P3: '{current_desc[:50]}...' → '{new_desc[:50]}...'")
                    stats["p3"] += 1
        else:
            # No description field
            name_val = normalize_name(filepath)
            desc = f"Use when working with {name_val.replace('-', ' ')}"
            # Insert after name line or after first ---
            if 'name:' in content.split('---')[1]:
                name_line_match = re.search(r'^name:.*$', content, re.MULTILINE)
                if name_line_match:
                    insert_pos = name_line_match.end()
                    content = content[:insert_pos] + f"\ndescription: {desc}" + content[insert_pos:]
            else:
                content = content.replace('---\n', f'---\ndescription: {desc}\n', 1)
            modified = True
            changes.append(f"P3: Added description '{desc}'")
            stats["p3"] += 1

    if modified and not DRY_RUN:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    stats["files"] += 1
    return changes


def scan_skills(directory):
    """Scan for skill files (matching diagnose.sh logic)."""
    skill_files = []
    for root, dirs, files in os.walk(directory):
        # Skip references/ directories
        if 'references' in root.split(os.sep):
            continue
        for f in sorted(files):
            if not f.endswith('.md'):
                continue
            filepath = os.path.join(root, f)
            # If SKILL.md exists in this dir, skip other .md files
            if f != 'SKILL.md' and os.path.exists(os.path.join(root, 'SKILL.md')):
                continue
            skill_files.append(filepath)
    return skill_files


def main():
    mode = "DRY RUN" if DRY_RUN else "APPLY"
    print(f"Skills 2.0 P1-P3 Batch Fix ({mode})")
    print(f"Target: {SKILLS_DIR}")
    print("=" * 50)

    # Support individual files, multiple files, or directory scan
    if os.path.isfile(SKILLS_DIR):
        # Single file provided as first argument
        skill_files = [SKILLS_DIR] + [f for f in EXTRA_TARGETS if os.path.isfile(f)]
    elif EXTRA_TARGETS:
        # Directory + additional specific file names
        all_skills = scan_skills(SKILLS_DIR)
        skill_files = []
        for t in EXTRA_TARGETS:
            # Try to find by name in the directory
            candidates = [s for s in all_skills if os.path.basename(s).replace('.md', '').replace('/SKILL', '') == t
                          or t in s]
            skill_files.extend(candidates)
        if not skill_files:
            skill_files = all_skills  # fallback to all
    else:
        skill_files = scan_skills(SKILLS_DIR)

    print(f"Found {len(skill_files)} skill files\n")

    all_changes = []
    for filepath in skill_files:
        changes = process_file(filepath)
        if changes:
            rel = os.path.relpath(filepath, SKILLS_DIR)
            all_changes.append((rel, changes))
            for c in changes:
                print(f"  [{rel}] {c}")

    print(f"\n{'=' * 50}")
    print(f"Summary:")
    print(f"  Files processed: {stats['files']}")
    print(f"  P1 (frontmatter added): {stats['p1']}")
    print(f"  P2 (name normalized): {stats['p2']}")
    print(f"  P3 (description fixed): {stats['p3']}")
    print(f"  Skipped: {stats['skipped']}")
    print(f"  Total changes: {stats['p1'] + stats['p2'] + stats['p3']}")
    if DRY_RUN:
        print(f"\n  (Dry run — no files modified)")


if __name__ == "__main__":
    main()
