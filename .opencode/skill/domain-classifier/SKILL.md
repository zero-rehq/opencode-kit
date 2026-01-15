---
name: Domain Classifier
description: Clasifica automáticamente tasks en dominios/categorías para routing inteligente a skills y subagentes apropiados.
compatibility: opencode
trigger_keywords: ["classify", "what type", "categorize", "domain"]
source: Adapted from huangserva skill-prompt-generator
---

# Domain Classifier Skill

Clasifica automáticamente **tasks** en dominios y categorías para **routing inteligente** a los skills y subagentes apropiados. Detecta el tipo de trabajo (UI, API, performance, docs, etc.) y sugiere el mejor workflow.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Orchestrator recibe nuevo task request (primera línea de defensa)
- User input es ambiguo: "fix the app", "improve performance"
- Necesita decidir qué skills activar
- Múltiples skills podrían aplicar (necesita priorizar)

MANUAL-TRIGGER:
- `/classify "<task description>"` - Clasifica descripción de task
- `/domain "<task>"` - Muestra dominio de task existente

---

## Features

✅ **12 Domain Categories**:
1. **UI/UX** - Interfaces, componentes, diseño
2. **API/Backend** - Endpoints, servicios, lógica de negocio
3. **Database** - Schemas, migrations, queries
4. **Performance** - Optimización, bundle size, caching
5. **Testing** - Unit tests, E2E tests, QA
6. **Documentation** - README, docs, API docs
7. **DevOps/CI** - Deploy, workflows, infrastructure
8. **Security** - Auth, permisos, vulnerabilities
9. **Integration** - Multi-repo, third-party APIs
10. **Refactor** - Code quality, patterns, DRY
11. **Bugfix** - Corregir errores existentes
12. **Feature** - Nueva funcionalidad completa

✅ **Multi-Label Classification**:
- Un task puede tener múltiples dominios
- Ejemplo: "Add login page" = UI/UX (70%) + API/Backend (40%) + Security (30%)

✅ **Confidence Scoring**:
- 0-100% confidence por dominio
- Si confidence < 50%, pedir clarificación

✅ **Skill Routing**:
- Recomienda qué skills activar automáticamente
- Orden de prioridad basado en confidence

---

## Classification Workflow

### Step 1: Parse User Input

```typescript
interface TaskInput {
  description: string;        // "Add dark mode toggle to settings"
  context?: string;           // Optional: información adicional
  repos?: string[];           // Optional: repos mencionados
}
```

**Keywords extraction**:
- UI keywords: page, component, button, form, layout, design, style, theme
- API keywords: endpoint, route, service, controller, request, response
- DB keywords: table, schema, migration, query, database, SQL
- Performance keywords: optimize, slow, bundle, cache, lazy, speed
- Security keywords: auth, login, token, permission, security, vulnerability
- etc.

### Step 2: Analyze Context

```
Description: "Add dark mode toggle to settings"

Analysis:
- "toggle" → UI component
- "settings" → UI page
- "dark mode" → UI theme system

Inferred tech:
- Frontend: React/Vue (theme context, CSS-in-JS)
- Possibly backend: Save user preference API?

Repos likely affected:
- cloud_front (UI)
- signage_service? (if saving preference)
```

### Step 3: Classify Domains

```typescript
interface ClassificationResult {
  primary: string;              // "UI/UX"
  confidence: number;           // 85
  secondary: string[];          // ["API/Backend", "Feature"]
  secondaryConfidence: number[]; // [40, 30]
  reasoning: string;            // "Keywords: toggle, settings, dark mode"
}
```

### Step 4: Route to Skills

```typescript
interface SkillRouting {
  recommended: string[];       // ["ui-ux-pro-max", "react-best-practices"]
  optional: string[];          // ["documentation-sync"]
  confidence: number;          // 85
}
```

---

## Domain Classification Examples

### Example 1: UI Task

**Input**: "Add dashboard charts for analytics"

