---
name: Prompt Analyzer
description: Analiza Task Briefs y Phase Briefs para proveer insights, comparaciones y recomendaciones de mejora iterativa.
compatibility: opencode
trigger_keywords: ["analyze prompt", "improve brief", "compare briefs", "prompt insights"]
source: Adapted from huangserva skill-prompt-generator
---

# Prompt Analyzer Skill

Analiza **Task Briefs** y **Phase Briefs** para proveer insights detallados, comparaciones, recomendaciones y estadísticas. Ayuda a mejorar prompts iterativamente detectando patrones exitosos y anti-patrones.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Orchestrator termina de generar un brief (feedback inmediato)
- User solicita: "analyze this task brief", "improve this prompt", "why did this brief work?"
- Después de task completado (post-mortem analysis)
- Para comparar múltiples briefs y aprender qué funciona mejor

MANUAL-TRIGGER:
- `/analyze-brief <task>` - Analiza Task Brief de una tarea específica
- `/compare-briefs <task1> <task2>` - Compara dos Task Briefs

---

## Features

✅ **5 Análisis Modes**:
1. **Detail View** - Ver estructura y elementos del brief
2. **Quality Score** - Scoring basado en best practices
3. **Comparison** - Comparar dos briefs lado a lado
4. **Recommendations** - Sugerencias de mejora específicas
5. **Statistics** - Métricas y patrones históricos

✅ **Quality Metrics**:
- Clarity Score (0-100): ¿Qué tan claro es el scope?
- Completeness Score (0-100): ¿Tiene todas las secciones necesarias?
- Consistency Score (0-100): ¿Hay contradicciones?
- Actionability Score (0-100): ¿Es implementable sin ambigüedades?

✅ **Pattern Detection**:
- Detecta briefs exitosos vs problemáticos
- Identifica common issues (scope creep, missing DoD, etc.)
- Aprende qué elementos correlacionan con éxito

---

## Mode 1: Detail View

### Input

```typescript
interface DetailViewInput {
  briefPath: string;          // worklog/YYYY-MM-DD_task.md
  section?: string;            // Optional: analizar sección específica
}
```

### Output

```markdown
# Brief Analysis: Task Catalogos

## Overview
- Type: Task Brief
- Created: 2026-01-15
- Repos affected: 5 (signage_service, cloud_tag_back, cloud_front, ftp, etouch)
- Estimated complexity: HIGH (multi-repo, new feature)

## Structure Analysis

✅ **Context Section**: Present (3 paragraphs, 120 words)
  - Business context: ✅ Clear
  - Architecture context: ✅ From supermemory
  - E2E flow pattern: ✅ Documented

✅ **Scope Section**: Present
  - In Scope: 5 items (specific, checkboxes)
  - Out of Scope: 3 items (clear boundaries)
  - Trade-offs: ✅ Mentioned (pagination optional if < 50 items)

✅ **Definition of Done**: Present (7 criteria)
  - E2E_TRACE: ✅ Required
  - Quality gates: ✅ Specified (lint, typecheck, build)
  - Contract validation: ✅ Cross-repo
  - No `any`: ✅ Explicit

⚠️ **Constraints Section**: Present but brief (4 items)
  - Could expand: Security constraints (auth for endpoints?)
  - Could expand: Performance targets (page load time?)

✅ **Technical Notes**: Present (excellent detail)
  - DB schema: ✅ Provided
  - API signature: ✅ TypeScript interface
  - Frontend component: ✅ Pattern reference
  - Known gotchas: ✅ Listed

## Element Inventory

- **Repos mentioned**: 5
- **Endpoints specified**: 1 (GET /api/catalogos)
- **DTOs defined**: 1 (Catalogo interface)
- **Components referenced**: 2 (CatalogosGrid, CatalogosPage)
- **External dependencies**: 1 (ftp_signed_proxy)
- **Code examples**: 3 (SQL, TypeScript, component)
- **Warnings/gotchas**: 3

## Potential Issues

⚠️ **Medium Priority**:
1. Missing: Error handling strategy (what if DB migration fails?)
2. Missing: Rollback plan (how to undo if deployment fails?)
3. Ambiguous: "Card grid like ProductsPage" - which specific pattern?

ℹ️ **Low Priority**:
1. Could improve: Add example screenshot or wireframe
2. Could improve: Specify loading states (skeleton, spinner?)

## Recommendations

1. Add "Rollback Plan" subsection in Technical Notes
2. Expand Constraints: Add auth requirements (public endpoint or authenticated?)
3. Clarify UI reference: Link to ProductsPage.tsx or provide code snippet
4. Consider: Add "Testing Strategy" section (manual? automated?)
```

---

