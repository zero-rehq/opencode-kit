# Guía de Creación de Skills

## Introdución

Esta guía te enseña paso a paso cómo crear nuevos skills para opencode-kit siguiendo los estándares de OpenCode y las mejores prácticas del proyecto.

## Qué es un Skill?

Un **skill** es un comportamiento reusable encapsulado en un archivo `SKILL.md` que contiene:

1. **Frontmatter** (YAML al inicio del archivo)
   - `name`: Nombre del skill (obligatorio)
   - `description`: Descripción corta (obligatorio)
   - `license`: Licencia (opcional)
   - `compatibility`: "opencode" (opcional)
   - `metadata`: Mapa string→string (opcional)
   - `source`: Repo de referencia (opcional)

2. **Contenido** (Markdown después de frontmatter)
   - Descripción del skill y su propósito
   - Cuándo usar (AUTO-TRIGGER vs MANUAL-TRIGGER)
   - Features del skill
   - Workflow paso a paso
   - Scripts/recursos si aplica
   - Ejemplos de uso

## Requisitos para Crear un Skill

### 1. Estructura de Directorio

Los skills deben vivir en:
```
.opencode/skill/<skill-name>/SKILL.md
```

O en la configuración global:
```
~/.config/opencode/skill/<skill-name>/SKILL.md
```

### 2. Convención de Nombres

El `name` en frontmatter DEBE:

- Tener 1–64 caracteres
- Ser lowercase alfanumérico con guiones simples
- NO empezar ni terminar con `-`
- NO tener `--` consecutivos
- Coincidir con el nombre del directorio que contiene `SKILL.md`

**Regex de validación**:
```
^[a-z0-9]+(-[a-z0-9]+)*$
```

**Ejemplos válidos**:
- ✅ `react-best-practices`
- ✅ `domain-classifier`
- ✅ `ui-ux-pro-max`

**Ejemplos inválidos**:
- ❌ `React-Best-Practices` (mayúsculas)
- ❌ `-react-practices` (empieza con -)
- ❌ `react--practices` (guiones consecutivos)
- ❌ `react-practices-` (termina con -)

### 3. Descripción Corta

La `description` en frontmatter DEBE:

- Tener 1-1024 caracteres
- Ser específica para que el agente pueda elegir correctamente
- Resumir en 1-2 frases

**Buenos ejemplos**:
```
description: Clasifica automáticamente tasks en dominios para routing inteligente
description: Genera changelog profesional desde commits y worklog
description: 45 reglas de performance optimizadas para React/Next.js
```

**Malos ejemplos**:
```
description: Este es un skill que hace muchas cosas importantes y es muy bueno para usar en diferentes situaciones y tiene muchas features (demasiado largo)
description: (demasiado corto)
```

## Paso a Paso: Crear un Nuevo Skill

### Paso 1: Identificar el Tipo de Skill

Primero, define qué tipo de skill necesitas:

| Tipo | Descripción | Ejemplos |
|-------|-------------|-----------|
| **Orchestration** | Coordina otros skills o agents | domain-classifier, intelligent-prompt-generator |
| **Implementation** | Ayuda a implementar código | react-best-practices, ui-ux-pro-max |
| **Review** | Valida calidad de código | web-design-guidelines |
| **Documentation** | Genera documentación | release-notes, documentation-sync |
| **Deployment** | Maneja deployment | vercel-deploy, github-actions-automation |

**Pregunta clave**: ¿Qué problema estás resolviendo que se repite frecuentemente?

**Ejemplos**:
- "Veo que los desarrolladores siempre olvidan usar `Promise.all()` cuando hacen fetches en paralelo" → Skill de reglas de React performance
- "Necesito generar changelogs consistentes cada vez que hacemos release" → Skill de release-notes
- "Los componentes UI no tienen consistencia en a11y" → Skill de web-design-guidelines

### Paso 2: Diseñar el Skill

#### Estructura Básica

Crea el directorio y archivo:
```bash
mkdir -p .opencode/skill/my-new-skill
touch .opencode/skill/my-new-skill/SKILL.md
```

#### Frontmatter (Obligatorio)

