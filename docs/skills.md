# Skills

Este kit incluye skills integrados y bridges para skills externas.

## Estructura

Los skills se organizan en `.opencode/skill/<nombre>/`:
- `SKILL.md` - Documentación y workflow del skill
- `scripts/` - Scripts ejecutables (si aplica)
- `config/` - Configuraciones (si aplica)
- `data/` - Datos (CSVs, reglas, etc. si aplica)

## Skills TIER 2: Orchestration & Deployment

### smart-router

**Config-driven workflow routing system** (Tier 4 - Interactive)

**Ubicación**: `.opencode/skill/smart-router/`

**Propósito**: Router dinámico que lee configuración JSON y ejecuta workflows por fases.

**Triggers**:
- Workflows multi-repo complejos
- Coordinación de múltiples fases
- Routing basado en tipo de cambio (feature/bugfix/refactor)

**Componentes**:
- `router.sh` - Router principal que lee config y ejecuta fases
- `config/*.json` - Configuraciones de workflow:
  - `multi-repo-e2e.json` - Full workflow (discovery → contracts → implementation → integration)
  - `quick-fix.json` - Workflow simplificado (validate → fix → test)
  - `refactor.json` - Refactor workflow (analyze → plan → refactor → validate)
- `scripts/phase-*.sh` - Scripts de fase ejecutables

**Uso**:
```bash
.opencode/skill/smart-router/router.sh \
  .opencode/skill/smart-router/config/multi-repo-e2e.json \
  "<task>" "<repos>"
```

**Output**: Workflow completo ejecutado fase por fase con logging.

---

### workflow-orchestration

**Sequential multi-script executor** (Tier 3 - Advanced)

**Ubicación**: `.opencode/skill/workflow-orchestration/`

**Propósito**: Orquestación de múltiples scripts con control de errores, logging y rollback.

**Triggers**:
- Workflows E2E que necesitan fases secuenciales
- Tareas con múltiples pasos con dependencias
- Necesidad de logging robusto y manejo de errores

**Fases Estándar**:
1. **Initialize** (`script1-init.sh`) - Setup inicial, validación de precondiciones
2. **Validate** (`script2-validate.sh`) - Validación de targets, contracts, precondiciones
3. **Execute** (`script3-execute.sh`) - Lógica principal del workflow
4. **Finalize** (`script4-finalize.sh`) - Quality gates, evidence generation, cleanup

**Componentes**:
- `orchestrator.sh` - Ejecutor principal con logging y timeout
- `scripts/script*.sh` - Scripts de fase numerados

**Uso**:
```bash
.opencode/skill/workflow-orchestration/orchestrator.sh "<task>" "<repos>"
```

**Features**:
- Exit codes por fase (0 = success, 1+ = fail)
- Logging detallado (stdout/stderr capturado)
- Timeout por fase (600s default)
- Abort on failure (workflow se detiene si una fase falla)

---

### vercel-deploy

**Instant preview deployments** (Vercel Labs)

**Ubicación**: `.opencode/skill/vercel-deploy/`

**Propósito**: Deploy aplicaciones a Vercel directamente desde conversación. Deployments son "claimables".

**Triggers**:
- "Deploy my app"
- "Deploy this to production"
- "Create a preview deployment"
- "Deploy and give me the link"

**Features**:
- **Auto-detección de 40+ frameworks** desde `package.json`:
  - Next.js, Vite, Astro, SvelteKit, Remix, Nuxt.js, etc.
- **Deployments claimables**:
  - Preview URL (live site)
  - Claim URL (transfer ownership a tu cuenta Vercel)
- **Manejo de HTML estático**: Si no hay `package.json`, asume HTML estático
- **Exclusiones automáticas**: node_modules, .git, .next, dist, build

**Workflow**:
1. Empaquetar proyecto (tarball excluyendo archivos innecesarios)
2. Detectar framework desde package.json
3. Upload y deploy a Vercel
4. Retornar Preview URL + Claim URL

