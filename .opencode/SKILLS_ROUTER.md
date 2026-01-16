# Skills Router - Central Index

## Skills Disponibles

- **Skills Completas**: 16 (índices 0-15)
- **Skills Templates**: 2 (nextjs-ssr-optimization, api-documentation-generator)
- **Total Directorios**: 18

**Nota**: Las skills templates tienen una estructura básica pero faltan scripts y ejemplos completos. Se consideran plantillas para futura implementación.

## Skills Index por Categoría

### Orchestration & Routing
| Skill | Trigger Keywords | Priority | Router Interno |
|-------|----------------|----------|-----------------|
| **domain-classifier** | classify, what type, categorize, domain | HIGH | ✓ Sí (12 domains) |
| **intelligent-prompt-generator** | task brief, phase brief, optimize prompt | CRITICAL | ✓ Sí (3 modes) |
| **prompt-analyzer** | analyze prompt, improve brief, insights | MEDIUM | ✓ Sí (5 modes) |
| **prompt-master** | auto, smart routing, best workflow | HIGH | ✓ Sí (skills routing) |
| **smart-router** | workflow, multi-repo, orchestration | HIGH | ✓ Sí (config-driven) |
| **skills-router-agent** | routing recommendation, skills analysis | CRITICAL | ✓ Sí (gaps identification) |

### Implementation
| Skill | Trigger Keywords | Priority | Router Interno |
|-------|----------------|----------|-----------------|
| **ui-ux-pro-max** | design, UI, UX, dashboard | HIGH | ✓ Sí (8 domains) |
| **react-best-practices** | react, next.js, performance | CRITICAL | ✓ Sí (8 categories, 45 rules) |
| **github-actions-automation** | github actions, CI/CD, workflow | MEDIUM | No |
| **vercel-deploy** | deploy, Vercel, preview | MEDIUM | No |

### Review & Quality
| Skill | Trigger Keywords | Priority | Router Interno |
|-------|----------------|----------|-----------------|
| **web-design-guidelines** | review UI, accessibility, audit | CRITICAL | ✓ Sí (17 categories, 100+ rules) |
| **react-best-practices** | react, next.js, performance | HIGH | ✓ Sí (usado en review) |

### Documentation
| Skill | Trigger Keywords | Priority | Router Interno |
|-------|----------------|----------|-----------------|
| **documentation-sync** | docs, drift, sync, outdated | MEDIUM | No |
| **release-notes** | release, changelog, version | MEDIUM | No |
| **looking-up-docs** | docs, API reference, how to use | LOW | No |

### Skills Templates (Status: Pendiente de Implementación Completa)

Las siguientes skills están marcadas como "template" y necesitan implementación completa:

| Skill | Estado | Falta |
|-------|--------|-------|
| **nextjs-ssr-optimization** | Template (checklist only) | Scripts de análisis SSR, reglas específicas, workflows de migración |
| **api-documentation-generator** | Template (description only) | Scripts de análisis de código, integración con parsers, generación de clientes |

**Nota**: Estas skills fueron detectadas como gaps por el skills-router-agent y necesitan scripts/ejemplos completos para ser usables.

## Routing Rules Globales

### Auto-Trigger (OBLIGATORIO)

Estos skills **SE ACTIVAN AUTOMÁTICAMENTE** cuando cumplen triggers:

#### Para Orchestrator
1. **domain-classifier**:
   - Trigger: Cualquier request nuevo al orchestrator
   - Obligatorio: SÍ
   - Output: JSON con classification + confidence score

2. **skills-router-agent**:
   - Trigger: Cualquier task con múltiples repos
   - Obligatorio: SÍ
   - Output: SKILLS ROUTING REPORT con skills recommendation + gaps

3. **intelligent-prompt-generator**:
   - Trigger: Task/Phase brief generation
   - Obligatorio: SÍ
   - Output: Brief optimizado con contexto

4. **prompt-analyzer**:
   - Trigger: Después de generar brief
   - Obligatorio: SÍ
   - Output: Quality Score + improvements

### Decision-Based (ORCHESTRATOR DECIDE)

