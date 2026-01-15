# Guía de Uso de Skills

## Introdución

El Skills Routing System de opencode-kit permite que los agentes automaticamente detecten y usen el skill apropiado para cada tarea. Esto funciona como un "empleado calificado" que sabe qué herramienta usar y cuándo.

## Conceptos Fundamentales

### ¿Qué es un Skill?

Un **skill** es un comportamiento reusable definido en un archivo `SKILL.md` que contiene:
- Instrucciones específicas para un tipo de tarea
- Reglas y guías (ej: 45 reglas de React)
- Routers internos (RULES, WORKFLOW, DOMAINS)
- Scripts y recursos cuando aplica

Los skills viven en:
```
.opencode/skill/<skill-name>/SKILL.md
```

### ¿Cómo Funciona el Routing?

El sistema de routing tiene 3 niveles:

**Nivel 1: SKILLS_ROUTER.md (Central)**
- Índice global de skills
- Define cuándo auto-trigger vs decisión manual
- Fallback strategy cuando no hay match
- Skills gaps detection

**Nivel 2: Agent Skills Router**
Cada agente define sus skills por defecto en su archivo `.md`:

```
---description: "Router + gatekeeper"mode: primary---
## Skills Router for Orchestrator

| Skill | Categoría | Priority | Trigger | Default |
|-------|-----------|----------|---------|---------|
| domain-classifier | Classification | HIGH | Task start | ✅ |
| intelligent-prompt-generator | Brief Gen | CRITICAL | Brief gen | ✅ |
| prompt-analyzer | Brief Validation | MEDIUM | After brief | ✅ |
| skills-router-agent | Skills Routing | CRITICAL | Multi-repo | ✅ |
| prompt-master | Meta-Orchestration | HIGH | Multi-domain | ❌ |
| smart-router | Workflow Routing | HIGH | Multi-repo | ❌ |
```

**Nivel 3: Skill Internal Router**
Skills complejos tienen routing interno más avanzado:

- **RULES_ROUTER**: Categorías de reglas (react-best-practices: 45 rules en 8 categorías)
- **WORKFLOW_ROUTER**: Dominios de búsqueda (ui-ux-pro-max: 8 dominios BM25)
- **DOMAINS ROUTER**: Clasificación de dominios (domain-classifier: 12 dominios)
- **MODES ROUTER**: Modos de generación (intelligent-prompt-generator: 3 modos)

## Uso Automático (Default)

Los skills se activan automáticamente según el agente y el tipo de tarea. No necesitas invocarlos manualmente.

### Orchestrator Skills (Siempre Activos)

#### domain-classifier
**Cuándo se activa**: Cuando el orchestrator recibe cualquier request nuevo

**Qué hace**:
```
Input: "Agrega página de catálogos con diseño SaaS"

Process:
1. Analiza keywords: "catálogos", "página", "diseño", "SaaS"
2. Clasifica en dominios:
   - UI/UX: 95% confidence
   - API/Backend: 40% confidence
   - Feature: 70% confidence
3. Genera recomendación de skills:
   - ui-ux-pro-max (UI task)
   - intelligent-prompt-generator (brief gen)
   - prompt-analyzer (brief validation)

Output: JSON con classification + confidence + skills recomendados
```

**Ejemplo Real**:
```
USER: /task catalogos

ORCHESTRATOR:
[domain-classifier ejecutado]
{
  "domains": [
    {"name": "UI/UX", "confidence": 90},
    {"name": "API/Backend", "confidence": 85},
    {"name": "Feature", "confidence": 75}
  ],
  "recommendations": [
    "ui-ux-pro-max",
    "react-best-practices"
  ],
  "primary_domain": "UI/UX"
}

→ skills-router-agent recibe esta clasificación
→ Recoleta activar ui-ux-pro-max + react-best-practices
→ Orchestrator acepta recomendación
→ Skills activados en builder
```

#### intelligent-prompt-generator
**Cuándo se activa**: Cuando se genera Task Brief o Phase Brief

**Qué hace**:
```
Input: Task description + domain classification + repos afectados

Process:
1. Carga contexto desde supermemory (si disponible)
2. Identifica repos afectados automáticamente
3. Detecta dependencies entre componentes
4. Infiere scope boundaries
5. Genera Task Brief con:
   - Objetivos claros
   - Repos en scope
   - E2E_TRACE requerido
   - Definition of Done
   - Gates requeridos
   - Constraints de arquitectura

Output: Task Brief completo y optimizado
```

**Ejemplo Real**:
```
USER: /task catalogos

ORCHESTRATOR:
[intelligent-prompt-generator ejecutado]
Cargando contexto desde supermemory...
  - Architecture: cloud_front usa Next.js 14 App Router
  - Patterns: API calls via apiClient wrapper
  - Build commands: pnpm build, pnpm lint

Generando Task Brief...
  - Scope: Add catalogos listing and detail pages
  - Repos: cloud_front, signage_service, ftp_proxy
  - Dependencies: API → frontend
  - DoD: E2E_TRACE + gates pasan

Task Brief generado ✅
Quality Score (prompt-analyzer): 87/100
```