**Classification**:
```json
{
  "primary": {
    "domain": "UI/UX",
    "confidence": 90,
    "keywords": ["dashboard", "charts", "analytics"],
    "reasoning": "Dashboard is UI component, charts are data visualization"
  },
  "secondary": [
    {
      "domain": "API/Backend",
      "confidence": 60,
      "reasoning": "Analytics data requires API endpoint"
    },
    {
      "domain": "Performance",
      "confidence": 40,
      "reasoning": "Charts can be heavy, consider optimization"
    },
    {
      "domain": "Feature",
      "confidence": 70,
      "reasoning": "New functionality being added"
    }
  ],
  "skillRouting": {
    "recommended": [
      "ui-ux-pro-max (dashboard design patterns, chart types)",
      "react-best-practices (rendering performance for charts)",
      "intelligent-prompt-generator (generate Task Brief)"
    ],
    "optional": [
      "documentation-sync (update README with new feature)"
    ]
  },
  "subagentRouting": {
    "primary": "builder (implementation)",
    "secondary": [
      "docs-specialist (update docs after implementation)"
    ]
  },
  "complexity": "MEDIUM",
  "estimatedRepos": 2,
  "warningFlags": [
    "Consider chart library selection (Chart.js vs Recharts)",
    "Data aggregation may be expensive (backend optimization needed)"
  ]
}
```

---

### Example 2: Performance Task

**Input**: "App is slow, fix performance issues"

**Classification**:
```json
{
  "primary": {
    "domain": "Performance",
    "confidence": 95,
    "keywords": ["slow", "performance", "fix"],
    "reasoning": "Explicit mention of performance problem"
  },
  "secondary": [
    {
      "domain": "Bugfix",
      "confidence": 60,
      "reasoning": "Fixing existing issue"
    },
    {
      "domain": "Refactor",
      "confidence": 50,
      "reasoning": "May require code restructuring"
    }
  ],
  "skillRouting": {
    "recommended": [
      "react-best-practices (40+ performance rules)",
      "web-design-guidelines (performance audit)"
    ],
    "optional": []
  },
  "subagentRouting": {
    "primary": "repo-scout (identify bottlenecks first)",
    "secondary": [
      "builder (implement fixes)",
      "reviewer (validate improvements)"
    ]
  },
  "complexity": "HIGH",
  "estimatedRepos": "UNKNOWN (needs discovery phase)",
  "warningFlags": [
    "⚠️ AMBIGUOUS: 'App is slow' is vague",
    "⚠️ CLARIFICATION NEEDED: Which part is slow? (page load, interaction, API?)",
    "⚠️ MEASUREMENT: Define success criteria (target load time?)"
  ],
  "recommendedApproach": "DISCOVERY FIRST",
  "clarifyingQuestions": [
    "Which specific pages or features are slow?",
    "Is it page load time, interaction lag, or API response?",
    "Do you have performance metrics? (Lighthouse score, Core Web Vitals)"
  ]
}
```

---

### Example 3: Multi-Domain Task

**Input**: "Add catalogos feature"

