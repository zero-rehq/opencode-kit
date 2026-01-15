---
name: Intelligent Prompt Generator
description: Generador inteligente de Task Briefs y Phase Briefs optimizados con semantic understanding y consistency checking.
compatibility: opencode
trigger_keywords: ["task brief", "phase brief", "optimize prompt", "improve brief"]
source: Adapted from huangserva skill-prompt-generator
---

# Intelligent Prompt Generator Skill

Generador inteligente de **Task Briefs** y **Phase Briefs** optimizados con semantic understanding, consistency checking, y context-aware generation.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Orchestrator necesita generar Task Brief para builder
- Orchestrator necesita generar Phase Brief para subagente
- User solicita: "optimize this task brief", "improve this prompt"
- Task es complejo y requiere brief detallado

## Features

✅ **3 Generation Modes**:
1. **Task Brief Mode** - Para tareas de implementación (builder)
2. **Phase Brief Mode** - Para fases de workflow (subagentes)
3. **Gate Request Mode** - Para review requests (reviewer)

✅ **Semantic Understanding**:
- Extrae intent del user request
- Identifica repos afectados automáticamente
- Detecta dependencies entre componentes
- Infiere scope boundaries

✅ **Consistency Checking**:
- Valida que scope sea consistente
- Detecta contradicciones en requirements
- Verifica que Definition of Done sea achievable
- Alerta sobre missing information

✅ **Context-Aware**:
- Lee supermemory para context loading
- Considera arquitectura existente
- Respeta patterns establecidos
- Incluye relevant constraints

---

## Mode 1: Task Brief Generation

### Input

```typescript
interface TaskBriefInput {
  userRequest: string;          // "Add catalogos feature"
  detectedRepos?: string[];     // ["signage_service", "cloud_front"]
  architecture?: string;        // From supermemory
  constraints?: string[];       // ["No refactors", "UI actual"]
}
```

### Output

```markdown
# Task Brief

## Context
<Background info from supermemory>
<Why this task is needed>
<Repos affected and their roles>

## Scope

### In Scope
- [ ] Feature X implementation in repo A
- [ ] API endpoint Y in repo B
- [ ] UI component Z in repo C

### Out of Scope
- Refactoring existing code
- Changing UI design patterns
- Performance optimizations (unless blocking)

## Definition of Done
- [ ] E2E_TRACE documented (UI → API → DB → UI)
- [ ] All affected repos compile and pass gates
- [ ] No `any` types introduced
- [ ] Contracts cross-repo validated
- [ ] Tests pass (if existing test suite)

## Constraints
- Use existing UI patterns (no new design system)
- Follow architectural conventions in docs/architecture.md
- Maintain backward compatibility

## Technical Notes
<Architecture considerations>
<Known gotchas>
<Suggested approach>
```

### Generation Rules

**Context Section**:
- Load architecture from supermemory
- Explain WHY task is needed (business context)
- List repos and their roles in E2E flow

**Scope Section**:
- Be specific about what WILL be done
- Be explicit about what WON'T be done
- Use checkboxes for trackability