## Mode 2: Quality Score

### Input

```typescript
interface QualityScoreInput {
  briefPath: string;
}
```

### Output

```markdown
# Quality Score: Task Catalogos

## Overall Score: 82/100 (GOOD)

### Breakdown

**Clarity Score: 85/100** ✅
- Scope clearly defined (+20)
- Out of scope explicitly stated (+15)
- Technical examples provided (+20)
- Some ambiguous references (-10, "card grid like ProductsPage")
- Missing error handling strategy (-10)

**Completeness Score: 78/100** ⚠️
- All required sections present (+30)
- Context from supermemory (+10)
- E2E_TRACE required (+15)
- Technical notes detailed (+15)
- Missing: Rollback plan (-8)
- Missing: Testing strategy (-7)
- Missing: Error scenarios (-7)

**Consistency Score: 90/100** ✅
- No contradictions detected (+30)
- Repos consistent across sections (+20)
- Constraints align with scope (+20)
- DTOs referenced but not fully defined (-10, CatalogoDTO)

**Actionability Score: 80/100** ✅
- Clear implementation order (+20)
- Code snippets provided (+15)
- API signatures specified (+15)
- DB schema provided (+15)
- UI patterns referenced but not specific (-10)
- Error cases not covered (-15)

## Comparison to Historical Average

- Your score: 82/100
- Average score (last 10 tasks): 74/100
- **+8 points above average** ✅

## Top Strengths

1. Excellent technical detail (DB schema, API signature, code examples)
2. Clear scope boundaries (in/out of scope)
3. Cross-repo awareness (contracts, E2E flow)

## Top Weaknesses

1. Missing error handling and rollback strategy
2. Ambiguous UI references ("like ProductsPage")
3. No testing strategy specified

## Action Items to Improve

1. **HIGH**: Add "Error Handling" subsection
   - What if DB migration fails?
   - What if API returns 500?
   - What if FTP images not found?

2. **MEDIUM**: Add "Rollback Plan"
   - How to revert migration?
   - How to remove feature flag?

3. **LOW**: Clarify UI references
   - Link to ProductsPage.tsx
   - Or provide inline code snippet
```

---

## Mode 3: Comparison

### Input

```typescript
interface ComparisonInput {
  brief1Path: string;
  brief2Path: string;
  focusArea?: string;  // Optional: "scope" | "structure" | "quality"
}
```

### Output

```markdown
# Brief Comparison

## Briefs
- **Brief A**: Task Catalogos (2026-01-15) - 5 repos, HIGH complexity
- **Brief B**: Task Logout Button (2026-01-12) - 2 repos, LOW complexity

## Side-by-Side Structure

| Section | Brief A (Catalogos) | Brief B (Logout Button) |
|---------|---------------------|-------------------------|
| **Context** | ✅ 120 words, arch context | ✅ 50 words, simple |
| **Scope** | ✅ 5 in-scope, 3 out-scope | ✅ 4 in-scope, 2 out-scope |
| **DoD** | ✅ 7 criteria | ✅ 5 criteria |
| **Constraints** | ⚠️ 4 items (brief) | ✅ 6 items (detailed) |
| **Technical Notes** | ✅ Excellent (DB, API, UI) | ⚠️ Minimal (1 code snippet) |

## Quality Score Comparison

| Metric | Brief A | Brief B | Winner |
|--------|---------|---------|--------|
| **Clarity** | 85/100 | 90/100 | Brief B ✅ |
| **Completeness** | 78/100 | 70/100 | Brief A ✅ |
| **Consistency** | 90/100 | 95/100 | Brief B ✅ |
| **Actionability** | 80/100 | 85/100 | Brief B ✅ |
| **Overall** | 82/100 | 85/100 | Brief B ✅ |

## Key Differences

### What Brief B does better:
1. **Clearer UI references**: Links to specific components
2. **Better constraints**: Security explicit (clear session, revoke token)
3. **Simpler scope**: Single feature, easy to understand

### What Brief A does better:
1. **More technical detail**: DB schema, API signature, gotchas
2. **Better multi-repo coordination**: E2E flow across 5 repos
3. **Code examples**: 3 examples vs 1

## Lessons Learned

✅ **From Brief B (apply to future complex briefs)**:
- Link to specific components instead of "like ComponentX"
- Security constraints explicit (auth, session, tokens)
- Simple language even for complex tasks

✅ **From Brief A (apply to future simple briefs)**:
- Provide code examples even for trivial tasks
- Document gotchas proactively
- Multi-repo coordination patterns

## Recommendation

For **future multi-repo briefs** (like Brief A):
- Keep the excellent technical detail
- Add Brief B's clarity in constraints and references
- Estimated improvement: +3 to +5 points in Quality Score
```