El orchestrator decide cuándo activar estos skills basado en el SKILLS ROUTING REPORT del skills-router-agent:

#### Skills del Orchestrator
1. **prompt-master**:
   - Trigger: Tasks complejos que requieran meta-orchestration
   - Contexto: Multi-domain, multi-phase workflows
   - Decisión: Orchestrator evalúa SKILLS ROUTING REPORT
   - Si: task complejo + domain-classifier indica múltiples dominios + confidence scores bajos

2. **smart-router**:
   - Trigger: Tasks multi-repo con dependencias
   - Contexto: 3+ repos, cross-repo integration
   - Decisión: Orchestrator evalúa SKILLS ROUTING REPORT
   - Si: multi-repo task + repo-scouts indican dependencias

#### Skills del Builder
3. **ui-ux-pro-max**:
   - Trigger: Tocar UI/components/páginas
   - Contexto: Task incluye "UI", "design", "component", "page"
   - Decisión: Builder detecta desde E2E_TRACE

4. **react-best-practices**:
   - Trigger: Tocar React/Next.js
   - Contexto: Task incluye "React", "Next.js", "performance"
   - Decisión: Builder detecta desde E2E_TRACE

5. **github-actions-automation**:
   - Trigger: Tocar CI/CD workflows
   - Contexto: Task toca workflows o CI/CD
   - Decisión: Builder detecta desde task o E2E_TRACE

6. **vercel-deploy**:
   - Trigger: Deployment de aplicación
   - Contexto: Task incluye "deploy", "production"
   - Decisión: Builder detecta desde task

#### Skills del Reviewer
7. **web-design-guidelines**:
   - Trigger: Revisar UI/components
   - Contexto: Task de review incluye archivos .tsx
   - Decisión: Reviewer detecta desde diff

8. **react-best-practices**:
   - Trigger: Revisar React/Next.js
   - Contexto: Task de review incluye archivos .tsx
   - Decisión: Reviewer detecta desde diff

#### Skills del Scribe
9. **release-notes**:
   - Trigger: Task completado (siempre)
   - Obligatorio: SÍ
   - Decisión: Siempre activo

#### Skills del Repo-Scout
10. **documentation-sync**:
    - Trigger: Detectar drift en docs
    - Contexto: Repo-scout detecta README outdated
    - Decisión: Repo-scout detecta discrepancias

#### Skills del Bootstrap-Scout
11. **prompt-generator (bridge)**:
    - Trigger: Generar AGENTS.md para nuevo repo
    - Obligatorio: SÍ
    - Decisión: Siempre activo al generar AGENTS.md

## Skills con Router Interno

| Skill | Tipo de Router | Categorías/Domains | Rules/Recursos |
|-------|----------------|---------------------|-----------------|
| domain-classifier | Domains Router | 12 domains | Keywords por dominio |
| intelligent-prompt-generator | Modes Router | 3 modes | Scripts + framework |
| prompt-analyzer | Modes Router | 5 modes | Quality metrics |
| prompt-master | Meta-Skills Router | Skills de prompt engineering | Coordination |
| smart-router | Config Router | Workflow configs | Scripts de fase |
| skills-router-agent | Skills Gaps Router | Agent's skills + recommendations | Gaps analysis |
| ui-ux-pro-max | Domains Router | 8 domains | BM25 search engine |
| react-best-practices | Rules Router | 8 categories | 45 rules |
| web-design-guidelines | Rules Router | 17 categories | 100+ rules |

## Skills Router por Agente (Default Skills)

Cada agente tiene sus **skills por defecto** definidos internamente. El skills-router-agent analiza y recomienda skills adicionales si es necesario.

### Orchestrator
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **domain-classifier** | Task Classification | HIGH | Nuevo task request | ✅ |
| **intelligent-prompt-generator** | Brief Generation | CRITICAL | Task/Phase brief | ✅ |
| **prompt-analyzer** | Brief Validation | MEDIUM | Después de generar brief | ✅ |
| **skills-router-agent** | Skills Routing + Gaps | CRITICAL | Multi-repo task | ✅ |
| **prompt-master** | Meta-Orchestration | HIGH | Task complejo | ❌ |
| **smart-router** | Workflow Routing | HIGH | Multi-repo task | ❌ |

