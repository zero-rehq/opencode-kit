# OpenCode Multi‑Repo Kit v8 (E2E Definitivo)

Kit para trabajar **E2E en N repos** con OpenCode, usando **agentes + subagentes especializados**, *targets dinámicos*, trazabilidad completa (worklog), gates automáticos y **discovery paralelo** con foco en **E2E_TRACE**.

## 🚀 Qué hay de nuevo (v8)

### ✅ Targets Dinámicos (No más hardcoding!)
- `/gate` ahora lee targets desde `.opencode/targets/<task>.txt` o auto-detecta repos
- Funciona con 2, 5, 10 o N repos sin cambiar código
- Fallback inteligente: si no hay targets → auto-detecta package.json

### ✅ Subagentes Especializados
- **repo-scout**: Discovery paralelo (uno por repo, simultáneo)
- **contract-keeper**: Validación cross-repo (DTOs, endpoints, eventos)
- **integration-builder**: Coordinación de cambios en 3+ repos con dependencias
- **docs-specialist**: Mantiene docs alineadas con código (drift detection)
- **bootstrap-scout**: Analiza repos y genera AGENTS.md automáticamente

### ✅ Comandos Slash Completos
- `/task <nombre>`: Inicia task con discovery paralelo + Task Brief automático
- `/bootstrap`: Auto-detecta repos + genera AGENTS.md por cada uno
- `/wrap <nombre>`: Cierra task con snapshot, CI, Jira note, y opción commit/PR

### ✅ Templates Profesionales
- **Phase Brief**: Template para orchestrator → subagente
- **Gate Request**: Template para builder → reviewer
- **Review Decision**: Template para reviewer → orchestrator

### ✅ Supermemory Integration (preparado)
- Orchestrator: Context loading automático
- Builder: Query patterns antes de implementar
- Scribe: Post-task learning (guarda contratos, decisiones, errores)

### ✅ Paralelización Real
- Discovery: N repo-scouts en UN mensaje (paralelo)
- Bootstrap: N bootstrap-scouts en UN mensaje (paralelo)
- Orchestrator sabe cuándo paralelizar vs secuencializar

---

## Qué trae (core)

- **Targets dinámicos**: Sin repos hardcoded. Escala a N repos.
- **Worklog** por tarea: Snapshots, comandos corridos, resultados.
- **Gates best-effort**: lint/format/typecheck/build por repo (auto-detección).
- **No‑any scan**: Escaneo heurístico para evitar `any` en TypeScript.
- **E2E_TRACE obligatorio**: Para cambios cross‑repo.
- **Subagentes especializados**: Discovery, contracts, integration, docs.

---

## Instalación

1) Descomprime esta carpeta dentro del **workspace root** (donde están todos tus repos).
2) Ejecuta:

```bash
cd opencode-kit
./install.sh
```

3) Abre OpenCode desde el workspace root:

```bash
cd ..
opencode
```

---

## Daily Workflow (Actualizado)

### 1) Bootstrap (primera vez)
```
USER: /bootstrap
```
- Auto-detecta todos los repos del workspace
- Genera `<repo>/AGENTS.md` con stack, scripts, entrypoints
- Crea service catalog en `worklog/service-catalog.md`
- Sugiere `/supermemory-init` (opcional)

**Output**:
```
🔍 Found 5 repos: cloud_front, signage_service, ftp, etouch, cloud_tag_back
📝 Generated AGENTS.md for 5 repos
📊 Service catalog: worklog/service-catalog.md
💡 Recommended: Run /supermemory-init
```

---

### 2) Iniciar Task
```
USER: /task catalogos
```

**Orchestrator**:
1. Crea `worklog/2026-01-15_catalogos.md`
2. Crea `.opencode/targets/2026-01-15_catalogos.txt` (vacío)
3. Snapshot "before"
4. **Pregunta**: "¿Auto-detect repos o manual?"

**Opción A - Auto-detect**:
```
USER: "auto con query: catalogo"
```
- Ejecuta: `./scripts/oc-targets auto catalogos "catalogo"`
- Detecta repos con matches (ej: 3 repos)
- Lanza **3 repo-scouts EN PARALELO** (un mensaje)
- Sintetiza outputs:
  - signage_service: tabla catalogos, endpoint /catalogos
  - cloud_front: CatalogosPage consume /catalogos
  - ftp: paths para imágenes
- Crea Task Brief con discovery
- Delega a @builder

**Opción B - Manual**:
```
USER: "manual: cloud_front, signage_service, ftp"
```
- Ejecuta: `./scripts/oc-targets set catalogos cloud_front signage_service ftp`
- Lanza repo-scouts (igual que auto)

**Output**:
```
✅ Task initialized: catalogos
📁 Worklog: worklog/2026-01-15_catalogos.md
🎯 Targets: .opencode/targets/2026-01-15_catalogos.txt
🔍 Discovery (parallel)...
   - repo-scout signage_service: ✅
   - repo-scout cloud_front: ✅
   - repo-scout ftp: ✅
🧩 Repos affected: 3
📋 Dependency order: signage_service → ftp → cloud_front
👷 Delegating to @builder...
```

---

### 3) Implementación
**Builder** recibe Task Brief y:
1. Query supermemory (si disponible): "patterns for catalogos"
2. Genera E2E_TRACE **antes** de codear
3. Implementa cambios mínimos
4. Corre gates por repo: lint/format/typecheck/build
5. Escanea no-any
6. Envía GATE_REQUEST a orchestrator