**Output**:
```
✅ Deployment successful!

📱 Preview URL: https://project-abc123.vercel.app
🔐 Claim URL:   https://vercel.com/claim-deployment?code=xyz789
```

**Casos de Uso**:
- Quick preview para validar UI
- Demo para cliente
- PR preview para code review

---

### github-actions-automation

**CI/CD workflow templates** (SkillsMP)

**Ubicación**: `.opencode/skill/github-actions-automation/`

**Propósito**: Crear y optimizar workflows de CI/CD multi-repo con GitHub Actions.

**Triggers**:
- `/bootstrap` detecta repos sin CI → sugiere setup
- Workflows existentes lentos o rotos
- Multi-repo coordination necesaria
- Best practices: security scanning, matrix builds, caching

**Features**:
- **Template workflows** para stacks comunes:
  - Node.js (npm/pnpm/yarn) con lint + typecheck + test + build
  - Rust (cargo) con check + test + clippy + build
  - Go (go test/build)
  - Python (pytest)
- **Optimizaciones incluidas**:
  - Dependency caching (npm, cargo, go mod)
  - Matrix builds (múltiples Node versions)
  - Parallel jobs (lint, test, build simultáneos)
  - Conditional workflows (skip en draft PRs)
- **Security**:
  - Dependabot integration
  - CodeQL scanning

**Workflow**:
1. Detectar stack (package.json / Cargo.toml / go.mod)
2. Generar workflow apropiado en `.github/workflows/ci.yml`
3. Incluir best practices (caching, paralelo, matrix)

**Template Ejemplo** (Node.js):
```yaml
name: CI
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
```

**Uso desde /bootstrap**:
```
/bootstrap detecta:
- 5 repos sin .github/workflows/

Orchestrator:
1. Sugiere: "Setup CI for repos without workflows?"
2. Si user acepta:
   - Lanza github-actions-automation
   - Para cada repo sin CI:
     * Detecta stack
     * Genera workflow apropiado
     * Commit workflow file
3. Output: "✅ CI setup for 5 repos"
```

---

### release-notes

**Changelog generator** (SkillsMP)

**Ubicación**: `.opencode/skill/release-notes/`

**Propósito**: Generar changelog profesional + GitHub release notes desde commits, worklog y E2E_TRACE.

**Triggers**:
- `/wrap <task> --release`
- "Generate release notes for v2.1.0"
- "Create CHANGELOG entry"

**Features**:
- **Auto-detecta changes** desde:
  - Git commits (conventionalcommits format)
  - Worklog (PHASE_SUMMARY + E2E_TRACE)
  - Git diff stats
- **Categoriza changes**:
  - Added (new features)
  - Changed (enhancements)
  - Fixed (bug fixes)
  - Deprecated (soon-to-be-removed)
  - Removed (deleted features)
  - Security (security fixes)
- **Genera múltiples formatos**:
  - CHANGELOG.md entry (Keep a Changelog format)
  - GitHub release notes (markdown)
  - Jira release summary (for ticket)

**Formato: Keep a Changelog**
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

**Workflow**:
1. Analizar commits desde último release (git log v2.0.0..HEAD)
2. Parsear conventional commits format (feat:, fix:, chore:)
3. Leer worklog para E2E_TRACE + PHASE_SUMMARY
4. Categorizar changes (Added, Changed, Fixed, etc.)
5. Generar CHANGELOG entry
6. Opcional: GitHub release (gh release create v2.1.0 --notes-file ...)

**Uso desde /wrap**:
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

**Convenciones Soportadas**:
- **Conventional Commits**: feat:, fix:, refactor:, docs:, chore:
- **Semantic Versioning**: MAJOR.MINOR.PATCH (2.1.0 → 2.2.0)
- **Breaking Changes**: Detectados por `BREAKING CHANGE:` en commit body

---

## Skills TIER 1: Performance & Best Practices

### react-best-practices

**45 reglas de performance React/Next.js** (Vercel Engineering)

**Ubicación**: `.opencode/skill/react-best-practices/`