El frontmatter YAML al inicio del archivo DEBE tener al menos:
```yaml
---
name: my-new-skill
description: Descripción corta y específica del skill
---
```

**Frontmatter completo con opciones**:
```yaml
---
name: my-new-skill
description: Descripción específica del skill
license: MIT
compatibility: opencode
trigger_keywords: ["keyword1", "keyword2", "keyword3"]
source: adaptado de <repo-o-source> si aplica
metadata:
  category: implementation
  priority: HIGH
  version: "1.0.0"
  author: "Tu Nombre"
---
```

#### Contenido (Cuerpo del Skill)

El contenido markdown debe incluir:

```markdown
# My New Skill

## Descripción

[Descripción detallada de qué hace el skill y por qué es útil]

## Cuándo Usar

### AUTO-TRIGGER
El skill se activa automáticamente cuando:
- [Condición 1]
- [Condición 2]
- [Condición 3]

### MANUAL-TRIGGER
El usuario puede invocar este skill manualmente cuando:
- [Condición A]
- [Condición B]

## Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

## Workflow

1. [Paso 1 detallado]
2. [Paso 2 detallado]
3. [Paso 3 detallado]

## Ejemplos de Uso

### Ejemplo 1: [Descripción del caso]

```typescript
// Código de ejemplo
```

**Resultado esperado**:
- [Output 1]
- [Output 2]

### Ejemplo 2: [Descripción del caso]

```bash
# Comando de ejemplo
```

**Resultado esperado**:
- [Output 1]
- [Output 2]

## Scripts/Recursos

Si el skill incluye scripts ejecutables o recursos:

```
scripts/
├── analyze.js
└── validate.py
```

Describir cómo usar cada script.

## Integración con Agentes

### Qué Agentes Deben Usar Este Skill

Especificar qué agentes deberían cargar este skill:

| Agente | Cuándo usar | Priority |
|---------|-------------|----------|
| builder | Cuando implemente React | HIGH |
| reviewer | Cuando valide React | HIGH |

### Permissions Requeridas

Especificar si el skill necesita permisos especiales:

```yaml
permission:
  bash:
    "*": allow
  webfetch: allow
```

## Troubleshooting

### Problema Común 1: Skill no aparece

**Síntoma**: El skill no aparece cuando el agente llama a `skill()` tool

**Posibles causas**:
1. `SKILL.md` no está en mayúsculas
2. Frontmatter no tiene `name` o `description`
3. Directorio del skill no coincide con `name` en frontmatter
4. Permisos del agente no permiten `skill: allow`

**Soluciones**:
1. Verificar que archivo se llame exactamente `SKILL.md`
2. Verificar frontmatter tiene:
   ```yaml
   ---
   name: my-skill
   description: Mi descripción
   ---
   ```
3. Verificar directorio nombre coincide: `.opencode/skill/my-skill/`
4. Verificar permisos en `.opencode/agent/<agent>.md`:
   ```yaml
   ---
   tools:
     skill: allow
   ---
   ```

### Problema Común 2: Skill se carga pero no funciona

**Síntoma**: El skill se carga pero no produce el output esperado

**Posibles causas**:
1. Workflow no está claro
2. Features no están bien descritas
3. Ejemplos no son representativos

**Soluciones**:
1. Revisar sección "Workflow" - debe ser paso a paso claro
2. Revisar sección "Features" - lista completa de capacidades
3. Revisar sección "Ejemplos" - casos reales con outputs esperados

## Best Practices

### 1. Naming Consistente

Usa nombres descriptivos que indiquen qué hace el skill:
- ❌ `helper`
- ✅ `react-performance-helper`
- ❌ `utils`
- ✅ `api-client-helper`

### 2. Descripción Específica

La descripción debe ser lo suficientemente específica para que el agente elija correctamente:
- ❌ `description: Un skill de utilidad`
- ✅ `description: 45 reglas de performance para React/Next.js`

### 3. Auto-Trigger Claro

Define claramente cuándo debe activarse automáticamente:
- ❌ AUTO-TRIGGER: Cuando sea necesario
- ✅ AUTO-TRIGGER: Cuando el E2E_TRACE toca archivos React/Next.js

### 4. Ejemplos Reales

Usa ejemplos basados en casos reales del proyecto:
- ❌ Ejemplo genérico sin contexto
- ✅ Ejemplo con paths específicos, outputs esperados, y contexto del proyecto

### 5. Integración con Otros Skills

Si el skill depende o complementa otros skills, documentarlo:
```markdown
## Dependencies

