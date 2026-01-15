# Referencia de Agentes

## Visión General

Opencode-kit utiliza **agentes especializados** que trabajan juntos para lograr el objetivo E2E. Cada agente tiene permisos, herramientas y skills específicas.

## Agentes Primarios

### Orchestrator

**Archivo**: `.opencode/agent/orchestrator.md`
**Modo**: `primary`
**Descripción**: Router + gatekeeper con skills routing

**Permisos**:
```yaml
permission:
  edit: deny
  webfetch: deny
  bash:
    "*": deny
  task:
    "*": deny
    "builder": allow
    "reviewer": allow
    "scribe": allow
```

**Herramientas**: task (para invocar subagentes)

**Skills Router**:
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| domain-classifier | Task Classification | HIGH | Task start | ✅ |
| intelligent-prompt-generator | Brief Generation | CRITICAL | Task/Phase brief | ✅ |
| prompt-analyzer | Brief Validation | MEDIUM | After brief gen | ✅ |
| skills-router-agent | Skills Routing + Gaps | CRITICAL | Multi-repo task | ✅ |
| prompt-master | Meta-Orchestration | HIGH | Multi-domain | ❌ |
| smart-router | Workflow Routing | HIGH | Multi-repo task | ❌ |

**Responsabilidades**:
1. **Task Initialization**
   - Crea worklog para task
   - Crea targets file (auto-detect o manual)
   - Snapshot "before"

2. **Domain Classification**
   - Ejecuta domain-classifier
   - Obtiene dominios con confidence scores
   - Identifica dominio primario

3. **Skills Routing**
   - Ejecuta skills-router-agent
   - Recibe recomendaciones de skills
   - Decide qué skills activar

4. **Brief Generation**
   - Ejecuta intelligent-prompt-generator
   - Genera Task Brief optimizado
   - Valida con prompt-analyzer

5. **Discovery Paralelo**
   - Lanza N repo-scouts en UN mensaje (paralelo)
   - Sintetiza outputs
   - Crea dependency order

6. **Delegation**
   - Delega a @builder con Task Brief
   - Delega a @contract-keeper para cross-repo
   - Delega a @reviewer para validar

7. **Gate Management**
   - Recibe GATE_REQUEST de builder
   - Delega a @reviewer
   - Si PASS → Delega a @scribe
   - Si FAIL → Devuelve a builder con REQUIRED_CHANGES

8. **Context Loading**
   - Query supermemory antes de delegar
   - Inyecta contexto en Phase Brief
   - Carga arquitectura, patterns, build commands

9. **Parallel Delegation**
   - **REGLA DE ORO**: Subagentes independientes EN UN MENSAJE
   - Para: repo-scouts, bootstrap-scouts, reviews adversariales
   - NO paralelizar: builder → reviewer (secuencial)

**Cuándo Usar**:
- Siempre (agente primario por defecto)
- Para iniciar cualquier task multi-repo
- Para delegar a subagentes
- Para coordinar workflow completo E2E

**Limitaciones**:
- NO puede editar archivos (edit: deny)
- NO puede ejecutar bash (bash: deny)
- SOLO puede invocar subagentes (task permission restrictiva)

---

### Builder

**Archivo**: `.opencode/agent/builder.md`
**Modo**: `subagent`
**Descripción**: Implementador + ejecutor de quality gates + E2E_TRACE

**Permisos**:
```yaml
permission:
  edit: allow
  webfetch: deny
  bash:
    "*": allow
    "git push*": ask
    "rm -rf*": ask
    "sudo*": ask
```

**Herramientas**: edit, write, bash, read, grep, glob

**Skills Router**:
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| ui-ux-pro-max | UI/UX Design | HIGH | Toca UI/components/páginas | ✅ |
| react-best-practices | React Performance | CRITICAL | Toca React/Next.js | ✅ |
| github-actions-automation | CI/CD | MEDIUM | Toca workflows CI/CD | ❌ |
| vercel-deploy | Deployment | MEDIUM | Deployment task | ❌ |

**Responsabilidades**:
1. **Context Loading** (antes de explorar)
   - Query supermemory: "how to add API in <repo>"
   - Query supermemory: "patterns for <feature>"
   - Query supermemory: "build commands for <repo>"
   - Si falla: skip, continúa normal

2. **E2E_TRACE Generation** (ANTES de codear)
   - Front: componente + hook + client
   - Backend: endpoint + handler + service layer
   - Integración: proxy/storage/DB
   - Resultado esperado en UI

