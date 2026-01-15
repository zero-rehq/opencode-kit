---
name: Release Notes (Changelog Generator)
description: Genera changelog profesional + GitHub release notes desde commits y worklog
compatibility: opencode
trigger_keywords: ["release", "changelog", "version", "notes"]
source: SkillsMP - meirm-askgpt-writing-release-notes
---

# Release Notes Skill

Genera changelog profesional + GitHub release notes desde commits, worklog y E2E_TRACE.

## Triggers

- `/wrap <task> --release`
- "Generate release notes for v2.1.0"
- "Create CHANGELOG entry"

## Features

✅ **Auto-detecta changes** desde:
- Git commits (conventionalcommits format)
- Worklog (PHASE_SUMMARY + E2E_TRACE)
- Git diff stats

✅ **Categoriza changes**:
- Added (new features)
- Changed (enhancements)
- Fixed (bug fixes)
- Deprecated (soon-to-be-removed)
- Removed (deleted features)
- Security (security fixes)

✅ **Genera múltiples formatos**:
- CHANGELOG.md entry (Keep a Changelog format)
- GitHub release notes (markdown)
- Jira release summary (for ticket)

## Formato: Keep a Changelog

```markdown
## [v2.1.0] - 2026-01-15

### Added
- Catálogos feature across 5 repos
  - signage_service: DB table + API endpoint `/api/catalogos`
  - cloud_tag_back: Artículos by catálogo endpoint
  - ftp_proxy: Image paths for catálogo images
  - cloud_front: CatalogosPage with grid UI
  - etouch: Menu entry for catálogos

### Changed
- API client refactored to use shared library (#123)

### Fixed
- Auth token expiration issue in signage_service (#98)

### Technical Details
- E2E_TRACE: etouch menu → cloud_front UI → signage_service API → DB
- Contract: CatalogoDTO shared across repos
- Assets: FTP proxy for catálogo images
- Tests: Added e2e tests for catálogos flow

### Breaking Changes
None

### Migration Guide
No migration needed. Feature is additive.
```

## Workflow

### 1. Analizar Commits

```bash
# Get commits since last release
git log v2.0.0..HEAD --oneline --no-merges

# Parse conventional commits format:
# feat: add catalogos feature
# fix: resolve auth token issue
# chore: update dependencies
```

### 2. Leer Worklog

```bash
# Parse worklog for E2E_TRACE + PHASE_SUMMARY
WORKLOG="worklog/2026-01-15_catalogos.md"

# Extract:
# - What was implemented (PHASE_SUMMARY)
# - E2E flow (E2E_TRACE)
# - Repos affected
# - Breaking changes (if any)
```

### 3. Categorizar Changes

```typescript
function categorize(commits: Commit[]): Categories {
  const categories = {
    added: [],
    changed: [],
    fixed: [],
    deprecated: [],
    removed: [],
    security: []
  };

  for (const commit of commits) {
    if (commit.message.startsWith('feat:')) {
      categories.added.push(commit);
    } else if (commit.message.startsWith('fix:')) {
      categories.fixed.push(commit);
    } else if (commit.message.startsWith('refactor:')) {
      categories.changed.push(commit);
    }
    // ... etc
  }

  return categories;
}
```

### 4. Generar CHANGELOG Entry

```markdown
## [${VERSION}] - ${DATE}

${categorize(commits).map(category =>
  `### ${category.title}\n` +
  category.items.map(item => `- ${item.description}`).join('\n')
).join('\n\n')}

### Technical Details
${E2E_TRACE}
${contracts}
${breaking_changes || 'None'}
```

### 5. Generar GitHub Release

```bash
# Create GitHub release using gh CLI
gh release create v2.1.0 \
  --title "v2.1.0 - Catálogos Feature" \
  --notes-file RELEASE_NOTES.md
```

## Script (generate-release-notes.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
TASK="${2:-}"

[[ -n "$VERSION" ]] || { echo "Usage: $0 <version> [task]"; exit 1; }

echo "📝 Generating release notes for $VERSION..."

# Get commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -n "$LAST_TAG" ]]; then
  COMMITS=$(git log "$LAST_TAG..HEAD" --oneline --no-merges)
else
  COMMITS=$(git log --oneline --no-merges)
fi

# Parse commits into categories
ADDED=()
FIXED=()
CHANGED=()

while IFS= read -r commit; do
  if [[ "$commit" =~ feat:|add: ]]; then
    ADDED+=("$commit")
  elif [[ "$commit" =~ fix: ]]; then
    FIXED+=("$commit")
  elif [[ "$commit" =~ refactor:|update: ]]; then
    CHANGED+=("$commit")
  fi
done <<< "$COMMITS"

# Generate CHANGELOG entry
cat > CHANGELOG_ENTRY.md <<EOF
## [$VERSION] - $(date +%Y-%m-%d)

### Added
$(printf '%s\n' "${ADDED[@]}" | sed 's/^[a-f0-9]* /- /')

### Changed
$(printf '%s\n' "${CHANGED[@]}" | sed 's/^[a-f0-9]* /- /')

### Fixed
$(printf '%s\n' "${FIXED[@]}" | sed 's/^[a-f0-9]* /- /')

### Technical Details
$(if [[ -n "$TASK" ]]; then
  WORKLOG="worklog/$(date +%F)_${TASK}.md"
  if [[ -f "$WORKLOG" ]]; then
    grep -A 20 "## E2E_TRACE" "$WORKLOG" || echo "See worklog for details"
  fi
fi)
EOF

echo "✅ Release notes generated: CHANGELOG_ENTRY.md"
echo ""
cat CHANGELOG_ENTRY.md
```

## Uso desde /wrap

```
USER: /wrap catalogos --release

Orchestrator → @scribe:
1. Ejecuta oc-wrap catalogos (normal wrap)
2. AUTO-TRIGGER release-notes:
   - Analiza commits desde último tag
   - Lee worklog/E2E_TRACE
   - Genera CHANGELOG entry
   - Pregunta: "¿Crear GitHub release?"
3. Si user acepta:
   - Prepend entry a CHANGELOG.md
   - gh release create v2.1.0 --notes-file ...
```

## Output Ejemplo

```
✅ Release notes generated!

📄 CHANGELOG.md updated
🚀 GitHub release created: v2.1.0

Release URL: https://github.com/org/repo/releases/tag/v2.1.0

Changelog entry:
────────────────────────────────────────────────
## [v2.1.0] - 2026-01-15

### Added
- Catálogos feature across 5 repos
  - signage_service: DB + API
  - cloud_front: UI with CatalogosPage
  - ftp: Image proxy paths

### Technical Details
- E2E flow: UI → API → DB → Proxy → UI
- Contract: CatalogoDTO
────────────────────────────────────────────────
```

## Convenciones Soportadas

### Conventional Commits
```
feat: add new feature
fix: bug fix
refactor: code refactor
docs: documentation
chore: maintenance
```

### Semantic Versioning
```
MAJOR.MINOR.PATCH
2.1.0 → 2.2.0 (minor - new feature)
2.1.0 → 3.0.0 (major - breaking change)
2.1.0 → 2.1.1 (patch - bug fix)
```

## Notas

- Si no hay git tags → usa todos los commits
- Breaking changes detectados por: `BREAKING CHANGE:` en commit body
- Multi-repo: consolida commits de todos los repos targets
- Formato Keep a Changelog es estándar de industria

---

**Version**: 1.0
**Docs**: https://keepachangelog.com
**Source**: SkillsMP + Conventional Commits