**Propósito**: Performance optimization guidelines para React y Next.js desde Vercel Engineering.

**Triggers**:
- Escribir nuevos componentes React o páginas Next.js
- Implementar data fetching (client o server-side)
- Revisar código para performance issues
- Refactorizar código React/Next.js existente
- Optimizar bundle size o load times

**Categorías por Prioridad**:

| Priority | Category | Impact | Rules |
|----------|----------|--------|-------|
| 1 | Eliminating Waterfalls | **CRITICAL** | 5 |
| 2 | Bundle Size Optimization | **CRITICAL** | 5 |
| 3 | Server-Side Performance | **HIGH** | 5 |
| 4 | Client-Side Data Fetching | **MEDIUM-HIGH** | 2 |
| 5 | Re-render Optimization | **MEDIUM** | 7 |
| 6 | Rendering Performance | **MEDIUM** | 7 |
| 7 | JavaScript Performance | **LOW-MEDIUM** | 12 |
| 8 | Advanced Patterns | **LOW** | 2 |

**Total**: 45 reglas

**Key Rules**:
- **async-parallel**: Use Promise.all() para operaciones independientes
- **bundle-dynamic-imports**: Use next/dynamic para componentes pesados
- **server-cache-react**: Use React.cache() para deduplicación per-request
- **rerender-memo**: Extraer componentes costosos a React.memo
- **rendering-svg-precision**: Reducir precisión de coordenadas SVG

**Auto-Trigger**: Durante code writing y review phase para archivos *.tsx, *.jsx

---

### web-design-guidelines

**100+ reglas de UI audit** (Vercel Labs)

**Ubicación**: `.opencode/skill/web-design-guidelines/`

**Propósito**: Auditoría de código UI contra 100+ reglas de Web Interface Guidelines.

**Triggers**:
- "Review my UI"
- "Check accessibility"
- "Audit design"
- "Review UX"
- "Check my site against best practices"

**Categorías Cubiertas** (17 categorías):
1. **Accessibility** (10 reglas) - Icon buttons, form controls, keyboard handlers
2. **Focus States** (4 reglas) - Visible focus, focus-visible patterns
3. **Forms** (12 reglas) - Autocomplete, validation, error handling
4. **Animation** (6 reglas) - prefers-reduced-motion, compositor-friendly
5. **Typography** (6 reglas) - Curly quotes, ellipsis, tabular-nums
6. **Content Handling** (4 reglas) - Truncate, line-clamp, empty states
7. **Images** (3 reglas) - Dimensions, lazy loading, alt text
8. **Performance** (6 reglas) - Virtualization, layout thrashing, preconnect
9. **Navigation & State** (4 reglas) - URL reflects state, deep-linking
10. **Touch & Interaction** (5 reglas) - touch-action, tap-highlight
11. **Safe Areas & Layout** (3 reglas) - env(safe-area-inset-*)
12. **Dark Mode & Theming** (3 reglas) - color-scheme, theme-color meta
13. **Locale & i18n** (3 reglas) - Intl.DateTimeFormat, Intl.NumberFormat
14. **Hydration Safety** (3 reglas) - Value/onChange, suppressHydrationWarning
15. **Hover & Interactive States** (2 reglas) - Hover feedback, contrast
16. **Content & Copy** (7 reglas) - Active voice, specific labels
17. **Anti-patterns** (13 reglas) - Zoom-disabling, paste-blocking, etc.

**Guidelines Source**: https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md

**Auto-Trigger**: Durante review phase para componentes UI, forms, páginas

---

### ui-ux-pro-max

**300+ recursos de diseño curados** (NextLevelBuilder)

**Ubicación**: `.opencode/skill/ui-ux-pro-max/`

**Propósito**: Searchable database de diseño profesional con motor BM25.

