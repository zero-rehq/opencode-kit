# Referencia Completa de Comandos

## Introdución

Este documento contiene TODOS los comandos y scripts disponibles en opencode-kit para el workflow multi-repo E2E con Skills Routing System.

## Comandos Slash (User-Facing)

### /bootstrap
**Descripción**: Auto-detecta todos los repos del workspace y genera AGENTS.md por cada uno.

**Uso**:
```bash
USER: /bootstrap
```

**Qué hace**:
1. Auto-detecta todos los repos del workspace
2. Domain classification: "Setup/Configuration" (100% confidence)
3. Skills recommendation: prompt-generator (bridge) activado
4. Genera `<repo>/AGENTS.md` con stack, scripts, entrypoints
5. Crea service catalog en `worklog/service-catalog.md`

**Output**:
```
🔍 Found N repos: cloud_front, signage_service, ftp, etouch, cloud_tag_back
🎯 Domain: Configuration (100% confidence)
🤖 Skills: prompt-generator (bridge) activated
📝 Generated AGENTS.md for N repos
📊 Service catalog: worklog/service-catalog.md
```

**Script**: `.opencode/bin/oc-bootstrap-repos`

---

### /task <nombre>
**Descripción**: Inicia task con discovery paralelo + Task Brief automático y Skills Routing.

**Uso**:
```bash
USER: /task catalogos
```

**Qué hace**:
1. **domain-classifier**: Clasifica task en dominios (UI/UX, API/Backend, Feature, etc.)
2. **skills-router-agent**: Analiza y recomienda skills
   ```
   ✅ domain-classifier (ya ejecutado)
   ✅ intelligent-prompt-generator (para brief)
   ✅ prompt-analyzer (para calidad)
   ✅ ui-ux-pro-max (UI task detectado)
   ✅ react-best-practices (React/Next.js detectado)
   ```
3. **intelligent-prompt-generator**: Genera Task Brief optimizado
4. **prompt-analyzer**: Valida calidad del brief (Quality Score 0-100)
5. Lanza repo-scouts EN PARALELO (N repo-scouts, 1 mensaje)
6. Sintetiza discovery + delega a @builder

**Output**:
```
🎯 Task initialized: <task>
📊 Domain Classification:
   - UI/UX: 90%
   - API/Backend: 85%
   - Feature: 75%
🤖 Skills Activated:
   - domain-classifier ✅
   - intelligent-prompt-generator ✅
   - prompt-analyzer ✅
   - ui-ux-pro-max ✅
   - react-best-practices ✅
📁 Worklog: worklog/<date>_<task>.md
🎯 Targets: .opencode/targets/<date>_<task>.txt
🔍 Discovery (parallel)...
   - repo-scout repo1: ✅
   - repo-scout repo2: ✅
   - repo-scout repoN: ✅
👷 Delegating to @builder...
```

**Opciones**:
- `/task <nombre>` - Forma básica
- `/task <nombre> --auto "<query>"` - Auto-detectar repos por keyword
- `/task <nombre> --repos repo1,repo2` - Especificar repos manualmente

**Scripts**: `.opencode/bin/oc-task` → llama a `.opencode/command/task.md`

---

### /wrap <nombre>
**Descripción**: Cierra task con snapshot, CI, Jira note y opción commit/PR.

**Uso**:
```bash
USER: /wrap catalogos
```

**Qué hace**:
1. Ejecuta `./scripts/oc-wrap <task>` (snapshot after + commits)
2. Ejecuta `./scripts/oc-gate <task>` (CI best-effort)
3. Ejecuta `./scripts/oc-jira-note <task>` (Jira note)
4. Pregunta: "¿Commit y PR?"

**Output**:
```
📸 Snapshot after: N repos, M files changed
🔬 CI best-effort: All gates passed ✅
📝 Jira note: worklog/<date>_jira_<task>.md
✨ Done!

What next?
1. Create commits (per repo)
2. Create PRs (per repo)
3. Both
4. Nothing
```

**Scripts**:
- `.opencode/bin/oc-wrap` → llama a `.opencode/command/wrap.md`
- `.opencode/bin/oc-gate`
- `.opencode/bin/oc-jira-note`

---

### /gate <nombre>
**Descripción**: Corre gates en repos targets (best-effort).

**Uso**:
```bash
USER: /gate catalogos
```