### Builder Skills (Contexto-Dependientes)

#### ui-ux-pro-max
**Cuándo se activa**: Cuando el E2E_TRACE del builder toca UI/components/páginas

**Qué hace**:
```
Input: Task description + E2E_TRACE

Process:
1. Analiza user requirements:
   - product_type: "SaaS dashboard" o "e-commerce"
   - style_keywords: "minimal", "glassmorphism"
   - industry: "healthcare", "fintech"
   - stack: "Next.js", "React", "html-tailwind"

2. WORKFLOW_ROUTER ejecuta búsqueda BM25:
   python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
     "ecommerce dashboard" \
     --domain product
   
   python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
     "minimal professional" \
     --domain style
   
   python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
     "fintech" \
     --domain color

3. Devuelve recomendaciones:
   - UI style: "Clean SaaS dashboard with card-based layout"
   - Color palette: "Navy Blue + White + Gray accents"
   - Typography: "Inter font family"
   - Components: "Data tables, search filters, pagination"

Output: Recomendaciones de diseño UI/UX específicas
```

**Ejemplo Real Completo**:
```
TASK: Agregar página de catálogos con diseño SaaS

BUILDER:
1. E2E_TRACE generado:
   - Entry UI: /catalogos page
   - Front: catalogos/page.tsx + useCatalogos hook
   - Backend: GET /api/catalogos endpoint
   - Service: catalogosService.list()
   - Integration: Signed URLs via ftp_proxy
   - Response: CatalogoDTO[]
   - UI states: loading, error, success

2. Detecta: Toca UI/components → ui-ux-pro-max activado

3. Ejecuta ui-ux-pro-max WORKFLOW_ROUTER:
   
   Search #1: "SaaS dashboard catalog" --domain product
   → Results:
     * Dashboard layout with sidebar navigation
     * Card-based grid for catalog items
     * Search bar with filters
     * Status badges (active/inactive)
     * Pagination component
   
   Search #2: "minimal professional" --domain style
   → Results:
     * Clean whitespace design
     * Subtle shadows on hover
     * Rounded corners (8px radius)
     * Consistent spacing (16px grid)
     * No gradients
   
   Search #3: "fintech" --domain color
   → Results:
     * Primary: Navy Blue (#1E3A8A)
     * Secondary: White (#FFFFFF)
     * Accent: Light Blue (#E3F2FD)
     * Text: Dark Gray (#1F2937)
     * Success: Green (#10B981)
     * Error: Red (#EF4444)

4. Implementa página siguiendo recomendaciones:
   
   catalogos/page.tsx:
   ```tsx
   export default function CatalogosPage() {
     return (
       <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
         <SearchBar placeholder="Buscar catálogos..." />
         <CatalogoCard 
           title={item.nombre}
           status={item.activo ? 'active' : 'inactive'}
           color="navy-blue"
         />
       </div>
     );
   }
   ```

5. Corre gates:
   - lint: ✅
   - typecheck: ✅
   - build: ✅

Output: Página implementada con diseño SaaS optimizado ✅
```

#### react-best-practices
**Cuándo se activa**: Cuando E2E_TRACE toca React/Next.js files

**Qué hace**:
```
Input: E2E_TRACE + código a implementar

Process:
1. RULES_ROUTER detecta categorías relevantes:
   - Eliminating Waterfalls (CRITICAL): Si hay async/await
   - Bundle Size Optimization (CRITICAL): Si hay imports
   - Server-Side Performance (HIGH): Si es server component
   - Re-render Optimization (MEDIUM): Si hay useEffect/useState

2. Valida código contra 45 reglas:
   - CRITICAL: 10 rules (waterfalls, bundle, SSR)
   - HIGH: 5 rules (server performance)
   - MEDIUM: 10 rules (re-render, rendering)
   - LOW-MEDIUM: 12 rules (JS performance)
   - LOW: 8 rules (advanced patterns)

3. Retorna violations y sugerencias

Output: Lista de violations con regla específica + línea de código
```

**Ejemplo Real Completo**:
```
BUILDER implementando catálogos:

Código original (❌ MAL):
```typescript
export default async function CatalogosPage() {
  const catalogos = await catalogosService.list();
  const filtered = catalogos.filter(c => c.activo);
  
  return <CatalogoGrid items={filtered} />;
}
```

react-best-practices RULES_ROUTER detecta:
```
┌─────────────────────────────────┐
│ Categoría: Eliminating Waterfalls  │
│ Priority: CRITICAL                 │
│ Rules activas: 5/5               │
└─────────────────────────────────────┘

Violations detectadas:
  ❌ Rule: async-parallel
     Location: catalogos/page.tsx:2
     Problem: Sequential awaits create waterfall
     Suggested fix: Use Promise.all() para operaciones independientes
     
  ❌ Rule: async-defer-await
     Location: catalogos/page.tsx:2
     Problem: Await ejecutado inmediatamente, no diferido
     Suggested fix: Mover await a función separada y deferir