**Classification**:
```json
{
  "primary": {
    "domain": "Feature",
    "confidence": 95,
    "keywords": ["add", "feature"],
    "reasoning": "New feature implementation"
  },
  "secondary": [
    {
      "domain": "Database",
      "confidence": 80,
      "reasoning": "New table 'catalogos' likely needed"
    },
    {
      "domain": "API/Backend",
      "confidence": 85,
      "reasoning": "API endpoint for catalogos CRUD"
    },
    {
      "domain": "UI/UX",
      "confidence": 75,
      "reasoning": "UI to display and manage catalogos"
    },
    {
      "domain": "Integration",
      "confidence": 90,
      "reasoning": "Multi-repo coordination (front + back + DB)"
    }
  ],
  "skillRouting": {
    "recommended": [
      "intelligent-prompt-generator (complex Task Brief)",
      "ui-ux-pro-max (catalogos UI design)",
      "documentation-sync (update docs after)"
    ],
    "optional": [
      "looking-up-docs (if using new library for catalogos)"
    ]
  },
  "subagentRouting": {
    "primary": "repo-scout (discovery across repos)",
    "secondary": [
      "integration-builder (coordinate multi-repo changes)",
      "contract-keeper (validate DTOs cross-repo)",
      "builder (implementation)",
      "reviewer (validation)",
      "docs-specialist (documentation)"
    ]
  },
  "complexity": "HIGH",
  "estimatedRepos": "3-5 (signage_service, cloud_front, ftp?, etouch?)",
  "warningFlags": [
    "⚠️ MULTI-REPO: Requires coordination",
    "⚠️ E2E_TRACE: Mandatory for multi-repo feature",
    "⚠️ CONTRACTS: Validate CatalogoDTO across repos"
  ],
  "recommendedWorkflow": "PHASED (discovery → contracts → implementation → integration → review)",
  "estimatedEffort": "HIGH (2-3 days)"
}
```

---

### Example 4: Documentation Task

**Input**: "Update README with new API endpoints"

**Classification**:
```json
{
  "primary": {
    "domain": "Documentation",
    "confidence": 100,
    "keywords": ["update", "README", "API endpoints"],
    "reasoning": "Explicit documentation task"
  },
  "secondary": [
    {
      "domain": "API/Backend",
      "confidence": 30,
      "reasoning": "Related to APIs but not implementing them"
    }
  ],
  "skillRouting": {
    "recommended": [
      "documentation-sync (detect drift, sync docs with code)"
    ],
    "optional": []
  },
  "subagentRouting": {
    "primary": "docs-specialist (update documentation)",
    "secondary": []
  },
  "complexity": "LOW",
  "estimatedRepos": 1,
  "warningFlags": [],
  "recommendedWorkflow": "DIRECT (no discovery needed)",
  "estimatedEffort": "LOW (< 1 hour)"
}
```

---

### Example 5: Security Task

**Input**: "Fix XSS vulnerability in product search"

**Classification**:
```json
{
  "primary": {
    "domain": "Security",
    "confidence": 100,
    "keywords": ["XSS", "vulnerability", "fix"],
    "reasoning": "Explicit security vulnerability"
  },
  "secondary": [
    {
      "domain": "Bugfix",
      "confidence": 90,
      "reasoning": "Fixing critical security bug"
    },
    {
      "domain": "API/Backend",
      "confidence": 70,
      "reasoning": "XSS prevention requires backend sanitization"
    },
    {
      "domain": "UI/UX",
      "confidence": 50,
      "reasoning": "Frontend must escape user input"
    }
  ],
  "skillRouting": {
    "recommended": [
      "web-design-guidelines (security audit rules)"
    ],
    "optional": []
  },
  "subagentRouting": {
    "primary": "builder (fix vulnerability)",
    "secondary": [
      "reviewer (security validation)"
    ]
  },
  "complexity": "MEDIUM",
  "estimatedRepos": "1-2 (front + back)",
  "warningFlags": [
    "🔴 CRITICAL: Security vulnerability, prioritize",
    "🔴 TEST: Validate fix with XSS payload tests",
    "🔴 REVIEW: Security-focused review mandatory"
  ],
  "recommendedWorkflow": "URGENT (expedited review)",
  "estimatedEffort": "MEDIUM (< 1 day)",
  "securityNotes": "Use DOMPurify or similar library for sanitization"
}
```

---

## Domain Decision Matrix