**Qué hace**:
- Lee targets desde `.opencode/targets/<task>.txt`
- Ejecuta gates por repo:
  - lint
  - format
  - typecheck
  - build
- Genera reporte de resultados

**Output**:
```
Running gates for task: <task>

Repo: repo1
  - pnpm lint: ✅ PASSED
  - pnpm typecheck: ✅ PASSED
  - pnpm build: ✅ PASSED

Repo: repo2
  - pnpm lint: ✅ PASSED
  - pnpm typecheck: ✅ PASSED
  - pnpm build: ✅ PASSED

...
Summary: All gates passed ✅
```

**Script**: `.opencode/bin/oc-gate`

---

## Comandos Internos (Scripts)

### oc-repos (Admin de Repos)
**Descripción**: Lista repos conocidos en el workspace.

**Uso**:
```bash
USER: /task oc-repos
```

**Script**: `.opencode/bin/oc-repos`

---

### oc-targets (Gestión de Targets)
**Descripción**: Maneja targets para tasks (auto-detect, set, list, clear).

**Comandos**:
```bash
# Inicializar targets
/scripts/oc-targets init <task>

# Auto-detectar por query
/scripts/oc-targets auto <task> "<query>"

# Especificar repos manualmente
/scripts/oc-targets set <task> repo1,repo2,repo3

# Listar targets actuales
/scripts/oc-targets list

# Limpiar targets
/scripts/oc-targets clear <task>
```

**Opciones**:
- `init <task>` - Crear targets file vacío
- `auto <task> <query>` - Auto-detectar repos por keyword
- `set <task> repo1,repo2` - Especificar repos manualmente
- `list <task>` - Mostrar repos actuales
- `add <task> <repo>` - Agregar repo a targets
- `remove <task> <repo>` - Remover repo de targets
- `clear <task>` - Limpiar todos los targets

**Script**: `.opencode/bin/oc-targets`

---

### oc-snapshot (Snapshots de Git)
**Descripción**: Captura snapshot de git status por repo.

**Uso**:
```bash
# Snapshot before de task
./scripts/oc-snapshot <task>

# Snapshot after de task (automático en wrap)
./scripts/oc-snapshot <task> after
```

**Opciones**:
- `<task>` - Nombre de la tarea (por defecto usa actual)
- `before` - Marcar como "before snapshot"
- `after` - Marcar como "after snapshot" (por defecto)

**Output**:
```
📸 Snapshot captured for task: <task>
   Repo: repo1
     Branch: main
     Files: 42
     Modified: 12
   Repo: repo2
     Branch: feature/catálogos
     Files: 15
     Modified: 8
   ...
```

**Script**: `.opencode/bin/oc-snapshot`

---

### oc-run-ci (Quality Gates CI)
**Descripción**: Ejecuta gates CI en repos targets con best-effort.

**Uso**:
```bash
# Ejecutar todos los gates para un task
./scripts/oc-run-ci <task>
```

**Opciones**:
- `<task>` - Nombre de la tarea
- `--continue` - Continuar aunque falle un gate
- `--fail-fast` - Detener al primer gate que falle

**Output**:
```
Running CI for task: <task>

Running: pnpm lint
  Repo1: ✅ PASSED
  Repo2: ✅ PASSED
  ...

Running: pnpm typecheck
  Repo1: ✅ PASSED
  Repo2: ⚠️ FAILED
    Error: Type error in src/components/Button.tsx:15
    ...

Summary:
  - lint: 2/2 repos passed
  - typecheck: 1/2 repos passed
  - build: not run (typecheck failed)
```

**Script**: `.opencode/bin/oc-run-ci`

---

### oc-bootstrap-repos (Bootstrap Automático)
**Descripción**: Auto-detecta repos y genera AGENTS.md para cada uno.

**Uso**:
```bash
USER: /task oc-bootstrap-repos
```

**Qué hace**:
1. Busca package.json en cada directorio del workspace
2. Identifica stack (Node.js, Python, Go, etc.)
3. Genera `<repo>/AGENTS.md` con stack, scripts, entrypoints

**Opciones**:
- `--service-yaml <file>` - Usar YAML personalizado de servicios
- `--force` - Regenerar AGENTS.md incluso si existe

**Script**: `.opencode/bin/oc-bootstrap-repos`