### Builder
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **ui-ux-pro-max** | UI/UX | HIGH | Tocar UI/components | ✅ |
| **react-best-practices** | React | CRITICAL | Tocar React/Next.js | ✅ |
| **github-actions-automation** | DevOps | MEDIUM | Tocar CI/CD | ❌ |
| **vercel-deploy** | Deployment | MEDIUM | Deployment | ❌ |

### Reviewer
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **web-design-guidelines** | UI Audit | CRITICAL | Tocar UI/components | ✅ |
| **react-best-practices** | React Audit | HIGH | Tocar React/Next.js | ✅ |

### Scribe
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **release-notes** | Documentation | MEDIUM | Task completado | ✅ |

### Repo-Scout
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **documentation-sync** | Documentation | MEDIUM | Drift detectado | ✅ |
| **looking-up-docs** | Documentation | LOW | Búsqueda de docs externas | ❌ |

### Bootstrap-Scout
| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| **prompt-generator (bridge)** | Brief Generation | MEDIUM | Generar AGENTS.md | ✅ |
| **intelligent-prompt-generator** | Brief Gen | HIGH | AGENTS.md estructurado | ❌ |

## Skills Gaps Identification

El **skills-router-agent** es responsable de identificar gaps en el sistema de skills.

### Tipos de Gaps Detectados

1. **Domain Coverage Gaps**: Dominios sin skills especializados
   - Ejemplo: "Server-Side Performance" (85% confidence) pero sin skill Next.js específico
   - Ejemplo: "Documentation" (70% confidence) pero skill genérico insuficiente

2. **Pattern Gaps**: Patrones repetitivos sin automatización
   - Ejemplo: Múltiples repos tienen migraciones manuales con errores frecuentes
   - Ejemplo: APIs creadas sin documentación automatizada

3. **Workflow Gaps**: Flujos de trabajo no automatizados
   - Ejemplo: Performance audits manuales cada vez
   - Ejemplo: Contract testing manual entre repos

4. **Quality Gaps**: Validaciones de calidad no estandarizadas
   - Ejemplo: E2E traces inconsistentes
   - Ejemplo: Code reviews sin checklist estructurado

### Proceso de Gaps Identification

```
skills-router-agent:
  1. Analiza domain-classifier (dominios con confidence)
  2. Analiza repo-scout reports (patrones, riesgos, repetibilidad)
  3. Compara con SKILLS_ROUTER.md (skills existentes)
  4. Identifica gaps (domains sin skills, patrones sin automatización)
  5. Genera recomendaciones de nuevos skills
  6. Proporciona plantillas de estructura para nuevos skills
```

### Formato de Recomendación de Nuevo Skill

```markdown
## Skill Recommendation: [NOMBRE DEL SKILL]

### Por Qué Es Necesario

**Gap Detectado**:
- [Descripción del problema/no cubierto]
- [Ejemplos de tareas donde se necesita]

**Análisis de Repo**:
- [Patrones encontrados en repo-scout]
- [Problemas repetitivos detectados]
- [Riesgos que se evitarían con este skill]

**Tipo de Skill**:
- [Orchestration / Implementation / Review / Documentation / Deployment]
- [Priority: CRITICAL / HIGH / MEDIUM / LOW]

### Propuesta de Estructura

```markdown
---
name: [NOMBRE DEL SKILL]
description: [DESCRIPCIÓN CORTA]
compatibility: opencode
trigger_keywords: ["keyword1", "keyword2", "keyword3"]
source: [REPO DE REFERENCIA si aplica]
---

# [NOMBRE DEL SKILL]

[Descripción del skill y su propósito]

## Cuándo Usar

AUTO-TRIGGER cuando:
- [Trigger 1]
- [Trigger 2]
- [Trigger 3]

## Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

## Workflow

[Flujo de uso del skill]

## Scripts/Recursos (si aplica)