| Domain | Keywords | Typical Repos | Typical Skills | Typical Subagents |
|--------|----------|---------------|----------------|-------------------|
| **UI/UX** | page, component, button, form, layout, design, style, theme, dashboard, menu | cloud_front, etouch | ui-ux-pro-max, react-best-practices, web-design-guidelines | builder, docs-specialist |
| **API/Backend** | endpoint, route, service, controller, API, request, response, server | signage_service, cloud_tag_back | looking-up-docs (Fastify, Express) | builder, contract-keeper |
| **Database** | table, schema, migration, query, database, SQL, index, relation | signage_service (DB layer) | - | builder |
| **Performance** | optimize, slow, bundle, cache, lazy, speed, memory, CPU | cloud_front, signage_service | react-best-practices, web-design-guidelines | repo-scout, builder |
| **Testing** | test, QA, spec, unit, e2e, integration, coverage | All repos | - | builder, reviewer |
| **Documentation** | README, docs, API docs, changelog, guide, tutorial | All repos | documentation-sync, looking-up-docs | docs-specialist |
| **DevOps/CI** | deploy, CI, CD, workflow, docker, kubernetes, pipeline | Root, .github/ | github-actions-automation, vercel-deploy | - |
| **Security** | auth, login, token, permission, vulnerability, XSS, SQL injection | signage_service, cloud_front | web-design-guidelines (security rules) | builder, reviewer |
| **Integration** | multi-repo, third-party, API integration, webhook, event | Multiple repos | intelligent-prompt-generator (complex briefs) | repo-scout, integration-builder, contract-keeper |
| **Refactor** | refactor, clean, DRY, patterns, architecture, restructure | Any repo | - | builder |
| **Bugfix** | fix, bug, error, issue, broken, crash | Any repo | - | builder, reviewer |
| **Feature** | add, create, implement, new, feature | Multiple repos | intelligent-prompt-generator, ui-ux-pro-max | repo-scout, integration-builder, builder |

---

## Ambiguity Detection

### Low Confidence Triggers

Si confidence < 50% en primary domain:
```
⚠️ AMBIGUOUS TASK

Input: "Fix the app"

Issues detected:
- "Fix" could be bugfix, performance, or refactor
- "The app" is vague (which part? all of it?)

Recommended action: ASK CLARIFYING QUESTIONS

Questions to ask:
1. What specifically is broken or needs fixing?
2. Is it a bug, performance issue, or design problem?
3. Which feature or page is affected?
```

### Conflicting Domains

Si múltiples dominios con confidence > 70%:
```
⚠️ MULTI-DOMAIN TASK

Input: "Add user authentication"

Domains detected:
- Security: 95% (auth is security-critical)
- API/Backend: 90% (login endpoint, JWT generation)
- UI/UX: 85% (login form, session UI)
- Database: 80% (users table, password hashing)
- Integration: 75% (multi-repo coordination)

Recommended action: PHASED WORKFLOW

Phases:
1. Discovery (repo-scout)
2. Contracts (contract-keeper)
3. Implementation (integration-builder)
4. Review (reviewer with security focus)
```

---

## Integration con Orchestrator

### Workflow: Task Entry Point

```
USER: /task "Add dark mode toggle"

ORCHESTRATOR:
1. AUTO-TRIGGER domain-classifier:
   - Parse: "Add dark mode toggle"
   - Classify: UI/UX (90%), Feature (80%)
   - Route to skills: ui-ux-pro-max, react-best-practices

2. Load skill recommendations:
   - ui-ux-pro-max: Suggest dark mode color palettes
   - react-best-practices: Theme context optimization

3. Generate Task Brief (intelligent-prompt-generator):
   - Include domain-specific context
   - Add relevant constraints (theme switching performance)

4. Delegate to builder with skill context
```

### Workflow: Ambiguous Input

```
USER: "Make the app better"

ORCHESTRATOR:
1. AUTO-TRIGGER domain-classifier:
   - Confidence: LOW (25%)
   - Primary: UNKNOWN
   - Warning: "Ambiguous input"

2. ASK CLARIFYING QUESTIONS:
   - "What aspect needs improvement? (UI, performance, features, bugs)"
   - "Which part of the app?"
   - "What is the current issue or goal?"

USER: "The dashboard loads slowly"

ORCHESTRATOR:
3. RE-CLASSIFY:
   - Primary: Performance (95%)
   - Secondary: UI/UX (dashboard), Bugfix
   - Route to: react-best-practices, web-design-guidelines

4. Proceed with discovery phase
```