---

### oc-catalog-sync (Sincronización de Catalogos)
**Descripción**: Sincroniza catálogos de servicios con el workspace.

**Uso**:
```bash
# Sincronizar catálogos
./scripts/oc-catalog-sync
```

**Opciones**:
- `--force` - Regenerar incluso si ya existe

**Script**: `.opencode/bin/oc-catalog-sync`

---

### oc-no-any (Escáneo de TypeScript `any`)
**Descripción**: Escanea repos buscando usos de `any` en TypeScript.

**Uso**:
```bash
# Escanear repos en targets
./scripts/oc-no-any <task>

# Escanear repos específicos
./scripts/oc-no-any <task> repo1,repo2,repo3
```

**Opciones**:
- `--force` - Regenerar informe aunque no haya cambios
- `--fix` - Intentar autofix de tipos unknown

**Output**:
```
Scanning for any usage...

Repo: cloud_front
  src/app/page.tsx:12 - "any" type found
  src/components/Card.tsx:45 - "any" type found
  ...
  Total: 3 occurrences

Repo: signage_service
  src/api/catalogos.ts:8 - "any" type found
  Total: 1 occurrence

Summary:
  Total occurrences: 4
  Repos with any: 2/3

Recommendation:
  Review and replace `any` with specific types or `unknown`
  Run ./scripts/oc-no-any --fix to attempt auto-replacement
```

**Script**: `.opencode/bin/oc-no-any`

---

### oc-e2e-trace (Plantilla E2E_TRACE)
**Descripción**: Inserta plantilla de E2E_TRACE en worklog.

**Uso**:
```bash
# Insertar plantilla en worklog
./scripts/oc-e2e-trace <task>
```

**Opciones**:
- `<task>` - Nombre de la tarea

**Output**:
```
E2E_TRACE template inserted in worklog/<date>_<task>.md

You can now fill in:
- Entry UI:
- Front client/hook:
- Backend endpoint:
- Service/internal call(s):
- External integration (proxy/storage/DB):
- Response shape:
- UI states affected:
```

**Script**: `.opencode/bin/oc-e2e-trace`

---

### oc-gate (Ejecutar Gates)
**Descripción**: Ejecuta gates y genera reporte para reviewer.

**Uso**:
```bash
# Ejecutar gates para task
./scripts/oc-gate <task>
```

**Output**:
```
Running gates for task: <task>

Lint:
  - cloud_front: ✅ PASSED (0 errors)
  - signage_service: ✅ PASSED (0 errors)
  ...

Typecheck:
  - cloud_front: ✅ PASSED (0 errors)
  - signage_service: ✅ PASSED (0 errors)
  ...

Build:
  - cloud_front: ✅ PASSED
  - signage_service: ✅ PASSED (0 errors)
  ...

GATE_REQUEST generated successfully 📤
```

**Script**: `.opencode/bin/oc-gate`

---

### oc-jira-note (Nota para Jira)
**Descripción**: Genera nota profesional para Jira desde worklog.

**Uso**:
```bash
# Generar nota Jira
./scripts/oc-jira-note <task>
```

**Output**:
```
📝 JIRA_COMMENT generated: worklog/<date>_jira_<task>.md

Ready to paste into Jira:

[What was done]
- Added catalogos listing page
- Integrated with signage_service API

[What was tested]
- Manual testing of UI
- API testing of endpoints
- E2E trace verified in code

[Risks]
- No automated tests (NICE_TO_HAVE)

[Pending]
- Add E2E automated tests
- Implement pagination for large catalogs

```

**Script**: `.opencode/bin/oc-jira-note`

---

### oc-wrap (Wrap Completo)
**Descripción**: Ejecuta wrap completo con snapshot, commits, CI y Jira note.

**Uso**:
```bash
USER: /wrap catalogos
```

**Qué hace**:
1. Ejecuta `./scripts/oc-snapshot <task> after`
2. Ejecuta `./scripts/oc-run-ci <task>` (CI best-effort)
3. Ejecuta `./scripts/oc-jira-note <task>`
4. Pregunta: "¿Commit y PR?"

**Output**:
```
📸 Snapshot after: 3 repos, 23 files changed
🔬 CI best-effort: All gates passed ✅
📝 Jira note: worklog/2026-01-15_jira_catalogos.md

✨ Task wrap complete!

What next?
1. Create commits (per repo)
2. Create PRs (per repo)
3. Both
4. Nothing
```

