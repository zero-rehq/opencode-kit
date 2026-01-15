---
description: "Wrap task: snapshot after, CI best-effort, jira note, commit/PR prompt"
agent: orchestrator
---

# Comando /wrap

Cierra un task con evidencia completa: snapshot, CI, nota Jira, y opción de commit/PR.

## Workflow

### 1. Delegar a @scribe

Orchestrator delega todo el wrap a @scribe.

```
Task: @scribe
Prompt: Execute wrap for task "<task>". Follow wrap protocol.
```

### 2. @scribe Ejecuta Wrap Protocol

#### A. Snapshot After
```bash
./scripts/oc-wrap "<task>"
```

Esto agrega al worklog:
- Git status por repo target
- Últimos commits (git log -3) por repo
- Diffstat acumulado (líneas agregadas/eliminadas)

#### B. CI Best-Effort
```bash
./scripts/oc-gate "<task>"
```

Esto genera `worklog/<date>_ci_<task>.md` con:
- lint/format/typecheck/build por repo target
- Exit codes (ok/fail/na)

#### C. Jira Note
```bash
./scripts/oc-jira-note "<task>"
```

Esto genera nota para Jira basada en:
- E2E_TRACE del worklog
- Cambios implementados (archivos + commits)
- Evidencia de gates (CI results)

Formato:
```md
## Task: <task> (2026-01-15)

### Summary
<qué se implementó en 2-3 oraciones>

### Repos Affected
- cloud_front: CatalogosPage UI + hooks
- signage_service: API /catalogos + DB migration
- ftp: paths para catálogo images

### E2E Flow
<copiar E2E_TRACE del worklog>

### Quality Gates
- lint: ✅ All repos
- typecheck: ✅ All repos
- build: ✅ All repos

### Commits
<últimos commits por repo>

### Evidence
- Worklog: worklog/2026-01-15_<task>.md
- CI Report: worklog/2026-01-15_ci_<task>.md
```

#### D. Flags Opcionales

**--release**: Lanzar release-notes skill
```bash
# Si hay flag --release:
# Lanzar release-notes skill para generar CHANGELOG.md entry
Task: release-notes
Prompt: Generate release notes for task "<task>" based on worklog and commits
```

**--sync-docs**: Lanzar documentation-sync skill
```bash
# Si hay flag --sync-docs:
# Lanzar documentation-sync skill para detectar drift
Task: documentation-sync
Prompt: Check documentation drift for repos in task "<task>"
```

### 3. Preguntar Commit/PR

Después de wrap, orchestrator pregunta:

```
✅ Wrap completed for task: <task>

📸 Snapshot after: ✅
🔬 CI best-effort: ✅ (3/3 repos passed)
📝 Jira note: ✅

What next?
1. Create commits (per repo)
2. Create PRs (per repo)
3. Both (commits + PRs)
4. Nothing (manual commit later)
```

#### Opción 1: Create Commits
```bash
# Por cada repo target:
cd <repo>
git add .
git commit -m "oc(<task>): <summary>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

#### Opción 2: Create PRs
```bash
# Por cada repo target:
cd <repo>
# Crear rama si no existe
git checkout -b oc/<task> || git checkout oc/<task>

# Push to remote (si existe)
git push -u origin oc/<task>

# Crear PR con gh CLI
gh pr create --title "oc(<task>): <summary>" \
  --body "$(cat <<EOF
## Summary
<del worklog>

## E2E_TRACE
<del worklog>

## Evidence
- Worklog: worklog/<date>_<task>.md
- CI: worklog/<date>_ci_<task>.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Flags opcionales

- `/wrap <task>` - forma básica
- `/wrap <task> --release` - genera también CHANGELOG entry
- `/wrap <task> --sync-docs` - verifica drift en docs
- `/wrap <task> --auto-commit` - skip pregunta, commit auto
- `/wrap <task> --auto-pr` - skip pregunta, PR auto

---

## Output esperado

```
👷 Delegating to @scribe...

📸 Snapshot after...
   - cloud_front: 12 files changed, +245/-18
   - signage_service: 8 files changed, +187/-5
   - ftp: 3 files changed, +42/-0

🔬 Running CI (best-effort)...
   - cloud_front: lint ✅ typecheck ✅ build ✅
   - signage_service: lint ✅ typecheck ✅ build ✅
   - ftp: check ✅ build ✅

📝 Generating Jira note...
   - worklog/2026-01-15_jira_catalogos.md: ✅

✅ Wrap completed!

📊 Summary:
   - 3 repos affected
   - 23 files changed (+474/-23)
   - All gates passed ✅

What next?
1. Create commits (per repo)
2. Create PRs (per repo)
3. Both (commits + PRs)
4. Nothing (manual commit later)

> User selects: 3

🚀 Creating commits...
   - cloud_front: ✅ oc(catalogos): Add CatalogosPage UI
   - signage_service: ✅ oc(catalogos): Add catalogos API + DB
   - ftp: ✅ oc(catalogos): Add catalogo image paths

🔀 Creating PRs...
   - cloud_front: ✅ PR #42 (https://github.com/org/cloud_front/pull/42)
   - signage_service: ✅ PR #18 (https://github.com/org/signage_service/pull/18)
   - ftp: ✅ PR #7 (https://github.com/org/ftp/pull/7)

✨ Done!
```

---

## Notas

- Wrap no falla si CI falla → best-effort (reporta fails pero continúa)
- Si repo no tiene remote → skip PR, solo commit local
- Si rama oc/<task> ya existe → reuse (no crea nueva)
- Jira note es markdown → user puede copiar/pegar a Jira ticket
- release-notes y documentation-sync son opcionales (flags)