---

## Output Formats

### JSON (for programmatic routing)

```json
{
  "taskId": "2026-01-15_dashboard-charts",
  "input": "Add dashboard charts for analytics",
  "classification": {
    "primary": {
      "domain": "UI/UX",
      "confidence": 90
    },
    "secondary": [
      {"domain": "API/Backend", "confidence": 60},
      {"domain": "Performance", "confidence": 40},
      {"domain": "Feature", "confidence": 70}
    ]
  },
  "routing": {
    "skills": ["ui-ux-pro-max", "react-best-practices", "intelligent-prompt-generator"],
    "subagents": ["builder", "docs-specialist"]
  },
  "metadata": {
    "complexity": "MEDIUM",
    "estimatedRepos": 2,
    "estimatedEffort": "MEDIUM (1-2 days)",
    "warnings": ["Consider chart library selection"],
    "workflow": "PHASED"
  }
}
```

### Markdown (for human reading)

```markdown
# Classification: Add Dashboard Charts

## Primary Domain: UI/UX (90% confidence)

**Keywords**: dashboard, charts, analytics
**Reasoning**: Dashboard is UI component, charts are data visualization

## Secondary Domains

- **API/Backend** (60%): Analytics data requires API endpoint
- **Performance** (40%): Charts can be heavy, consider optimization
- **Feature** (70%): New functionality being added

## Recommended Skills

✅ **ui-ux-pro-max**: Dashboard design patterns, chart types
✅ **react-best-practices**: Rendering performance for charts
✅ **intelligent-prompt-generator**: Generate Task Brief

## Recommended Subagents

- **builder**: Implementation
- **docs-specialist**: Update docs after implementation

## Metadata

- **Complexity**: MEDIUM
- **Estimated Repos**: 2 (cloud_front + signage_service)
- **Estimated Effort**: 1-2 days
- **Workflow**: PHASED (discovery → implementation → review)

## Warnings

⚠️ Consider chart library selection (Chart.js vs Recharts)
⚠️ Data aggregation may be expensive (backend optimization needed)
```

---

## Best Practices

1. **Always classify before routing** - Prevents wrong skill activation
2. **Ask questions if confidence < 50%** - Better to clarify than assume
3. **Multi-domain is OK** - Many tasks span multiple areas
4. **Update classification mid-task** - Discovery phase may reveal new domains
5. **Learn from history** - Track which classifications led to successful tasks
6. **Context matters** - Same keywords mean different things in different projects
7. **Don't over-classify** - Primary + 2-3 secondary is enough

---

## Learning & Improvement

### Feedback Loop

```
Task classified as: UI/UX (90%)
Task completed: ✅
Actual domains needed: UI/UX, API/Backend

Feedback:
- Classification: Correct on primary
- Missed: API/Backend should have been 70%+ (new endpoint was needed)

Learning:
- "Add dashboard" usually implies API endpoint
- Update keyword weights: "dashboard" → +20% API/Backend
```

### Historical Patterns

Track successful classifications:
- "Add X" → Usually Feature + Implementation
- "Fix X" → Usually Bugfix + specific domain
- "Optimize X" → Usually Performance + specific area
- "Update docs" → Usually Documentation only

Store in supermemory for reuse.

---

## Notas

- **Not perfect**: Classification is heuristic, not ML
- **Context-dependent**: Same task may classify differently in different projects
- **Iterative**: Can re-classify after discovery phase
- **User override**: User can force different classification if AI is wrong

---

## Referencias

- **Source**: Adapted from huangserva skill-prompt-generator (domain-classifier concept)
- **Related**: prompt-master (uses classification for skill routing), intelligent-prompt-generator (uses domain context)
- **Tools**: supermemory (for learning historical patterns)

---

**Version**: 1.0
**Maintainer**: OpenCode Kit
**Last Updated**: 2026-01-15