**Script**: `.opencode/bin/oc-wrap`

---

### oc-gate-quick (Gates Rápidos)
**Descripción**: Ejecuta gates rápidamente (solo lint/typecheck, sin build).

**Uso**:
```bash
# Ejecutar gates rápidos
./scripts/oc-gate-quick <task>
```

**Script**: `.opencode/bin/oc-gate-quick` (ver si existe)

---

### Templates (.opencode/templates/)

### task-brief.md
**Descripción**: Template para generar Task Brief de Orchestrator → Builder.

**Contenido**: Estructura estándar con:
- Task info
- Contexto (supermemory)
- Scope
- Repos afectados
- E2E_TRACE requerido
- Definition of Done
- Gates requeridos
- Active skills

**Uso**: Utilizado automáticamente por `intelligent-prompt-generator`

---

### phase-brief.md
**Descripción**: Template para generar Phase Brief de Orchestrator → Subagente.

**Contenido**: Estructura similar a task-brief pero para fases específicas.

**Uso**: Utilizado para subagentes específicos.

---

### gate-request.md
**Descripción**: Template para que Builder envía a Reviewer.

**Contenido**:
- PHASE_SUMMARY
- COMMANDS_RUN
- E2E_TRACE
- FILES_CHANGED
- Qué validar en reviewer

**Uso**: Utilizado automáticamente por Builder antes de pedir gate.

---

### review-decision.md
**Descripción**: Template para que Reviewer envía a Orchestrator.

**Contenido**:
- REVIEW_DECISION: PASS o FAIL
- REQUIRED_CHANGES (si FAIL)
- NICE_TO_HAVE (opcional)

**Uso**: Utilizado por Reviewer después de validar.

---

## Scripts de Utilidad

### render_template.py
**Descripción**: Renderiza templates markdown a HTML u otros formatos.

**Uso**: Utilizado internamente por scripts de templates.

---

## Resumen de Skills en Scripts

Los scripts de gates y validación utilizan los skills siguientes:

### oc-run-ci
- **react-best-practices**: Valida código contra 45 reglas CRITICAL/HIGH/MEDIUM
- **web-design-guidelines**: Valida UI contra 100+ rules CRITICAL

### oc-gate, oc-no-any
- **react-best-practices**: Valida reglas de performance
- **web-design-guidelines**: Valida reglas de a11y y UI

### oc-task (inicialización de task)
- **domain-classifier**: Clasifica dominios (12 categorías)
- **skills-router-agent**: Recomienda skills basado en dominios
- **intelligent-prompt-generator**: Genera Task Brief con contexto
- **prompt-analyzer**: Valida calidad del brief

### oc-wrap (cierre de task)
- **release-notes**: Genera CHANGELOG profesional
- No usa skills específicos

## Workflow Completo con Skills Routing

```
Usuario request
    ↓
Orchestrator + skills-router-agent
    ↓
domain-classifier (12 dominios)
    ↓
skills-router-agent (recomienda skills)
    ↓
intelligent-prompt-generator (Task Brief)
    ↓
prompt-analyzer (Quality Score)
    ↓
[Task Brief con Skills Activados]
    ↓
Builder con Skills (ui-ux-pro-max, react-best-practices)
    ↓
[Gates con Skills de validación]
    ↓
Reviewer con Skills (web-design-guidelines, react-best-practices)
    ↓
[Review Decision]
    ↓
Scribe (release-notes)
    ↓
Supermemory (learnings)
```

## Referencias

Para más información:
- [README](../README.md) - Documentación principal
- [Skills Usage](./docs/skills-usage.md) - Guía detallada de skills
- [Agents Reference](./docs/agents.md) - Referencia de agentes
- [Skills Creation Guide](./docs/skills-creation-guide.md) - Tutorial de skills
- [Skills Troubleshooting](./docs/skills-troubleshooting.md) - Solución de problemas
- [Skills Supermemory Integration](./docs/skills-supermemory-integration.md) - Integración con supermemory
- [SKILLS_ROUTER](../.opencode/SKILLS_ROUTER.md) - Índice central de skills

---

**Última actualización**: 2026-01-15
**Versión**: v8.5 (Skills Routing System completo)