```

BUILDER corrige siguiendo react-best-practices:

Código corregido (✅ BIEN):
```typescript
async function getCatalogos() {
  // Parallel fetching - no waterfall
  const [catalogos, filters] = await Promise.all([
    catalogosService.list(),
    getFilterOptions()
  ]);
  
  return { catalogos, filters };
}

export default async function CatalogosPage() {
  // Defer await - no bloqueear render
  const data = getCatalogos();
  
  return <CatalogoGrid items={data.catalogos} />;
}
```

react-best-practices validation:
```
✅ async-parallel: Promise.all() usado correctamente
✅ async-defer-await: Await diferido apropiadamente
✅ bundle-barrel-imports: No barrel imports detectados
✅ All CRITICAL rules: PASSED
```

## Uso Manual de Skills

Puedes cargar un skill directamente usando el agente con permisos de `skill: allow`:

```bash
# Usar skill desde prompt
USER: "Usa el skill react-best-practices para revisar este código"

# El agente carga el skill
skill({ name: "react-best-practices" })
# SKILL.md se carga en el contexto del agente
```

## Skills con Router Interno

Algunos skills tienen routing interno más avanzado:

### ui-ux-pro-max (WORKFLOW_ROUTER)

**Dominios Disponibles**:
- `product`: SaaS, e-commerce, portfolio, healthcare, beauty, service
- `style`: glassmorphism, minimalism, dark mode, brutalism
- `typography`: font pairings
- `color`: color palettes
- `landing`: page structure, CTAs
- `chart`: chart types
- `ux`: animation, accessibility, z-index
- `stack`: layout, responsive, a11y, performance

**Motor BM25**: Busca semántica avanzada con scoring de relevancia

**Ejemplo de uso avanzado**:
```bash
# Multi-domain search para página de catálogos
python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
  "healthcare dashboard" \
  --domain product \
  --threshold 0.7

# Resultado (BM25 scores):
# 0.92 - "SaaS dashboard for healthcare providers"
# 0.87 - "Patient catalog management system"
# 0.85 - "Medical supplies catalog"
# 0.82 - "Healthcare inventory dashboard"

# Buscar estilo complementario
python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
  "clean minimal white" \
  --domain style \
  --threshold 0.8

# Resultado:
# 0.95 - "Clean white design with blue accents"
# 0.91 - "Minimalist healthcare UI"
# 0.88 - "Whitespace-heavy dashboard"

# Buscar paleta de colores
python3 .opencode/skill/ui-ux-pro-max/scripts/search.py \
  "healthcare" \
  --domain color

# Resultado:
# Primary: Medical Blue (#0077B6)
# Secondary: Pure White (#FFFFFF)
# Accent: Light Blue (#BAE6FD)
# Text: Navy (#001A3F)
# Success: Health Green (#22C55E)
# Error: Alert Red (#DC2626)
```

### react-best-practices (RULES_ROUTER)

**Categorías de Rules**:
- **Eliminating Waterfalls** (CRITICAL, 5 rules)
  - async-parallel: Promise.all() para operaciones independientes
  - async-defer-await: Mueve await a ramas donde se usa
  - avoid-await-in-loop: No await en loops, usar Promise.all
  - parallel-server-fetches: Fetches en server en paralelo
  - client-cache-strategy: SWR o React Query para client
  
- **Bundle Size Optimization** (CRITICAL, 5 rules)
  - bundle-barrel-imports: Importa directamente, evita barrel files
  - bundle-dynamic-imports: Usa next/dynamic para >50KB
  - bundle-code-splitting: Code splitting por ruta
  - bundle-tree-shaking: Eliminar código muerto
  - bundle-externalize: Externizar librerías grandes
  
- **Server-Side Performance** (HIGH, 5 rules)
  - server-serialization: Minimizar datos serializados
  - server-parallel-fetching: Parallel fetching en server
  - server-lru-cache: LRU cache para cross-request
  - server-react-cache: React.cache() para fetches duplicados
  - server-after-promise: Mover lógica a after() promise
  
- ... [5 categorías más]

**Total**: 45 rules

## Troubleshooting

Para problemas comunes, ver: [Troubleshooting de Skills](skills-troubleshooting.md)

## Conclusión

El Skills Routing System hace que opencode-kit funcione como un "empleado calificado" que:

1. **Detecta automáticamente** qué skills necesita
2. **Recomienda inteligentemente** basado en dominios y context
3. **Activa los skills apropiados** sin intervención manual
4. **Valida calidad** con rules y guidelines
5. **Identifica gaps** y sugiere mejoras continuamente

Para aprender más:
- [Referencia de Agentes](agents.md)
- [Guía de Creación de Skills](skills-creation-guide.md)
- [Integración con Supermemory](skills-supermemory-integration.md)