- [Script 1]
- [Recurso 1]
```

### Implementación Sugerida

**Opción 1: Desde Scratch**
- Crear: `.opencode/skill/[skill-name]/SKILL.md`
- Implementar scripts si aplica
- Symlinks a repos de referencia si existe

**Opción 2: Desde Subrepo**
- Buscar en `docs/references/repos/`
- Clonar/copiar estructura relevante
- Adaptar a opencode-kit

**Opción 3: Adaptar Existente**
- Basarse en skill similar existente
- Ajustar para nuevo dominio/caso de uso
```

### Ejemplos de Gaps Comunes

#### Gap 1: Next.js SSR Optimization

**Detectado en**: Domain classification + repo-scout
**Confidence**: 85% (Server-Side Performance domain)
**Patrones**:
- cloud_front usa Next.js 14 App Router
- Múltiples fetches no optimizados con `React.cache()`
- Hydration mismatches en componentes con datos dinámicos

**Recomendación**: Ver plantilla completa en `.opencode/skill/nextjs-ssr-optimization/SKILL.md`

#### Gap 2: API Documentation Generator

**Detectado en**: Domain classification + repo-scouts
**Confidence**: 70% (Documentation domain)
**Patrones**:
- signage_service, api_gateway tienen endpoints sin docs
- DTOs cambian pero documentación desactualizada
- No hay docs automatizados de OpenAPI/Swagger

**Recomendación**: Ver plantilla completa en `.opencode/skill/api-documentation-generator/SKILL.md`

#### Gap 3: Database Migration

**Detectado en**: Repo-scouts de múltiples backends
**Confidence**: 60% (Database domain)
**Patrones**:
- Múltiples backends tienen esquemas DB similares sin migración automatizada
- Scripts SQL manuales con errores frecuentes
- No hay rollback seguro

**Recomendación**: Plantilla disponible (se creará)

## Fallback Strategy

### Cuando No Hay Match de Skills

**Escenario 1: Domain confidence < 50% para todos los dominios**
```
Orchestrator decision:
  → Usar prompt-master para routing genérico
  → Delegar a builder con brief estándar
  → Skills-router-agent: Reportar "No clear domain match"
```

**Escenario 2: Skills existentes no cubren task**
```
Orchestrator decision:
  → Usar skills por defecto del agente
  → Solicitar a skills-router-agent: gaps identification
  → Si se recomienda nuevo skill: evaluar si crear ahora
```

**Escenario 3: Skills-router-agent recomienda nuevo skill**
```
Orchestrator decision:
  ✅ ACEPTAR: Usar plantilla sugerida y crear skill
  ⚠️ MODIFICAR: Ajustar propuesta antes de crear
  ❌ RECHAZAR: Usar solo skills existentes
```

## Quick Reference (Agent → Skills)

| Agente | Skills Obligatorios | Skills Opcionales |
|--------|-------------------|------------------|
| orchestrator | domain-classifier, skills-router-agent, intelligent-prompt-generator, prompt-analyzer | prompt-master, smart-router |
| builder | ui-ux-pro-max, react-best-practices | github-actions-automation, vercel-deploy |
| reviewer | web-design-guidelines, react-best-practices | (ninguno) |
| scribe | release-notes | documentation-sync |
| repo-scout | documentation-sync | looking-up-docs |
| bootstrap-scout | prompt-generator (bridge) | intelligent-prompt-generator |

## Skills con Documentación Completa

| Skill | Ubicación | Documentación |
|-------|----------|---------------|
| domain-classifier | `.opencode/skill/domain-classifier/` | 12 domains + trigger keywords |
| intelligent-prompt-generator | `.opencode/skill/intelligent-prompt-generator/` | 3 modes + scripts + framework |
| prompt-analyzer | `.opencode/skill/prompt-analyzer/` | 5 modes + quality metrics |
| ui-ux-pro-max | `.opencode/skill/ui-ux-pro-max/` | 8 domains + BM25 engine + workflow |
| react-best-practices | `.opencode/skill/react-best-practices/` | 8 categories + 45 rules |
| web-design-guidelines | `.opencode/skill/web-design-guidelines/` | 17 categories + 100+ rules |

---

**Última actualización**: 2026-01-15