**Features Principales**:
- **57 UI Styles** - Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode, etc.
- **95 Color Palettes** - Paletas específicas por industria (SaaS, E-commerce, Healthcare, Fintech, Beauty, etc.)
- **56 Font Pairings** - Combinaciones tipográficas curadas con Google Fonts imports
- **24 Chart Types** - Recomendaciones para dashboards y analytics
- **98 UX Guidelines** - Best practices, anti-patterns, accessibility
- **11 Tech Stacks** - React, Next.js, Vue, Nuxt.js, Nuxt UI, Svelte, SwiftUI, React Native, Flutter, HTML+Tailwind, shadcn/ui
- **Motor de Búsqueda BM25** - Búsqueda híbrida BM25 + regex para matches precisos

**Prerequisites**: Python 3.x requerido para motor de búsqueda

**Workflow**:
1. Analizar user requirements (product type, style, industry, stack)
2. Search relevant domains: product, style, typography, color, landing, chart, ux
3. Stack guidelines (default: html-tailwind)
4. Synthesize all search results

**Available Domains**:
- `product` - Product type recommendations (SaaS, e-commerce, portfolio, etc.)
- `style` - UI styles (glassmorphism, minimalism, dark mode, brutalism)
- `typography` - Font pairings con Google Fonts
- `color` - Color palettes by product type
- `landing` - Page structure, CTA strategies
- `chart` - Chart types, library recommendations
- `ux` - Best practices, anti-patterns
- `prompt` - AI prompts, CSS keywords

**Search Command**:
```bash
python3 .opencode/skill/ui-ux-pro-max/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
python3 .opencode/skill/ui-ux-pro-max/scripts/search.py "<keyword>" --stack html-tailwind
```

**Auto-Trigger**: Cuando task menciona "landing page", "dashboard", "design", "UI", "color palette", "typography"

**Top Resources**:
- **Styles**: Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode, Flat Design, Material Design, Skeuomorphism, Abstract Geometric, Art Deco, Cyberpunk, Memphis Design, Swiss Style, Retro/Vintage, Organic/Nature, Maximalism, Monochrome, Gradient Mesh
- **Color Palettes**: SaaS, E-commerce, Healthcare, Educational, Fintech, Gaming, Beauty/Spa, Luxury, Real Estate, Travel/Tourism, y 85 más
- **Font Pairings**: Professional (Inter), Elegant (Playfair Display + Lato), Modern Tech (Montserrat + Open Sans), Minimalist (Raleway + Nunito), Playful (Fredoka One + Poppins), Editorial (Merriweather + Roboto), y 50 más
- **Chart Types**: Line Chart, Bar Chart, Pie/Donut, Scatter Plot, Heat Map, Choropleth Map, Funnel Chart, Gauge/Bullet, Treemap, Sankey, Waterfall, Radar, Candlestick, Network Graph, Box Plot, Waffle Chart, Sunburst, y más

---

### documentation-sync

**Drift detection docs vs código** (SkillsMP)

**Ubicación**: `.opencode/skill/documentation-sync/`

**Propósito**: Detecta y corrige drift (desincronización) entre código y documentación.

**Triggers**:
- Después de implementar cambios en APIs
- Después de refactorings arquitectónicos
- En `/wrap` antes de cerrar task
- User menciona: "update docs", "sync documentation", "outdated README"

**Drift Detection en**:
- API signatures en README vs código
- Ejemplos en docs que no compilan
- Diagramas de arquitectura desactualizados
- Changelog sin entrada nueva
- Comentarios de código obsoletos
- Links rotos en documentación

**Validation Checklist**:
- [ ] API signatures coinciden (method, params, return type)
- [ ] Ejemplos en docs compilan y corren
- [ ] Diagramas de arquitectura actualizados
- [ ] Changelog con entrada para cambios
- [ ] README refleja cambios en features
- [ ] Links internos y externos funcionan

**Severity Levels**:
- **CRITICAL**: Ejemplos no compilan, endpoints incorrectos (BLOQUEA merge)
- **HIGH**: API signatures diferentes, parámetros incorrectos (review requerida)
- **MEDIUM**: Diagramas desactualizados, features no listadas (fix antes de release)
- **LOW**: Changelog vacío, typos en docs (nice-to-have)