---

## Mode 4: Recommendations

### Input

```typescript
interface RecommendationsInput {
  briefPath: string;
  priority?: "critical" | "high" | "medium" | "low" | "all";
}
```

### Output

```markdown
# Recommendations: Task Catalogos

## CRITICAL Issues (blocking)

*None detected* ✅

## HIGH Priority (should fix before delegation)

### 1. Add Error Handling Strategy

**Current state**: No mention of error scenarios

**Recommended addition** (in Technical Notes):
```markdown
## Error Handling

- **DB Migration fails**: Rollback migration, alert devops
- **API 500 error**: Log error, return {error: "message"}, don't crash
- **FTP image 404**: Show placeholder image, log warning
- **Frontend fetch fails**: Show error toast, retry button
```

**Impact**: Prevents builder from making assumptions about error handling
**Effort**: 5 minutes
**ROI**: High (avoids rework)

### 2. Specify Auth Requirements

**Current state**: API endpoint documented but auth not mentioned

**Recommended addition** (in Constraints):
```markdown
- Endpoint GET /api/catalogos is **public** (no auth required)
  OR
- Endpoint GET /api/catalogos requires JWT token (validate with authMiddleware)
```

**Impact**: Prevents security vulnerability or over-engineering
**Effort**: 1 minute
**ROI**: Critical (security)

## MEDIUM Priority (nice-to-have)

### 3. Clarify UI Reference

**Current state**: "Use CatalogosGrid similar to ProductsGrid"

**Recommended change**:
```markdown
**Frontend Component**:
- Use CatalogosGrid similar to ProductsGrid (cloud_front/src/components/ProductsGrid.tsx)
- Pattern: Grid layout with cards, 3 columns on desktop, 1 on mobile
- Image: <Image src={proxy(catalog.imagen)} width={300} height={200} />
```

**Impact**: Builder knows exactly what pattern to follow
**Effort**: 2 minutes
**ROI**: Medium (reduces back-and-forth)

### 4. Add Testing Strategy

**Recommended addition** (new section):
```markdown
## Testing Strategy

- **Manual testing**:
  - [ ] Navigate to /catalogos
  - [ ] Verify grid displays
  - [ ] Click catalog card (if clickable)
  - [ ] Check images load from FTP

- **Automated testing** (if test suite exists):
  - [ ] API test: GET /catalogos returns 200 + array
  - [ ] Component test: CatalogosGrid renders with mock data
```

**Impact**: Clear testing expectations
**Effort**: 3 minutes
**ROI**: Medium (quality assurance)

## LOW Priority (optional)

### 5. Add Screenshot or Wireframe

**Recommended**: ASCII wireframe or Figma link showing expected UI layout

**Impact**: Visual clarity
**Effort**: 5-10 minutes
**ROI**: Low (helpful but not critical)

## Summary

- **Must fix**: 2 HIGH priority items (auth, error handling)
- **Should fix**: 2 MEDIUM priority items (UI clarity, testing)
- **Could fix**: 1 LOW priority item (wireframe)
- **Estimated time to address**: 15 minutes total for HIGH+MEDIUM

**Predicted score improvement**: 82 → 88 (+6 points) if HIGH+MEDIUM addressed
```

---

## Mode 5: Statistics

### Input

```typescript
interface StatisticsInput {
  scope?: "project" | "user" | "global";
  timeRange?: string;  // "last-7-days" | "last-30-days" | "all-time"
}
```

### Output