Este skill funciona mejor cuando se usa junto con:
- react-best-practices (para validar reglas CRITICAL)
- web-design-guidelines (para validar a11y)
```

## Ejemplos Completo de Skills

### Ejemplo 1: Skill Simple sin Scripts

**Archivo**: `.opencode/skill/release-notes/SKILL.md`

```yaml
---
name: release-notes
description: Genera changelog profesional desde commits y worklog
license: MIT
compatibility: opencode
trigger_keywords: ["release", "changelog", "version"]
metadata:
  category: documentation
  priority: MEDIUM
  version: "1.0.0"
---

# Release Notes Skill

## Descripción

Genera changelogs profesionales en formato estándar desde los commits y el worklog de la tarea.

## Cuándo Usar

### AUTO-TRIGGER
Este skill se activa automáticamente cuando:
- El Orchestrator completa una tarea y delega al Scribe
- Se ejecuta `/wrap <task>`

### MANUAL-TRIGGER
El usuario puede invocar este skill manualmente cuando:
- Necesita generar un changelog específico
- Quiere documentar cambios recientes

## Features

- ✅ Genera CHANGELOG en formato estándar
- ✅ Categoriza cambios: Added, Changed, Fixed, Deprecated, Removed, Security
- ✅ Genera TECH_NOTES con detalles técnicos
- ✅ Crea JIRA_COMMENT listo para pegar
- ✅ Lee E2E_TRACE y COMMANDS_RUN del worklog

## Workflow

1. **Leer Worklog**: `worklog/<date>_<task>.md`
2. **Extraer Cambios**: De PHASE_SUMMARY y COMMANDS_RUN
3. **Categorizar**: Determinar si es Added, Changed, Fixed, etc.
4. **Generar CHANGELOG**: Bullets orientados a producto/negocio
5. **Generar TECH_NOTES**: Bullets técnicos (archivos, decisiones)
6. **Generar JIRA_COMMENT**: Formato listo para Jira
7. **Output**: Entregar los 3 outputs

## Ejemplo de Uso

**Input**: Worklog completado con implementación de catálogos

**CHANGELOG**:
```markdown
## CHANGELOG

### Added
- Catalogos listing page con búsqueda y filtros
- Catalogo detail page con información completa
- Integración con signage_service API

### Changed
- Navegación actualizada para incluir enlace a Catálogos
- Manejo de errores mejorado con toasts

### Fixed
- Bug: Imágenes de catálogos no cargaban en detail page
```

**TECH_NOTES**:
```markdown
## TECH_NOTES

Archivos clave:
- cloud_front/src/app/catalogos/page.tsx (listing)
- signage_service/src/api/catalogos.ts (API)

Decisiones:
- Usé React Query para data fetching (caching incluido)
- Zod validation para API responses

E2E trace:
Frontend: catalogos page → useCatalogos hook → API client
Backend: GET /api/catalogos → service layer → DB query
```

**JIRA_COMMENT**:
```markdown
Implemented catalogos feature con listing y detail pages.

**What was done**:
- Added catalogos listing page con búsqueda y filtros
- Added catalogo detail page
- Integrated with signage_service API

**What was tested**:
- Manual testing: listing, búsqueda, filtros, detail page
- API testing: GET /api/catalogos, GET /api/catalogos/:id
- E2E trace verificado en código (front → back → proxy → S3)

**Risks**:
- No automated tests added (NICE_TO_HAVE)
- Performance no optimized para large catalogs (future work)

**Pending**:
- Add automated E2E tests
- Implement pagination para large catalogs
```

## Integración con Agentes

**Agente Primario**: Scribe
**Priority**: MEDIUM
**Auto-Trigger**: Task completado (wrap)

---

### Ejemplo 2: Skill Complejo con Router Interno