**Integration con /wrap**:
```
@scribe en /wrap catalogos:
1. Ejecutar oc-wrap catalogos
2. AUTO-TRIGGER documentation-sync:
   - Lee README.md, docs/, CHANGELOG.md
   - Compara con git diff
   - Detecta drift
3. Si drift CRITICAL o HIGH → BLOQUEAR wrap
4. Reportar issues + suggested fixes
```

**Output**: Lista de drift issues con severity + suggested fixes

---

### looking-up-docs

**Búsqueda de docs oficiales** (SkillsMP)

**Ubicación**: `.opencode/skill/looking-up-docs/`

**Propósito**: Busca documentación oficial de APIs y libraries externas (version-specific).

**Triggers**:
- Builder duda de sintaxis de API externa
- User pregunta "how to use [library]"
- Implementando integración con library nueva
- Error sugiere revisar docs (deprecation warning, wrong signature)

**Features**:
- **Version-specific search**: Busca docs para versión exacta en package.json
- **Official sources only**: Prioriza docs oficiales sobre Stack Overflow
- **No hallucinations**: No inventa sintaxis - busca o reporta "no encontrado"
- **Multiple sources**: Docs oficiales, GitHub README, TypeScript definitions

**Supported Libraries** (50+ libraries):
- **Frontend**: React, Next.js, Vue, Svelte, Tailwind CSS, shadcn/ui
- **State**: Zustand, Jotai, Pinia, Redux Toolkit
- **Data Fetching**: React Query, SWR, tRPC
- **Forms**: React Hook Form, Zod, Yup
- **UI Components**: Radix UI, Headless UI, Chakra UI, Mantine
- **Backend**: Fastify, Express, Hono, Prisma
- **Testing**: Vitest, Jest, Playwright, Testing Library

**Workflow**:
1. Identify library and version (read package.json)
2. Search official docs (WebFetch)
3. Parse and extract (signature, params, examples, notes)
4. Return structured info

**Fallback Strategy**:
1. Official docs (library website, GitHub README)
2. TypeScript definitions (.d.ts files)
3. GitHub examples
4. Report not found

**Output Example**:
```
📚 Docs Found: React useEffect

API Signature:
  useEffect(setup, dependencies?)

Parameters:
  - setup: () => void | (() => void)
  - dependencies?: any[]

Examples:
  useEffect(() => {
    console.log('Component mounted');
  }, []);

Notes:
  - Runs AFTER paint (non-blocking)
  - Empty deps [] = runs once on mount

Source: https://react.dev/reference/react/useEffect
Version: React 18
```

**Auto-Trigger**: Cuando builder encuentra syntax error, deprecation warning, o menciona "I'm not sure about [library] syntax"

---

## Skills TIER 3: Prompt Engineering & Advanced

### intelligent-prompt-generator

**Generador inteligente de Task Briefs y Phase Briefs** (Adapted from huangserva)

**Ubicación**: `.opencode/skill/intelligent-prompt-generator/`

**Propósito**: Genera Task Briefs y Phase Briefs optimizados con semantic understanding, consistency checking, y context-aware generation.

**Triggers**:
- Orchestrator necesita generar Task Brief para builder
- Orchestrator necesita generar Phase Brief para subagente
- User solicita: "optimize this task brief", "improve this prompt"
- Task es complejo y requiere brief detallado

**Features**:
- **3 Generation Modes**:
  1. **Task Brief Mode** - Para tareas de implementación (builder)
  2. **Phase Brief Mode** - Para fases de workflow (subagentes)
  3. **Gate Request Mode** - Para review requests (reviewer)
- **Semantic Understanding**:
  - Extrae intent del user request
  - Identifica repos afectados automáticamente
  - Detecta dependencies entre componentes
  - Infiere scope boundaries
- **Consistency Checking**:
  - Valida que scope sea consistente
  - Detecta contradicciones en requirements
  - Verifica que Definition of Done sea achievable
  - Alerta sobre missing information