**Definition of Done**:
- Include E2E_TRACE requirement
- Include quality gates (compile, tests, no-any)
- Include contract validation if multi-repo
- Be achievable (don't add impossible requirements)

**Constraints**:
- NO refactors (unless explicitly requested)
- Follow existing patterns
- Maintain backward compatibility
- Specific to project (from supermemory)

---

## Mode 2: Phase Brief Generation

### Input

```typescript
interface PhaseBriefInput {
  phaseName: string;           // "discovery" | "contracts" | "implementation"
  taskContext: string;         // Task Brief content
  repos: string[];             // Repos for this phase
  previousPhaseResults?: any;  // Results from previous phase
}
```

### Output

```markdown
# Phase Brief: Discovery

## Phase Goal
Identify all files and contracts affected by adding catalogos feature across 5 repos.

## Repos Affected
- signage_service
- cloud_tag_back
- cloud_front
- ftp_signed_proxy
- etouch

## Definition of Done
- [ ] List of relevant files per repo (top 10)
- [ ] Contracts identified (DTOs, endpoints, events)
- [ ] E2E flow parcial documented
- [ ] Dependency order determined

## Inputs
<Context loaded from supermemory>
<Previous phase results if applicable>

## Expected Outputs
- File list with roles (controller, service, DTO, UI component)
- Contract signatures (API endpoints with request/response)
- E2E flow diagram (ASCII or Mermaid)
- Implementation order recommendation

## Constraints
- READ-ONLY phase (no code changes)
- Focus on catalogos-related files only
- Ignore unrelated features
```

### Generation Rules

**Phase Goal**:
- Single sentence, specific, achievable
- Clear success criteria

**Definition of Done**:
- Specific deliverables for this phase
- Checkboxes for trackability
- No unrealistic expectations

**Inputs/Outputs**:
- Clear interface contract between phases
- Structured format (lists, signatures, diagrams)

---

## Mode 3: Gate Request Generation

### Input

```typescript
interface GateRequestInput {
  phaseSummary: string;        // What was implemented
  repos: string[];             // Repos modified
  filesChanged: string[];      // Top files changed
  e2eTrace: string;            // E2E_TRACE documented
  commandsRun: string[];       // Gates run
}
```

### Output

```markdown
# Gate Request

## PHASE_SUMMARY
- Repos afectados: signage_service, cloud_tag_back, cloud_front
- Archivos tocados (top 10):
  - signage_service/src/api/catalogos.ts (new)
  - signage_service/src/db/schema/catalogos.ts (new)
  - cloud_front/src/pages/CatalogosPage.tsx (new)
  - ...
- Qué se implementó:
  - Database table `catalogos` con migration
  - API endpoint GET /api/catalogos
  - Frontend page para listar catálogos
- Riesgos/notas:
  - New table requires DB migration
  - API endpoint is public (no auth required)

## E2E_TRACE
1. Entry: User clicks "Catálogos" in etouch menu
2. Navigation: Router navigates to /catalogos in cloud_front
3. Frontend Client: useCatalogos() hook fetches data
4. HTTP Request: GET /api/catalogos to signage_service
5. Backend Service: catalogosService.list() queries DB
6. Database: SELECT * FROM catalogos ORDER BY created_at DESC
7. Response: {id, nombre, imagen, created_at}[] as JSON
8. UI Render: CatalogosGrid displays cards with images
9. User sees: Grid of catálogos with images

## COMMANDS_RUN
```bash
# signage_service
cd signage_service
pnpm lint → ✅ passed
pnpm typecheck → ✅ passed
pnpm build → ✅ passed

# cloud_front
cd cloud_front
pnpm lint → ✅ passed
pnpm typecheck → ✅ passed
pnpm build → ✅ passed
```

## NO-ANY SCAN
```bash
oc-no-any signage_service cloud_front
→ No new 'any' types detected
```

## FILES_CHANGED
- signage_service: 8 files (5 new, 3 modified)
- cloud_tag_back: 2 files (1 new, 1 modified)
- cloud_front: 6 files (4 new, 2 modified)

Total: 16 files changed

## GATE_REQUEST
Validar:
- [ ] E2E_TRACE consistente con diff
- [ ] UI encaja con actual patterns
- [ ] Contratos cross-repo OK (CatalogoDTO coincide)
- [ ] No `any` types introducidos
- [ ] Gates pasan en todos los repos
- [ ] Migration script included for DB changes
```

### Generation Rules

**PHASE_SUMMARY**:
- Concise summary of what was done
- List repos and top files
- Mention risks/gotchas

**E2E_TRACE**:
- Step-by-step flow (numbered)
- Include entry point, all hops, and final result
- Use consistent format (from template)

**COMMANDS_RUN**:
- Show actual commands with results
- Include exit codes (✅/❌)

**GATE_REQUEST**:
- Checklist for reviewer
- Specific to this task
- Include all critical validations

---

## Semantic Understanding Features

### 1. Auto-Detect Repos Affected

```
User: "Add logout button to the app"

Semantic Analysis:
- "logout" → auth-related
- "button" → UI component
- "app" → likely frontend

Auto-detected repos:
- cloud_front (UI)
- signage_service (API for logout endpoint)

Generated Scope:
✅ Add logout button to navigation bar
✅ Call POST /api/auth/logout endpoint
✅ Clear local session storage
✅ Redirect to login page

❌ Refactor entire auth system
❌ Change login flow
```

### 2. Infer E2E Flow

```
User: "Add dashboard charts for analytics"

Semantic Analysis:
- "dashboard" → UI page
- "charts" → data visualization
- "analytics" → requires data aggregation

Inferred E2E Flow:
1. User navigates to /dashboard
2. Frontend fetches data from GET /api/analytics/summary
3. Backend aggregates from database
4. Frontend renders charts with Chart.js
5. User sees visualizations

Generated Technical Notes:
- Consider chart library: Chart.js vs Recharts
- Data aggregation may be expensive (consider caching)
- Responsive design for mobile dashboards
```

### 3. Consistency Checking

```
User input:
"Add real-time notifications without changing backend"

Consistency Check: ❌ FAILED

Issue:
Real-time notifications REQUIRE backend changes:
- WebSocket server or SSE endpoint
- Event emission system
- Notification storage

Suggested Fix:
Either:
1. Allow backend changes (WebSocket endpoint)
2. Use polling instead of real-time (no backend change needed)

Generated Warning:
⚠️ Constraint conflict detected:
   "real-time notifications" requires backend changes,
   but you specified "without changing backend"

   Please clarify approach.
```

---

## Integration con Orchestrator

### Workflow

```
USER: /task catalogos

Orchestrator:
1. Parse user request: "catalogos"
2. AUTO-TRIGGER intelligent-prompt-generator:
   - Mode: Task Brief
   - Input: "catalogos", detected repos, architecture
3. Generator produces optimized Task Brief:
   - Context loaded from supermemory
   - Scope clearly defined
   - Definition of Done with E2E_TRACE
   - Constraints from architecture docs
4. Orchestrator uses generated Task Brief to delegate to builder
```

### Example: Generated Task Brief

```markdown
# Task Brief: Catálogos Feature

## Context

Adding catálogos feature to allow users to browse product catalogs organized by category.

**Architecture** (from supermemory):
- signage_service: Backend API (Fastify + PostgreSQL)
- cloud_tag_back: Additional backend services
- cloud_front: Frontend UI (Next.js + React)
- ftp_signed_proxy: Asset proxy for images
- etouch: Entry point menu

**E2E Flow Pattern** (from docs/architecture.md):
etouch (entry) → cloud_front (UI) → signage_service (API) → DB

## Scope

### In Scope
- [ ] Database table `catalogos` with migration
- [ ] API endpoint GET /api/catalogos in signage_service
- [ ] Frontend page /catalogos in cloud_front
- [ ] FTP proxy paths for catálogo images
- [ ] Menu entry in etouch linking to /catalogos

### Out of Scope
- Catálogo editing UI (admin panel)
- Filtering/search functionality (future)
- Pagination (if catalog count < 50)

## Definition of Done
- [ ] E2E_TRACE documented (etouch → cloud_front → signage_service → DB → UI)
- [ ] Database migration runs successfully
- [ ] GET /api/catalogos returns catalogos list
- [ ] CatalogosPage renders grid with images
- [ ] All repos pass gates (lint, typecheck, build)
- [ ] No `any` types introduced
- [ ] CatalogoDTO contract matches across repos

## Constraints
- Use existing UI patterns (card grid like ProductsPage)
- Follow API conventions in signage_service/src/api/README.md
- Image URLs must use ftp_signed_proxy
- Maintain backward compatibility (no breaking changes)

## Technical Notes

**Database Schema**:
```sql
CREATE TABLE catalogos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  imagen VARCHAR(512),
  created_at TIMESTAMP DEFAULT NOW()
);
```

**API Signature**:
```typescript
GET /api/catalogos
Response: Catalogo[]