**Orchestrator** delega a @contract-keeper (valida DTOs cross-repo) y @reviewer.

**Reviewer** valida:
- E2E_TRACE consistente con diff ✅
- Gates pasan ✅
- No any ✅
- Contratos OK ✅
- Decision: **PASS** o **FAIL** (con required changes)

---

### 4) Wrap Task
```
USER: /wrap catalogos
```

**Orchestrator** delega a @scribe:
1. Ejecuta `./scripts/oc-wrap catalogos` (snapshot after + commits)
2. Ejecuta `./scripts/oc-gate catalogos` (CI best-effort)
3. Ejecuta `./scripts/oc-jira-note catalogos`
4. Guarda learnings en supermemory (si disponible)
5. **Pregunta**: "¿Commit y PR?"

**Output**:
```
📸 Snapshot after: 3 repos, 23 files changed
🔬 CI best-effort: All gates passed ✅
📝 Jira note: worklog/2026-01-15_jira_catalogos.md
✨ Done!

What next?
1. Create commits (per repo)
2. Create PRs (per repo)
3. Both
4. Nothing
```

---

## Regla de oro: E2E_TRACE

Si tocas más de 1 repo, o cambias contratos (DTO/API/events/topics), **no se aprueba fase sin E2E_TRACE completo**.

---

## Comandos Disponibles

### Slash Commands (user-facing)
- `/bootstrap` - Auto-detecta repos + genera AGENTS.md
- `/task <nombre>` - Inicia task con discovery + Task Brief
- `/wrap <nombre>` - Cierra task con evidencia + commit/PR
- `/gate <nombre>` - Corre gates en repos targets (best-effort)

### Scripts Bash (uso interno)
- `./scripts/oc-targets <cmd> <task>` - Maneja targets
- `./scripts/oc-gate <task>` - Quality gates multi-repo
- `./scripts/oc-wrap <task>` - Snapshot + commits
- `./scripts/oc-e2e-trace <task>` - Plantilla E2E_TRACE
- `./scripts/oc-no-any <task>` - Escaneo de `any`
- `./scripts/oc-jira-note <task>` - Nota para Jira

---

## Estructura del Kit

```
.opencode/
├── agent/
│   ├── orchestrator.md         (router + context loading + parallel)
│   ├── builder.md              (implementador + supermemory query)
│   ├── reviewer.md             (PASS/FAIL duro)
│   ├── scribe.md               (worklog + learning)
│   ├── repo-scout.md           (discovery paralelo)
│   ├── contract-keeper.md      (validación cross-repo)
│   ├── integration-builder.md  (coordinación N repos)
│   ├── docs-specialist.md      (drift detection)
│   └── bootstrap-scout.md      (analiza repo → AGENTS.md)
├── command/
│   ├── task.md                 (iniciar task)
│   ├── bootstrap.md            (setup workspace)
│   ├── wrap.md                 (cerrar task)
│   ├── gate.md                 (targets dinámicos)
│   ├── e2e-trace.md            (plantilla)
│   ├── jira-note.md            (nota Jira)
│   └── no-any.md               (scan any)
├── templates/
│   ├── task-brief.md           (orchestrator → builder)
│   ├── phase-brief.md          (orchestrator → subagente)
│   ├── gate-request.md         (builder → reviewer)
│   └── review-decision.md      (reviewer → orchestrator)
├── skill/
│   ├── microservices/SKILL.md  (workflow base)
│   ├── ui-ux-pro-max/SKILL.md  (bridge a UI/UX skill)
│   └── prompt-generator/SKILL.md (bridge a prompt skill)
└── targets/
    └── <date>_<task>.txt       (repos en scope por task)

scripts/
├── oc-targets          (gestión de targets)
├── oc-gate             (gates dinámicos)
├── oc-wrap             (snapshot + commits)
├── oc-e2e-trace        (plantilla)
├── oc-no-any           (scan any)
├── oc-jira-note        (nota Jira)
├── oc-snapshot         (git status por repo)
└── oc-run-ci           (CI best-effort con fallback)

docs/
├── workflow.md         (targets + evidencia)
├── e2e-trace.md        (plantilla + reglas)
├── skills.md           (skills disponibles)
└── references/         (material de referencia)
```

---

## Próximos Pasos (Fase TIER 1-3)

La **Fase CORE** está completa. Próximas fases (ver `/home/bruno/.claude/plans/breezy-roaming-lemur.md`):

### 🟡 TIER 1 (Skills de Performance & UI/UX)
- react-best-practices (40+ reglas Vercel)
- web-design-guidelines (100+ reglas accesibilidad)
- ui-ux-pro-max expandido (57 styles, 95 palettes, BM25 search)
- documentation-sync, looking-up-docs

### 🟢 TIER 2 (Orchestration & Deployment)
- smart-router (config-driven workflows)
- workflow-orchestration (multi-script)
- vercel-deploy, github-actions-automation, release-notes

### 🔵 TIER 3 (Prompt Engineering & Advanced)
- intelligent-prompt-generator, prompt-analyzer
- domain-specific skills (art-master, design-master, etc.)

---

## Referencias

- Plan completo: `/home/bruno/.claude/plans/breezy-roaming-lemur.md`
- Material de referencia: `docs/references/` (25+ archivos .txt)
- Skills identificados: 25+ skills de SkillsMP y repos externos

---

**Versión**: v8 (Fase CORE completa)
**Fecha**: 2026-01-15