**Archivo**: `.opencode/skill/react-best-practices/SKILL.md`

```yaml
---
name: react-best-practices
description: 45 reglas de performance optimizadas para React y Next.js
license: MIT
compatibility: opencode
trigger_keywords: ["react", "next.js", "performance", "bundle"]
source: Adaptado de Vercel Engineering
metadata:
  category: implementation
  priority: CRITICAL
  version: "1.0.0"
  router: RULES_ROUTER
  total_rules: 45
---

# React Best Practices Skill

## Descripción

Contiene 45 reglas de performance optimizadas para React y Next.js, organizadas en 8 categorías con prioridades CRITICAL, HIGH, MEDIUM, LOW. Valida código automáticamente y sugiere mejoras.

## Cuándo Usar

### AUTO-TRIGGER
Este skill se activa automáticamente cuando:
- El Builder implementa archivos React/Next.js (.tsx, .ts)
- El Reviewer valida cambios React/Next.js

### MANUAL-TRIGGER
El usuario puede invocar este skill manualmente cuando:
- Necesita validar código React existente
- Quiere optimizar performance de React
- Busca seguir best practices de Vercel

## Features

- ✅ 45 reglas de performance organizadas por categoría
- ✅ RULES_ROUTER interno para categorías relevantes
- ✅ Validación automática de código
- ✅ Sugerencias específicas con línea de código
- ✅ Priorización: CRITICAL → HIGH → MEDIUM → LOW

## RULES_ROUTER

Este skill tiene un router interno que organiza las 45 reglas en 8 categorías:

| Category | Priority | # Rules | Trigger Keywords | Files Triggered |
|----------|----------|----------|------------------|------------------|
| Eliminating Waterfalls | CRITICAL | 5 | async, await, fetch, Promise, waterfall | .tsx, .ts |
| Bundle Size Optimization | CRITICAL | 5 | bundle, import, dynamic, code splitting | .tsx, .ts |
| Server-Side Performance | HIGH | 5 | server, cache, SSR, after, serialization | .ts (server) |
| Client-Side Data Fetching | MEDIUM-HIGH | 2 | SWR, useSWR, client fetch, cache | .tsx (client) |
| Re-render Optimization | MEDIUM | 7 | render, memo, state, useEffect, useCallback | .tsx |
| Rendering Performance | MEDIUM | 7 | SVG, CSS, content-visibility, precision | .tsx, .css |
| JavaScript Performance | LOW-MEDIUM | 12 | JS, loop, Set, Map, cache | .ts, .tsx |
| Advanced Patterns | LOW | 2 | event handler, ref, useLatest | .tsx, .ts |

**Total**: 45 rules

## Workflow

### Paso 1: Categoría Detección
El RULES_ROUTER analiza el contexto y detecta qué categorías son relevantes:

**Input**: Task brief, E2E_TRACE, o código a validar

**Process**:
```python
# Pseudo-código de RULES_ROUTER
def detect_categories(context):
    categories = []
    
    # CRITICAL: Waterfalls
    if context.contains("async") and context.contains("await"):
        if not context.contains("Promise.all"):
            categories.append("Eliminating Waterfalls")
    
    # CRITICAL: Bundle Size
    if context.contains("import") and not context.contains("dynamic"):
        if context.modifies_size() > 50000:  # 50KB
            categories.append("Bundle Size Optimization")
    
    # HIGH: Server-Side
    if context.modifies_server_files() and context.contains("async"):
        categories.append("Server-Side Performance")
    
    return categories
```

**Output**: Lista de categorías relevantes con prioridad

### Paso 2: Validación de Reglas

Para cada categoría activa, valida el código contra las reglas:

```python
# Pseudo-código de validación
def validate_rules(category, code):
    violations = []
    
    for rule in category.rules:
        if rule.check(code):
            violations.append({
                "rule": rule.name,
                "priority": rule.priority,
                "location": rule.find_location(code),
                "problem": rule.description,
                "fix": rule.suggested_fix
            })
    
    return violations
```

**Output**: Lista de violations con:
- Nombre de regla
- Prioridad (CRITICAL, HIGH, MEDIUM, LOW)
- Location (file:line)
- Descripción del problema
- Sugerencia de fix

### Paso 3: Reporte

Genera reporte organizado por prioridad:

```markdown
## Validation Report