- **Context-Aware**:
  - Lee supermemory para context loading
  - Considera arquitectura existente
  - Respeta patterns establecidos
  - Incluye relevant constraints

**Generation Rules**:
- **Context Section**: Load architecture from supermemory, explain WHY task is needed, list repos and their roles
- **Scope Section**: Be specific about what WILL be done, be explicit about what WON'T be done, use checkboxes
- **Definition of Done**: Include E2E_TRACE requirement, quality gates, contract validation if multi-repo
- **Constraints**: NO refactors (unless requested), follow existing patterns, maintain backward compatibility

**Integration**:
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

**Output**: Task Brief / Phase Brief / Gate Request (markdown format)

---

### prompt-analyzer

**Análisis de Task Briefs con Quality Score** (Adapted from huangserva)

**Ubicación**: `.opencode/skill/prompt-analyzer/`

**Propósito**: Analiza Task Briefs y Phase Briefs para proveer insights detallados, comparaciones, recomendaciones y estadísticas.

**Triggers**:
- Orchestrator termina de generar un brief (feedback inmediato)
- User solicita: "analyze this task brief", "improve this prompt"
- Después de task completado (post-mortem analysis)
- Para comparar múltiples briefs y aprender qué funciona mejor

**Features**:
- **5 Análisis Modes**:
  1. **Detail View** - Ver estructura y elementos del brief
  2. **Quality Score** - Scoring basado en best practices (0-100)
  3. **Comparison** - Comparar dos briefs lado a lado
  4. **Recommendations** - Sugerencias de mejora específicas
  5. **Statistics** - Métricas y patrones históricos

**Quality Metrics**:
- **Clarity Score** (0-100): ¿Qué tan claro es el scope?
- **Completeness Score** (0-100): ¿Tiene todas las secciones necesarias?
- **Consistency Score** (0-100): ¿Hay contradicciones?
- **Actionability Score** (0-100): ¿Es implementable sin ambigüedades?

**Pattern Detection**:
- Detecta briefs exitosos vs problemáticos
- Identifica common issues (scope creep, missing DoD, etc.)
- Aprende qué elementos correlacionan con éxito

**Workflow Example**:
```
Task Brief generado → prompt-analyzer
1. Calculate Quality Score
2. If score < 80:
   - Muestra recomendaciones HIGH priority
   - Pregunta: "¿Aplicar mejoras sugeridas?"
3. If score >= 80:
   - Log brief como "good quality"
   - Procede con delegación
```

**Output**: Quality Score + Issues + Recommendations + Statistics

**Commands**:
- `/analyze-brief <task>` - Analiza Task Brief de una tarea específica
- `/compare-briefs <task1> <task2>` - Compara dos Task Briefs

---

### domain-classifier

**Auto-clasificación de dominios para routing inteligente** (Adapted from huangserva)

**Ubicación**: `.opencode/skill/domain-classifier/`

**Propósito**: Clasifica automáticamente tasks en dominios y categorías para routing inteligente a los skills y subagentes apropiados.

**Triggers**:
- Orchestrator recibe nuevo task request (primera línea de defensa)
- User input es ambiguo: "fix the app", "improve performance"
- Necesita decidir qué skills activar
- Múltiples skills podrían aplicar (necesita priorizar)

**Features**:
- **12 Domain Categories**:
  1. UI/UX - Interfaces, componentes, diseño
  2. API/Backend - Endpoints, servicios, lógica de negocio
  3. Database - Schemas, migrations, queries
  4. Performance - Optimización, bundle size, caching
  5. Testing - Unit tests, E2E tests, QA
  6. Documentation - README, docs, API docs
  7. DevOps/CI - Deploy, workflows, infrastructure
  8. Security - Auth, permisos, vulnerabilities
  9. Integration - Multi-repo, third-party APIs
  10. Refactor - Code quality, patterns, DRY
  11. Bugfix - Corregir errores existentes
  12. Feature - Nueva funcionalidad completa