interface Catalogo {
  id: number;
  nombre: string;
  imagen: string | null;
  created_at: string;
}
```

**Frontend Component**:
- Use CatalogosGrid similar to ProductsGrid
- Images: <Image src={proxy(catalog.imagen)} />
- Empty state: "No hay catálogos disponibles"

**Known Gotchas**:
- DB migration must run before API starts
- Image URLs from DB may be absolute or relative (handle both)
- etouch menu requires rebuild after adding entry
```

---

## Best Practices

1. **Context Loading** - Always load from supermemory first
2. **Scope Clarity** - Be explicit about in/out of scope
3. **Achievable DoD** - Don't add impossible requirements
4. **Consistency** - Check for contradictions
5. **Examples** - Include code snippets when helpful
6. **Warnings** - Alert about risks and gotchas

---

## Notas

- **Supermemory required** - Generator works best with context
- **Iterative** - Generated briefs can be refined based on feedback
- **Not magic** - Requires good user input and architecture docs
- **Version control** - Save generated briefs for future reference

---

## Referencias

- **Source**: Adapted from huangserva skill-prompt-generator
- **Related**: prompt-analyzer (para mejorar briefs iterativamente)
- **Templates**: `.opencode/templates/task-brief.md`, `phase-brief.md`

---

**Version**: 1.0
**Maintainer**: OpenCode Kit
**Last Updated**: 2026-01-15