3. **Discovery & Plan**
   - Descubre rutas/archivos
   - Confirma repos afectados
   - Plan corto (3-6 bullets)
   - Implementa respetando patrones

4. **Implementation with Skills**
   - Usa skills activos (ui-ux-pro-max, react-best-practices)
   - Cambios mínimos y coherentes
   - NO introducir `any`
   - Sigue patrones existentes

5. **Quality Gates** (por repo)
   - lint ✅
   - format ✅
   - typecheck ✅
   - build ✅

6. **No-Any Scan** (heurístico)
   - `rg -n "(:\s*any\b|\bas any\b|<any\b)" -S .`
   - Si encuentra: fallar gate

7. **Gate Request**
   - Envía GATE_REQUEST a orchestrator
   - Incluye PHASE_SUMMARY, COMMANDS_RUN, E2E_TRACE

**Cuándo Usar**:
- Cuando Orchestrator delega implementación
- Para cambios multi-repo
- Para ejecutar quality gates
- Para generar E2E_TRACE

**Limitaciones**:
- Debe confirmar gates antes de pedir gate
- Si gate falla: arreglar antes de pedir gate

---

### Reviewer

**Archivo**: `.opencode/agent/reviewer.md`
**Modo**: `subagent`
**Descripción**: Review duro: valida E2E_TRACE, no-any, gates, coherencia y calidad

**Permisos**:
```yaml
permission:
  edit: deny
  webfetch: deny
  bash:
    "*": ask
    "git status": allow
    "git diff*": allow
    "git log*": allow
    "grep *": allow
    "pnpm *": ask
    "npm *": ask
    "yarn *": ask
```

**Herramientas**: git (allow), rg (allow), read

**Skills Router**:
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| web-design-guidelines | UI Audit | CRITICAL | Toca UI/components | ✅ |
| react-best-practices | React Audit | HIGH | Toca React/Next.js | ✅ |

**Responsabilidades**:
1. **Checklist** (si falta algo clave → FAIL)
   - No `any` (diff + rg)
   - Gates pasan (lint/format/typecheck/build)
   - Coherencia cross-repo (contratos/endpoints/payloads)
   - UI encaja con actual (patrones/estilos)
   - Seguridad/perf razonable
   - E2E_TRACE válido

2. **E2E_TRACE Validation**
   - Existe bloque E2E_TRACE
   - Trace consistente con diff
   - Si tocó backend → revisó consumidor (front)
   - Si tocó front → revisó back/proxy

3. **Skills Validation**
   - web-design-guidelines: 100+ rules CRITICAL
   - react-best-practices: 45 rules CRITICAL

4. **Review Decision** (PASS o FAIL)
   - Si FAIL: REQUIRED_CHANGES con paths exactos
   - Si PASS: NICE_TO_HAVE opcional

**Cuándo Usar**:
- Cuando Builder envía GATE_REQUEST
- Para validar quality antes de aprobar fase
- Para detectar problemas cross-repo

**Limitaciones**:
- NO puede editar archivos (edit: deny)
- Puede hacer bash commands con permiso `ask` (user confirma)

---

### Scribe

**Archivo**: `.opencode/agent/scribe.md`
**Modo**: `subagent`
**Descripción**: Trazabilidad: changelog + nota para Jira (sin tocar código)

**Permisos**:
```yaml
permission:
  edit: deny
  webfetch: deny
  bash:
    "*": deny
```

**Herramientas**: read

**Skills Router**:
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| release-notes | Documentation | MEDIUM | Task completado | ✅ |

**Responsabilidades**:
1. **Inputs esperados**
   - E2E_TRACE + PHASE_SUMMARY + COMMANDS_RUN del builder
   - REVIEW_DECISION del reviewer

2. **Output obligatorio**
   - CHANGELOG: Bullets cortos orientados a producto/negocio
   - TECH_NOTES: Bullets técnicos (archivos, decisiones, edge cases)
   - JIRA_COMMENT: Listo para Jira (qué se hizo, qué se probó, E2E verificado, riesgos, pendientes)

3. **No inventar**
   - Si falta info: NO inventar
   - Usar solo inputs recibidos

**Cuándo Usar**:
- Cuando Orchestrator delega wrap task
- Para generar changelog profesional
- Para guardar learnings en supermemory

---

### Otros Agentes

[Describir similar: repo-scout, bootstrap-scout, contract-keeper, integration-builder, docs-specialist]

Para información detallada sobre estos agentes, consulta sus archivos en `.opencode/agent/`.