### CRITICAL Violations (MUST FIX)
[Lista de violations CRITICAL con sugerencias]

### HIGH Violations (SHOULD FIX)
[Lista de violations HIGH con sugerencias]

### MEDIUM Violations (NICE TO HAVE)
[Lista de violations MEDIUM con sugerencias]

### Summary
- Total violations: N
- CRITICAL: X (FAIL si > 0)
- HIGH: Y
- MEDIUM: Z
- LOW: W
```

## Ejemplos de Uso

### Ejemplo 1: Waterfall en Server Component

**Código a validar**:
```typescript
export default async function CatalogosPage() {
  const catalogos = await catalogosService.list();
  const filtered = catalogos.filter(c => c.activo);
  
  return <CatalogoGrid items={filtered} />;
}
```

**RULES_ROUTER Analysis**:
```
Detectando categorías...
✓ Eliminating Waterfalls (CRITICAL) detectado

Validando reglas de Eliminating Waterfalls...
❌ async-parallel: Promise.all() no usado
   → Location: catalogos/page.tsx:2
   → Problem: Sequential awaits create waterfall
   → Fix: Use Promise.all() para operaciones independientes

❌ async-defer-await: Await ejecutado inmediatamente
   → Location: catalogos/page.tsx:2
   → Problem: Await bloquea render inicial
   → Fix: Mover await a función separada y deferir
```

**Output esperado**:
```markdown
## Validation Report

### CRITICAL Violations (MUST FIX)
1. **async-parallel**
   - Location: catalogos/page.tsx:2
   - Problem: Sequential awaits create waterfall
   - Fix: 
     ```typescript
     const [catalogos, filters] = await Promise.all([
       catalogosService.list(),
       getFilterOptions()
     ]);
     ```

2. **async-defer-await**
   - Location: catalogos/page.tsx:2
   - Problem: Await bloquea render inicial
   - Fix:
     ```typescript
     async function getData() {
       const catalogos = await catalogosService.list();
       return catalogos;
     }
     
     export default async function CatalogosPage() {
       const data = getData();
       return <CatalogoGrid items={data} />;
     }
     ```

### Summary
- Total violations: 2
- CRITICAL: 2 (FAIL ❌)
```

### Ejemplo 2: Bundle Size Violation

**Código a validar**:
```typescript
import { Card } from '@/components';  // Barrel import
import { Button } from '@/lib';    // Barrel import
```

**RULES_ROUTER Analysis**:
```
Detectando categorías...
✓ Bundle Size Optimization (CRITICAL) detectado

Validando reglas de Bundle Size Optimization...
❌ bundle-barrel-imports: Barrel imports detectados
   → Location: file.ts:1, file.ts:2
   → Problem: Importa desde barrel files (@/components, @/lib)
   → Fix: Importa directamente desde ruta exacta
```

**Output esperado**:
```markdown
## Validation Report

### CRITICAL Violations (MUST FIX)
1. **bundle-barrel-imports**
   - Location: file.ts:1, file.ts:2
   - Problem: Importa desde barrel files (@/components, @/lib)
   - Fix:
     ```typescript
     import { Card } from '@/components/Card';
     import { Button } from '@/lib/Button';
     ```

### Summary
- Total violations: 1
- CRITICAL: 1 (FAIL ❌)
```

## Integración con Agentes

**Agentes Primarios**:
- Builder: Cuando implementa React/Next.js (AUTO-TRIGGER)
- Reviewer: Cuando valida React/Next.js (AUTO-TRIGGER)

**Priority**: CRITICAL

## Scripts/Recursos

Este skill no tiene scripts ejecutables. Las reglas están documentadas en `.opencode/skill/react-best-practices/RULES_ROUTER.md`.

## Troubleshooting

Ver guía completa: [Troubleshooting de Skills](skills-troubleshooting.md)

## Referencias

- Vercel Engineering: [React Best Practices](https://vercel.com/guides/react-best-practices)
- OpenCode Skills: [Guía de Uso de Skills](skills-usage.md)