- **Multi-Label Classification**: Un task puede tener múltiples dominios
- **Confidence Scoring**: 0-100% confidence por dominio
- **Skill Routing**: Recomienda qué skills activar automáticamente

**Domain → Skills Mapping**:
- UI/UX → ui-ux-pro-max, react-best-practices, web-design-guidelines
- API/Backend → intelligent-prompt-generator, looking-up-docs
- Performance → react-best-practices, web-design-guidelines
- Documentation → documentation-sync
- Integration → intelligent-prompt-generator, contract-keeper, repo-scout
- DevOps → github-actions-automation, vercel-deploy

**Workflow Example**:
```
USER: /task "Add dark mode toggle"

domain-classifier:
1. Parse: "dark mode toggle"
2. Keywords: "toggle" (UI), "dark mode" (theme), "add" (feature)
3. Classification:
   - Primary: UI/UX (90%)
   - Secondary: Feature (70%), API/Backend (40%)
4. Skill routing:
   - Recommended: ui-ux-pro-max, react-best-practices
5. Workflow: SIMPLE (direct execution)
```

**Ambiguity Detection**: Si confidence < 50%, pide clarification questions

**Output**: Classification (JSON/Markdown) + Skill routing + Workflow type

---

### prompt-master

**Meta-skill de orchestration** (Adapted from huangserva)

**Ubicación**: `.opencode/skill/prompt-master/`

**Propósito**: Meta-skill que orquesta todos los skills de prompt engineering y routing. Analiza task input, clasifica dominio, selecciona skills óptimos, genera briefs, valida calidad, y coordina workflow end-to-end.

**Triggers**:
- Orchestrator recibe nuevo task (entry point principal)
- Task es complejo y requiere múltiples skills
- User solicita "best workflow" o "auto-optimize"
- Necesita coordinación inteligente de skills

**Features**:
- **End-to-End Orchestration**: Clasifica → Genera Brief → Valida → Ruta a Skills → Ejecuta → Aprende
- **Skill Coordination**:
  - domain-classifier: Entiende tipo de task
  - intelligent-prompt-generator: Genera Task Brief optimizado
  - prompt-analyzer: Valida calidad del brief
  - Routing automático: Activa skills relevantes
- **Adaptive Workflow**:
  - Simple tasks: Workflow directo (classify → generate → execute)
  - Complex tasks: Workflow faseado (discovery → contracts → implementation)
  - Multi-repo: Coordina subagentes especializados
- **Learning Loop**: Guarda workflows exitosos en supermemory

**Workflow Phases**:
1. **Classification** - domain-classifier analiza task
2. **Skill Selection** - Map domains to skills, rank by relevance
3. **Brief Generation** - intelligent-prompt-generator con supermemory context
4. **Quality Validation** - prompt-analyzer, re-iterate until score >= 80
5. **Workflow Execution** - Route to subagents, activate skills during execution
6. **Post-Task Learning** - Save patterns to supermemory

**Decision Matrix**:
| Complexity | Repos | Domains | Workflow Type |
|------------|-------|---------|---------------|
| LOW | 1 | 1-2 | SIMPLE |
| MEDIUM | 1-2 | 2-3 | PHASED |
| HIGH | 3+ | 3+ | MULTI-PHASE |

**Integration**:
```
USER: /task "Add catalogos feature"

prompt-master:
1. Classify: Feature (95%), Integration (90%), UI/UX (75%), API/Backend (85%)
2. Select skills: intelligent-prompt-generator, ui-ux-pro-max, documentation-sync
3. Generate brief (quality: 82) → Fix issues → Re-validate (quality: 88)
4. Workflow: MULTI-PHASE
   - Phase A: Discovery (repo-scouts x5 EN PARALELO)
   - Phase B: Contracts (contract-keeper)
   - Phase C: Implementation (integration-builder + skills)
   - Phase D: Integration (validate E2E)
   - Phase E: Review (reviewer)
   - Phase F: Documentation (documentation-sync)
5. Learn: Save "multi-repo-feature" pattern to supermemory
```