```markdown
# Brief Statistics (Last 30 Days)

## Overall Metrics

- **Total briefs analyzed**: 23
- **Average Quality Score**: 74/100
- **Success rate**: 78% (18/23 tasks completed without major rework)
- **Average repos per task**: 2.8

## Quality Score Distribution

```
0-50  (Poor):       ■■ (2)
51-70 (Below Avg):  ■■■■■ (5)
71-80 (Average):    ■■■■■■■■ (8)
81-90 (Good):       ■■■■■■ (6)
91-100 (Excellent): ■■ (2)
```

## Common Issues (Top 10)

| Issue | Frequency | Avg Impact |
|-------|-----------|------------|
| Missing error handling | 15/23 (65%) | -8 points |
| Ambiguous UI references | 12/23 (52%) | -6 points |
| No testing strategy | 18/23 (78%) | -5 points |
| Missing rollback plan | 14/23 (61%) | -7 points |
| Unclear auth requirements | 9/23 (39%) | -10 points |
| Incomplete DoD | 7/23 (30%) | -12 points |
| Missing code examples | 6/23 (26%) | -8 points |
| No E2E_TRACE | 3/23 (13%) | -15 points |
| Scope creep | 5/23 (22%) | -10 points |
| Contradictions | 2/23 (9%) | -12 points |

## Success Patterns

### High-scoring briefs (85+) have:
- ✅ Code examples (100%)
- ✅ E2E_TRACE documented (100%)
- ✅ Error handling strategy (87.5%)
- ✅ Security constraints explicit (75%)
- ✅ Testing strategy (62.5%)

### Failed tasks (rework needed) usually had:
- ❌ Missing DoD (80%)
- ❌ Ambiguous scope (60%)
- ❌ No error handling (100%)
- ❌ Unclear dependencies (60%)

## Recommendations Based on Data

1. **Add error handling by default** (missing in 65% of briefs)
   - Template: Create error-handling-template.md
   - Impact: Could prevent 40% of rework

2. **Enforce E2E_TRACE** (missing in 13%, but 100% of failures had missing E2E)
   - Action: Add validation step in orchestrator
   - Impact: Reduce failures by 13%

3. **UI reference guidelines** (ambiguous in 52%)
   - Template: Link to actual component files
   - Impact: Save ~2 hours per task on clarifications

## Trending Improvements

- **Week 1-2 avg score**: 68/100
- **Week 3-4 avg score**: 74/100
- **Week 5-6 avg score**: 79/100
- **Trend**: +5.5 points improvement over 6 weeks ✅

## Top Brief Authors (by avg quality)

1. Orchestrator + supermemory context: 82/100 avg
2. Orchestrator + manual context: 76/100 avg
3. User-written briefs: 68/100 avg

**Insight**: Supermemory context adds +6 to +8 points on average
```

---

## Integration con Workflow

### Auto-Trigger: Después de Brief Generation

```
Orchestrator genera Task Brief usando intelligent-prompt-generator

AUTO-TRIGGER prompt-analyzer:
1. Analiza brief recién generado (Detail View)
2. Calcula Quality Score
3. Si score < 75:
   - Muestra recomendaciones HIGH priority
   - Pregunta: "¿Aplicar mejoras sugeridas?"
4. Si score >= 75:
   - Log brief como "good quality"
   - Procede con delegación

Builder recibe brief optimizado
```

### Manual-Trigger: Post-Mortem

```
USER: /analyze-brief catalogos

Orchestrator delega a prompt-analyzer:
1. Lee worklog/2026-01-15_catalogos.md
2. Ejecuta Quality Score + Recommendations
3. Retorna análisis al user
4. Opcional: Compara con task similar anterior
5. Guarda insights en supermemory (learned-pattern)
```

### Comparison Workflow

```
USER: /compare-briefs catalogos logout-button

Orchestrator:
1. Lee ambos briefs
2. Ejecuta Comparison mode
3. Muestra lado a lado
4. Extrae lessons learned
5. Sugerencia: "Apply pattern X from brief B to future briefs"
```

---

## Best Practices

1. **Run analysis before delegation** - Catch issues early
2. **Compare successful vs failed briefs** - Learn what works
3. **Track metrics over time** - Monitor improvement
4. **Use recommendations iteratively** - Each brief better than last
5. **Share insights with team** - Document learned patterns in supermemory
6. **Focus on HIGH priority first** - Maximum ROI
7. **Automate common fixes** - Template for error handling, auth, etc.

---

## Output Formats

### CLI Output (for scripts)

```json
{
  "briefPath": "worklog/2026-01-15_catalogos.md",
  "qualityScore": {
    "overall": 82,
    "clarity": 85,
    "completeness": 78,
    "consistency": 90,
    "actionability": 80
  },
  "issues": [
    {
      "priority": "HIGH",
      "title": "Missing error handling strategy",
      "impact": -8,
      "effort": "5 minutes"
    }
  ],
  "recommendations": [
    {
      "priority": "HIGH",
      "section": "Technical Notes",
      "suggestion": "Add Error Handling subsection"
    }
  ]
}
```

### Markdown Output (for human reading)

Usa formatos mostrados arriba en cada mode (Detail View, Quality Score, etc.)

---

## Notas

- **Scoring algorithm**: Basado en heurísticas + historical data
- **Learning**: Scores mejoran con más datos (requires supermemory)
- **Customizable**: Ajustar weights de metrics según proyecto
- **False positives**: Algunos warnings pueden no aplicar (revisar manualmente)

---

## Referencias

- **Source**: Adapted from huangserva skill-prompt-generator
- **Related**: intelligent-prompt-generator (genera briefs), domain-classifier (clasifica tasks)
- **Tools**: supermemory (para historical data y patterns)

---

**Version**: 1.0
**Maintainer**: OpenCode Kit
**Last Updated**: 2026-01-15
