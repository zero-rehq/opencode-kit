# OpenCode Multi‑Repo Kit v8.5 (E2E Definitivo + Skills Routing)

Kit para trabajar **E2E en N repos** con OpenCode, usando **agentes + subagentes especializados**, *targets dinámicos*, trazabilidad completa (worklog), gates automáticos, **discovery paralelo**, **Skills Routing System** y foco en **E2E_TRACE**.

## Tabla de Contenidos

- [Instalación](#instalación)
- [Quick Start](#quick-start)
- [Daily Workflow](#daily-workflow)
- [Skills Routing System](#skills-routing-system)
- [Referencia de Skills](#referencia-de-skills)
- [Documentación Detallada](#documentación-detallada)
- [Troubleshooting](#troubleshooting)

## 🚀 Qué hay de nuevo (v8.5)

### ✅ Skills Routing System (NEW!)
- **skills-router-agent**: Nuevo agente especialista que analiza tasks y recomienda skills
- **Agent-level Skills Router**: Cada agente tiene skills por defecto (auto-trigger) + opcionales
- **3-Level Routing Architecture**: Central Router → Agent Router → Skill Router (Internal)
- **Skills Gaps Detection**: Identifica skills faltantes y genera plantillas
- **Prompt Engineering Skills**: domain-classifier, intelligent-prompt-generator, prompt-analyzer
- **Internal Routers**: RULES_ROUTER (react, web-design) y WORKFLOW_ROUTER (ui-ux)

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

## Quick Start

```bash
# 1) Bootstrap (primera vez)
USER: /bootstrap

# 2) Iniciar task con skills routing automático
USER: /task catalogos

# 3) Wrap task con evidencia
USER: /wrap catalogos
```

---

## Daily Workflow (Actualizado con Skills Routing)

### 1) Bootstrap (primera vez)
```
USER: /bootstrap
```

**Orchestrator** + **skills-router-agent**:
1. Auto-detecta todos los repos del workspace
2. Domain classification: "Setup/Configuration" (100% confidence)
3. Skills recommendation: prompt-generator (bridge) activado
4. Genera `<repo>/AGENTS.md` con stack, scripts, entrypoints
5. Crea service catalog en `worklog/service-catalog.md`

**Output**:
```
🔍 Found 5 repos: cloud_front, signage_service, ftp, etouch, cloud_tag_back
🎯 Domain: Configuration (100% confidence)
🤖 Skills: prompt-generator (bridge) activated
📝 Generated AGENTS.md for 5 repos
📊 Service catalog: worklog/service-catalog.md
```

---

### 2) Iniciar Task con Skills Routing
```
USER: /task catalogos
```

**Orchestrator** + **skills-router-agent**:
1. **domain-classifier**: Clasifica task
   ```
   UI/UX: 90%
   API/Backend: 85%
   Feature: 75%
   ```
2. **skills-router-agent**: Analiza y recomienda skills
   ```
   ✅ domain-classifier (ya ejecutado)
   ✅ intelligent-prompt-generator (para brief)
   ✅ prompt-analyzer (para calidad)
   ✅ ui-ux-pro-max (UI task detectado)
   ✅ react-best-practices (React/Next.js detectado)
   ```
3. Genera Task Brief optimizado
4. Lanza repo-scouts EN PARALELO (3 repo-scouts, 1 mensaje)
5. Sintetiza discovery + delega a @builder

**Builder con skills activos**:
1. Query supermemory: "patterns for catalogos"
2. Genera E2E_TRACE
3. Implementa cambios siguiendo ui-ux-pro-max + react-best-practices
4. Corre gates: lint/format/typecheck/build
5. Escanea no-any
6. Envía GATE_REQUEST

**Reviewer con skills activos**:
1. Valida E2E_TRACE vs diff
2. Valida web-design-guidelines CRITICAL
3. Valida react-best-practices CRITICAL
4. Decision: **PASS** o **FAIL**

**Output**:
```
🎯 Task initialized: catalogos
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
📁 Worklog: worklog/2026-01-15_catalogos.md
🎯 Targets: .opencode/targets/2026-01-15_catalogos.txt
🔍 Discovery (parallel)...
   - repo-scout signage_service: ✅
   - repo-scout cloud_front: ✅
   - repo-scout ftp: ✅
👷 Delegating to @builder...
```

---

### 3) Implementación
**Builder** recibe Task Brief y:
1. Query supermemory (si disponible): "patterns for catalogos"
2. Genera E2E_TRACE **antes** de codear
3. Implementa cambios mínimos
4. Corre quality gates por repo: lint/format/typecheck/build
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

## Skills Routing System

### Arquitectura de 3 Niveles

El Skills Routing System permite que opencode-kit funcione como un "empleado calificado" que automáticamente detecta qué usar y cuándo.

```
┌─────────────────────────────────────────────────────┐
│                     NIVEL 1: CENTRAL                  │
│              .opencode/SKILLS_ROUTER.md               │
│  - Índice de todos los skills                        │
│  - Reglas de routing globales                        │
│  - Fallback strategy                                   │
│  - Skills gaps detection                               │
└────────────────────────┬────────────────────────────────────┘
                     │ Domain Classification
                     ↓
┌─────────────────────────────────────────────────────┐
│                  NIVEL 2: AGENTES                    │
│      Cada agente tiene Skills Router propio                │
│  - Orchestrator: domain, prompt, routing skills      │
│  - Builder: ui-ux, react-practices                │
│  - Reviewer: web-design, react-audit                 │
│  - Scribe: release-notes                             │
└────────────────────────┬────────────────────────────────────┘
                     │ Skills Recommendation
                     ↓
┌─────────────────────────────────────────────────────┐
│                NIVEL 3: SKILL INTERNO                │
│      Routing específico dentro de cada skill               │
│  - RULES_ROUTER: Categorías de reglas             │
│  - WORKFLOW_ROUTER: Dominios de búsqueda            │
│  - DOMAINS ROUTER: Clasificación de dominios       │
│  - MODES ROUTER: Modos de generación             │
└─────────────────────────────────────────────────────┘
```

### Flujo de Routing Completo

```
Usuario Request: "Agrega página de catálogos con diseño SaaS"
         │
         ↓
┌──────────────────────────────────────┐
│     ORCHESTRATOR +              │
│     SKILLS-ROUTER-AGENT         │
└──────────────────────────────────────┘
         │
         ├─────────────────────────────┐
         │ domain-classifier        │
         ↓                         │
┌──────────────────────────┐     │
│ DOMAINS ROUTER (12)    │     │
│ - UI/UX: 95%          │     │
│ - API/Backend: 60%       │     │
│ - Feature: 75%          │     │
└──────────────────────────┘     │
         │                         │
         ├─────────────────────────────┤
         │ skills-router-agent      │
         ↓                         │
┌──────────────────────────┐     │
│ SKILLS GAPS ROUTER    │     │
│ - Analiza task           │     │
│ - Recomienda skills      │     │
│ - Detecta gaps         │     │
└──────────────────────────┘     │
         │                         │
         ├─────────────────────────────┤
         │ intelligent-prompt-gen  │
         ↓                         │
┌──────────────────────────┐     │
│ MODES ROUTER (3)      │     │
│ - Task Brief Mode       │     │
│ - Phase Brief Mode      │     │
│ - Gate Request Mode    │     │
└──────────────────────────┘     │
         │                         │
         ├─────────────────────────────┤
         │ prompt-analyzer        │
         ↓                         │
┌──────────────────────────┐     │
│ QUALITY SCORE          │     │
│ - Clarity: 85/100     │     │
│ - Completeness: 92/100  │     │
│ - Consistency: 88/100   │     │
└──────────────────────────┘     │
         │                         │
         ↓
┌──────────────────────────────────────┐
│     SKILLS ACTIVADOS:             │
│  ✅ domain-classifier            │
│  ✅ intelligent-prompt-generator  │
│  ✅ prompt-analyzer             │
│  ✅ ui-ux-pro-max             │
│  ✅ react-best-practices         │
└──────────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│          BUILDER                  │
│  Usa skills activos para         │
│  implementar con best practices   │
└──────────────────────────────────────┘
```

### Agents vs Skills vs Commands

| Concepto | Ubicación | Propósito | Ejemplo |
|-----------|-------------|-------------|----------|
| **Agent** | `.opencode/agent/<name>.md` | Asistente especializado con permisos y herramientas | `orchestrator.md` (router + gatekeeper) |
| **Skill** | `.opencode/skill/<name>/SKILL.md` | Comportamiento reusable que agentes pueden cargar | `react-best-practices` (45 reglas de performance) |
| **Command** | `.opencode/command/<name>.md` | Prompt predefinido ejecutado con `/` | `/task`, `/bootstrap`, `/wrap` |

**Relación entre ellos:**
- **Agents invocan Skills**: Los agentes usan la herramienta `skill()` para cargar SKILL.md según necesidad.
- **Commands invocan Agents**: Los comandos ejecutan prompts predefinidos, pueden especificar `agent:` en frontmatter.

---

## Referencia de Skills

### Skills por Categoría

#### Orchestration & Routing
| Skill | Descripción | Trigger | Router Interno | Priority |
|--------|-------------|----------|-----------------|----------|
| **domain-classifier** | Clasifica tasks en dominios | Task start | Domains Router (12) | HIGH |
| **intelligent-prompt-generator** | Genera briefs optimizados | Brief gen | Modes Router (3) | CRITICAL |
| **prompt-analyzer** | Valida calidad de briefs | After brief | Modes Router (5) | MEDIUM |
| **prompt-master** | Meta-orchestration de skills | Multi-domain | Meta Skills Router | HIGH |
| **smart-router** | Workflows config-driven | Multi-repo tasks | Config Router | HIGH |
| **skills-router-agent** | Analiza tasks y recomienda skills | Multi-repo | Gaps Router | CRITICAL |

#### Implementation
| Skill | Descripción | Trigger | Router Interno | Priority |
|--------|-------------|----------|-----------------|----------|
| **ui-ux-pro-max** | Diseño UI/UX | UI/components | Domains Router (8) | HIGH |
| **react-best-practices** | Reglas performance React | React/Next.js | Rules Router (8 cats, 45 rules) | CRITICAL |
| **github-actions-automation** | Workflows CI/CD | CI/CD tasks | - | MEDIUM |
| **vercel-deploy** | Deployment scripts | Deploy | - | MEDIUM |

#### Review & Quality
| Skill | Descripción | Trigger | Router Interno | Priority |
|--------|-------------|----------|-----------------|----------|
| **web-design-guidelines** | UI audit | Review UI | Rules Router (17 cats, 100+ rules) | CRITICAL |
| **react-best-practices** | Performance audit | Review React | Rules Router (8 cats, 45 rules) | HIGH |

#### Documentation
| Skill | Descripción | Trigger | Router Interno | Priority |
|--------|-------------|----------|-----------------|----------|
| **documentation-sync** | Detecta drift docs | Repo discovery | - | MEDIUM |
| **release-notes** | Genera changelog | Task wrap | - | MEDIUM |
| **looking-up-docs** | Búsqueda docs externas | Doc lookup | - | LOW |

### Agent Skills Matrix

| Agente | Skills Obligatorios (Auto-Trigger) | Skills Opcionales (Decision-Based) |
|---------|--------------------------------|----------------------------------|
| **orchestrator** | domain-classifier, intelligent-prompt-generator, prompt-analyzer, skills-router-agent | prompt-master, smart-router |
| **builder** | ui-ux-pro-max, react-best-practices | github-actions-automation, vercel-deploy |
| **reviewer** | web-design-guidelines, react-best-practices | (ninguno) |
| **scribe** | release-notes | documentation-sync |
| **repo-scout** | documentation-sync | looking-up-docs |
| **bootstrap-scout** | prompt-generator (bridge) | intelligent-prompt-generator |

### Skills con Gaps Identificados

| Skill | Status | Tipo de Gap | Template Disponible |
|--------|----------|----------------|-------------------|
| **nextjs-ssr-optimization** | 📝 Template | Performance gap (85% confidence) | ✅ `.opencode/skill/nextjs-ssr-optimization/SKILL.md` |
| **api-documentation-generator** | 📝 Template | Documentation gap (70% confidence) | ✅ `.opencode/skill/api-documentation-generator/SKILL.md` |
| **database-migration** | 🔜 Pendiente | Database gap (60% confidence) | ❌ Pendiente |

---

## Documentación Detallada

Para información detallada sobre Skills Routing System, consulta:

- 📘 [Guía de Uso de Skills](docs/skills-usage.md) - Cómo usar skills (auto, manual, routers internos)
- 🤖 [Referencia de Agentes](docs/agents.md) - Descripción detallada de cada agente
- 🛠️ [Guía de Creación de Skills](docs/skills-creation-guide.md) - Tutorial paso a paso
- 🔧 [Troubleshooting de Skills](docs/skills-troubleshooting.md) - Solución de problemas comunes
- 🧠 [Integración con Supermemory](docs/skills-supermemory-integration.md) - Aprendizaje automático

---

## Troubleshooting

Para problemas con Skills Routing System, consulta: [Troubleshooting de Skills](docs/skills-troubleshooting.md)

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
├── agent/                           # Agent definitions (markdown + frontmatter)
│   ├── orchestrator.md              # Router + gatekeeper + skills router
│   ├── builder.md                   # Implementador + skills router
│   ├── reviewer.md                  # Review + skills router
│   ├── scribe.md                    # Worklog + skills router
│   ├── repo-scout.md                # Discovery + skills router
│   ├── contract-keeper.md            # Validación cross-repo
│   ├── integration-builder.md          # Coordinación N repos
│   ├── docs-specialist.md            # Drift detection
│   ├── bootstrap-scout.md            # Analiza repo + skills router
│   └── skills-router-agent.md         # NEW: Routing specialist + gaps
├── SKILLS_ROUTER.md                 # NEW: Central routing index
├── command/                          # Custom commands (markdown + frontmatter)
│   ├── task.md                      # Iniciar task con skills routing
│   ├── bootstrap.md                 # Setup workspace
│   ├── wrap.md                      # Cerrar task con evidencia
│   └── gate.md                      # Targets dinámicos
├── skill/                            # Skills (SKILL.md + routers internos)
│   ├── domain-classifier/              # NEW: 12 domains classification
│   ├── intelligent-prompt-generator/  # NEW: Brief generation (3 modes)
│   ├── prompt-analyzer/               # NEW: Brief validation (5 modes)
│   ├── react-best-practices/
│   │   ├── SKILL.md
│   │   └── RULES_ROUTER.md         # 45 rules en 8 categorías
│   ├── web-design-guidelines/
│   │   ├── SKILL.md
│   │   └── RULES_ROUTER.md         # 100+ rules en 17 categorías
│   ├── ui-ux-pro-max/
│   │   ├── SKILL.md
│   │   └── WORKFLOW_ROUTER.md      # 8 dominios BM25 search
│   └── [other skills...]
├── templates/                        # Phase Briefs, Gate Requests, Reviews
└── targets/                          # Repos por task (dinámicos)

scripts/                            # Bash scripts para workflows
├── oc-targets                       # Gestión de targets
├── oc-gate                          # Gates dinámicos
├── oc-wrap                          # Snapshot + commits
└── [other scripts...]

docs/
├── skills-usage.md                   # NEW: Guía detallada de uso
├── agents.md                         # NEW: Referencia de agentes
├── workflow.md                       # Targets + evidencia
├── e2e-trace.md                    # Plantilla + reglas
└── references/                      # Material de referencia
    └── repos/                       # Subrepos clonados
        ├── ui-ux-pro-max-skill/       # 300+ recursos
        ├── agent-skills/                # React + web-design rules
        ├── opencode-skills-example/    # Smart router patterns
        └── skill-prompt-generator/    # Prompt engineering skills
```

---

**Versión**: v8.5 (Skills Routing System completo)
**Fecha**: 2026-01-15

**Features**:
- ✅ Targets dinámicos (v8)
- ✅ Subagentes especializados (v8)
- ✅ Comandos slash completos (v8)
- ✅ Templates profesionales (v8)
- ✅ Supermemory integration (v8)
- ✅ Paralelización real (v8)
- ✅ Skills routing system (v8.5) ← NEW
- ✅ 3-level routing architecture (v8.5) ← NEW
- ✅ Skills gaps detection (v8.5) ← NEW
- ✅ Prompt engineering skills (v8.5) ← NEW
- ✅ Internal routers (RULES, WORKFLOW, DOMAINS) (v8.5) ← NEW
- ✅ Documentación modular detallada (v8.5) ← NEW