**Output**: Workflow orchestration + Delegation plan

**Commands**:
- `/auto-workflow "<task>"` - Genera workflow completo automáticamente
- `/smart-task "<task>"` - Task con routing inteligente y feedback

---

## Skills Base (Existentes)

### microservices

**Ubicación**: `.opencode/skill/microservices/`

**Propósito**: Workflow core multi-repo: targets + evidencia + gates + wrap.

**Workflow**:
1. Define targets (repos afectados)
2. Implementa changes
3. Ejecuta quality gates por repo
4. Genera evidencia (worklog + E2E_TRACE)
5. Wrap (snapshot + CI + commits)

**Usado por**: Comandos `/task`, `/gate`, `/wrap`

---

### ui-ux-pro-max

**Ubicación**: `.opencode/skill/ui-ux-pro-max/`

**Propósito**: Design intelligence skill (expandido en TIER 1)

**Nota**: Skill completamente integrado con 300+ recursos curados. Ver sección TIER 1 arriba para documentación completa.

---

### prompt-generator-suite (bridge)

**Ubicación**: `.opencode/skill/prompt-generator-suite/`

**Propósito**: Guía para usar generadores de prompts inteligentes.

**Skills incluidos** (referencia):
- intelligent-prompt-generator (3 modos: portrait, cross-domain, design)
- prompt-analyzer (análisis e insights)
- domain-classifier (auto-clasificación)
- prompt-master (auto-selección de skill)

**Nota**: Bridge - documenta skills externos guardados en archivos .txt de referencia.

---

## Uso de Skills

### Auto-Trigger

Los skills se activan automáticamente cuando el orchestrator detecta patterns:
- "Deploy..." → vercel-deploy
- Repos sin CI en /bootstrap → github-actions-automation
- /wrap con --release → release-notes
- Workflow multi-fase → smart-router o workflow-orchestration

### Manual Invocation

Desde scripts bash:
```bash
# Smart router
.opencode/skill/smart-router/router.sh \
  .opencode/skill/smart-router/config/multi-repo-e2e.json \
  "catalogos" "signage_service,cloud_front"

# Workflow orchestration
.opencode/skill/workflow-orchestration/orchestrator.sh \
  "catalogos" "signage_service,cloud_front"
```

### Desde Agents

El orchestrator puede delegar a skills vía Task Brief:
```md
## Task Brief

...
Auto-trigger skills:
- workflow-orchestration para coordinar fases
- release-notes si es release
- github-actions si setup CI
```

---

## Roadmap: Skills Implementados

### ✅ TIER 1 (COMPLETADO - Calidad y Performance)
- ✅ **react-best-practices** (45 reglas de Vercel Engineering)
- ✅ **web-design-guidelines** (100+ reglas de UI audit de Vercel Labs)
- ✅ **ui-ux-pro-max** (expandido: 300+ recursos curados con motor BM25)
- ✅ **documentation-sync** (drift detection docs vs código de SkillsMP)
- ✅ **looking-up-docs** (búsqueda de docs oficiales de SkillsMP)

### ✅ TIER 2 (COMPLETADO - Orchestration & Deployment)
- ✅ **smart-router** (config-driven workflow routing)
- ✅ **workflow-orchestration** (sequential multi-script executor)
- ✅ **vercel-deploy** (instant preview deployments)
- ✅ **github-actions-automation** (CI/CD workflow templates)
- ✅ **release-notes** (changelog generator)

### ✅ TIER 3 (COMPLETADO - Prompt Engineering & Advanced)
- ✅ **intelligent-prompt-generator** (optimización de Task Briefs con 3 modos)
- ✅ **prompt-analyzer** (análisis e insights con Quality Score)
- ✅ **domain-classifier** (auto-clasificación de dominios + routing)
- ✅ **prompt-master** (meta-skill de orchestration)

---

**Docs**: Ver `docs/workflow.md` para workflow E2E completo.
**Agents**: Ver `docs/orchestrator-protocol.md` para routing de skills.
