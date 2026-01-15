---
name: Prompt Master
description: Meta-skill que orquesta todos los skills de prompt engineering y routing. Auto-selección y coordinación de skills basada en domain classification.
compatibility: opencode
trigger_keywords: ["auto", "smart routing", "best workflow", "optimize workflow"]
source: Adapted from huangserva skill-prompt-generator
---

# Prompt Master Skill

**Meta-skill** que orquesta todos los skills de prompt engineering y routing. Analiza task input, clasifica dominio, selecciona skills óptimos, genera briefs, valida calidad, y coordina workflow end-to-end.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Orchestrator recibe nuevo task (entry point principal)
- Task es complejo y requiere múltiples skills
- User solicita "best workflow" o "auto-optimize"
- Necesita coordinación inteligente de skills

MANUAL-TRIGGER:
- `/auto-workflow "<task>"` - Genera workflow completo automáticamente
- `/smart-task "<task>"` - Task con routing inteligente

---

## Features

✅ **End-to-End Orchestration**:
- Clasifica → Genera Brief → Valida → Ruta a Skills → Ejecuta → Aprende

✅ **Skill Coordination**:
- Domain-classifier: Entiende tipo de task
- Intelligent-prompt-generator: Genera Task Brief optimizado
- Prompt-analyzer: Valida calidad del brief
- Routing automático: Activa skills relevantes (ui-ux-pro-max, react-best-practices, etc.)

✅ **Adaptive Workflow**:
- Simple tasks: Workflow directo (classify → generate → execute)
- Complex tasks: Workflow faseado (discovery → contracts → implementation)
- Multi-repo: Coordina subagentes especializados

✅ **Learning Loop**:
- Guarda workflows exitosos en supermemory
- Aprende de failures (qué no hacer)
- Mejora routing con cada task

---

## Architecture

```
                      ┌─────────────────┐
                      │  PROMPT MASTER  │
                      │   (Orchestrator) │
                      └────────┬─────────┘
                               │
               ┌───────────────┼───────────────┐
               │               │               │
               ▼               ▼               ▼
       ┌───────────────┐ ┌──────────────┐ ┌────────────────┐
       │ DOMAIN        │ │ INTELLIGENT  │ │ PROMPT         │
       │ CLASSIFIER    │ │ PROMPT GEN   │ │ ANALYZER       │
       └───────┬───────┘ └──────┬───────┘ └────────┬───────┘
               │                │                   │
               └────────────────┼───────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
            ┌───────────────┐       ┌──────────────┐
            │ TIER 1 SKILLS │       │ TIER 2 SKILLS│
            │ (ui-ux, perf) │       │ (deploy, CI) │
            └───────────────┘       └──────────────┘
                    │                       │
                    └───────────┬───────────┘
                                │
                                ▼
                        ┌───────────────┐
                        │  SUBAGENTS    │
                        │ (builder, etc)│
                        └───────────────┘
                                │
                                ▼
                        ┌───────────────┐
                        │  EXECUTION    │
                        └───────────────┘
                                │
                                ▼
                        ┌───────────────┐
                        │  LEARNING     │
                        │ (supermemory) │
                        └───────────────┘
```

---

## Workflow Phases

### Phase 1: Classification

**Input**: User task description

**Process**:
```
1. Invoke domain-classifier
2. Get primary + secondary domains
3. Get confidence scores
4. Get warning flags
```

**Output**:
```json
{
  "primary": "UI/UX",
  "confidence": 90,
  "secondary": ["API/Backend", "Feature"],
  "warnings": [],
  "complexity": "MEDIUM"
}
```

**Decision**:
- If confidence < 50% → Ask clarifying questions
- If warnings present → Surface to user
- Else → Proceed to Phase 2

---

### Phase 2: Skill Selection

**Input**: Classification result

**Process**:
```
1. Map domains to skills (using Decision Matrix)
2. Rank skills by relevance
3. Filter by availability
4. Select top 3-5 skills
```

**Domain → Skills Mapping**:

| Domain | Required Skills | Optional Skills |
|--------|----------------|-----------------|
| **UI/UX** | ui-ux-pro-max, react-best-practices | web-design-guidelines |
| **API/Backend** | intelligent-prompt-generator | looking-up-docs |
| **Performance** | react-best-practices, web-design-guidelines | - |
| **Documentation** | documentation-sync | - |
| **Integration** | intelligent-prompt-generator, contract-keeper | repo-scout |
| **Feature** | intelligent-prompt-generator, ui-ux-pro-max | all |
| **Security** | web-design-guidelines | - |
| **DevOps** | github-actions-automation, vercel-deploy | - |

**Output**:
```json
{
  "recommended": [
    "ui-ux-pro-max",
    "react-best-practices",
    "intelligent-prompt-generator"
  ],
  "optional": [
    "documentation-sync",
    "web-design-guidelines"
  ]
}
```

---

### Phase 3: Brief Generation

**Input**: Classification + Skill selection

**Process**:
```
1. Query supermemory for context
   - Architecture
   - Previous similar tasks
   - Learned patterns
2. Invoke intelligent-prompt-generator
   - Mode: Task Brief or Phase Brief
   - Context: From supermemory
   - Domain: From classification
3. Generate optimized brief
```

**Output**: Task Brief (markdown)

---

### Phase 4: Quality Validation

**Input**: Generated brief

**Process**:
```
1. Invoke prompt-analyzer
2. Calculate Quality Score
3. Get recommendations (if score < 80)
4. Apply fixes if needed
5. Re-validate until score >= 80 or max 3 iterations
```

**Output**:
```json
{
  "qualityScore": 85,
  "issues": [],
  "ready": true
}
```

**Decision**:
- If score >= 80 → Proceed to Phase 5
- If score < 80 and fixes available → Apply fixes, re-validate
- If score < 80 and no fixes → Warn user, ask approval

---

### Phase 5: Workflow Execution

**Input**: Validated brief + Skill selection

**Process**:
```
1. Determine workflow type:
   - Simple: Direct execution
   - Medium: Phased (discovery → implementation)
   - Complex: Multi-phase (discovery → contracts → implementation → integration)

2. Route to subagents:
   - If UI/UX: builder with ui-ux-pro-max context
   - If multi-repo: repo-scout (parallel) → integration-builder
   - If performance: repo-scout → builder with perf context

3. Activate skills during execution:
   - ui-ux-pro-max: On component creation
   - react-best-practices: On React code changes
   - documentation-sync: After implementation
   - etc.

4. Monitor execution
   - Track progress
   - Surface issues
   - Adjust routing if needed
```

**Output**: Execution plan + Delegation to subagents

---

### Phase 6: Post-Task Learning

**Input**: Task result (success/failure)

**Process**:
```
1. Collect metrics:
   - Quality score of brief
   - Skills activated
   - Subagents used
   - Time taken
   - Success/failure
   - Issues encountered

2. Analyze patterns:
   - What worked well?
   - What didn't work?
   - Unexpected issues?

3. Save to supermemory:
   - Successful workflow patterns
   - Failed approaches (to avoid)
   - Domain-specific learnings
```

**Output**: Learned pattern saved

---

## Example: Complete Workflow

### Example 1: Simple UI Task

**User Input**: "Add dark mode toggle to settings"

**Phase 1: Classification**
```json
{
  "primary": "UI/UX (90%)",
  "secondary": ["Feature (70%)", "API/Backend (40%)"],
  "complexity": "LOW",
  "estimatedRepos": 1
}
```

**Phase 2: Skill Selection**
```json
{
  "recommended": [
    "ui-ux-pro-max (dark mode patterns)",
    "react-best-practices (theme context optimization)"
  ]
}
```

**Phase 3: Brief Generation**
```markdown
# Task Brief: Dark Mode Toggle

## Context
Add dark mode toggle to settings page. User can switch between light and dark theme.

## Scope
- [ ] Theme context in cloud_front
- [ ] Toggle component in SettingsPage
- [ ] CSS-in-JS dark mode styles

## Definition of Done
- [ ] Toggle switches between themes
- [ ] Theme persists in localStorage
- [ ] All pages support dark mode
- [ ] No `any` types
```

**Phase 4: Quality Validation**
```json
{
  "qualityScore": 85,
  "ready": true
}
```

**Phase 5: Workflow Execution**
```
Workflow: SIMPLE (direct execution)

1. Delegate to builder
2. Auto-trigger ui-ux-pro-max:
   - Suggest dark mode palette: #1a1a2e, #16213e
   - Suggest toggle design: Switch component
3. Builder implements
4. Auto-trigger react-best-practices:
   - Check: Theme context memoized? ✅
   - Check: No unnecessary re-renders? ✅
5. Review PASS
```

**Phase 6: Learning**
```
Saved to supermemory:
- Pattern: "dark mode" → UI/UX + react-best-practices
- Workflow: Simple UI tasks can be direct
- Quality: 85 score, completed without issues
```

---

### Example 2: Complex Multi-Repo Task

**User Input**: "Add catalogos feature"

**Phase 1: Classification**
```json
{
  "primary": "Feature (95%)",
  "secondary": ["Integration (90%)", "UI/UX (75%)", "API/Backend (85%)", "Database (80%)"],
  "complexity": "HIGH",
  "estimatedRepos": "3-5"
}
```

**Phase 2: Skill Selection**
```json
{
  "recommended": [
    "intelligent-prompt-generator (complex Task Brief)",
    "ui-ux-pro-max (catalogos UI)",
    "react-best-practices (performance)"
  ],
  "optional": [
    "documentation-sync (update docs after)"
  ]
}
```

**Phase 3: Brief Generation**
```markdown
# Task Brief: Catálogos Feature

## Context
Adding catálogos feature across 5 repos to allow users to browse product catalogs.

## Scope
- [ ] Database table `catalogos` (signage_service)
- [ ] API endpoint GET /api/catalogos (signage_service)
- [ ] Frontend page /catalogos (cloud_front)
- [ ] FTP proxy paths (ftp)
- [ ] Menu entry (etouch)

## Definition of Done
- [ ] E2E_TRACE documented
- [ ] All repos pass gates
- [ ] No `any` types
- [ ] Contracts validated

## Technical Notes
[DB schema, API signature, UI pattern, gotchas...]
```

**Phase 4: Quality Validation**
```json
{
  "qualityScore": 82,
  "issues": [
    {"priority": "HIGH", "title": "Add error handling"}
  ]
}
```

Prompt-analyzer suggests fixes → Applied → Re-validated → Score: 88 ✅

**Phase 5: Workflow Execution**
```
Workflow: COMPLEX (multi-phase)

Phase A: Discovery
1. Launch repo-scouts EN PARALELO (5 tasks)
   - repo-scout signage_service
   - repo-scout cloud_tag_back
   - repo-scout cloud_front
   - repo-scout ftp
   - repo-scout etouch
2. Synthesize findings

Phase B: Contracts
1. Invoke contract-keeper
2. Define CatalogoDTO
3. Validate cross-repo

Phase C: Implementation
1. Delegate to integration-builder
2. Implementation order: back → ftp → fronts
3. Auto-trigger skills:
   - ui-ux-pro-max (catalogos UI design)
   - react-best-practices (performance check)

Phase D: Integration
1. Validate E2E flow
2. Run gates per repo
3. Contract validation

Phase E: Review
1. Reviewer checks:
   - E2E_TRACE ✅
   - Gates ✅
   - No any ✅
   - Contracts ✅
2. PASS

Phase F: Documentation
1. Auto-trigger documentation-sync
2. Update README in 5 repos
```

**Phase 6: Learning**
```
Saved to supermemory:
- Pattern: "add X feature" → Feature + Integration (multi-repo)
- Workflow: Complex tasks need PHASED approach
- Skills: ui-ux-pro-max + react-best-practices + intelligent-prompt-generator
- Time: 2 days (within estimate)
- Quality: 88 score after fixes
```

---

## Decision Matrix

### Workflow Type Selection

| Complexity | Repos | Domains | Workflow Type | Phases |
|------------|-------|---------|---------------|--------|
| LOW | 1 | 1-2 | SIMPLE | 1 (execute) |
| MEDIUM | 1-2 | 2-3 | PHASED | 2 (discovery → implementation) |
| HIGH | 3+ | 3+ | MULTI-PHASE | 5 (discovery → contracts → implementation → integration → review) |

### Skill Activation Rules

| Condition | Skill to Activate | When |
|-----------|------------------|------|
| Domain = UI/UX | ui-ux-pro-max | On component creation |
| Domain = UI/UX + React | react-best-practices | After code written |
| Domain = Performance | react-best-practices + web-design-guidelines | On optimization task |
| Repos >= 3 | intelligent-prompt-generator | Before delegation |
| Domain = Documentation | documentation-sync | After implementation |
| Domain = DevOps | github-actions-automation | On CI/CD setup |
| Domain = Deploy | vercel-deploy | On preview request |
| External API used | looking-up-docs | When builder mentions library |

---

## Learning Patterns

### Successful Patterns (stored in supermemory)

```json
{
  "pattern": "simple-ui-task",
  "triggers": ["add button", "add page", "change color"],
  "workflow": "SIMPLE",
  "skills": ["ui-ux-pro-max", "react-best-practices"],
  "subagents": ["builder"],
  "avgQualityScore": 85,
  "avgTime": "2 hours",
  "successRate": 95
}
```

```json
{
  "pattern": "multi-repo-feature",
  "triggers": ["add feature", "new functionality"],
  "workflow": "MULTI-PHASE",
  "skills": ["intelligent-prompt-generator", "ui-ux-pro-max", "documentation-sync"],
  "subagents": ["repo-scout", "integration-builder", "builder", "contract-keeper", "reviewer"],
  "avgQualityScore": 82,
  "avgTime": "2 days",
  "successRate": 85
}
```

### Failed Patterns (to avoid)

```json
{
  "pattern": "skipped-discovery-multi-repo",
  "issue": "Skipped discovery phase for multi-repo task",
  "consequence": "Missed repos, incomplete implementation, rework needed",
  "lesson": "Always run discovery for 3+ repos",
  "occurrences": 3
}
```

---

## Configuration

### Settings (optional)

```json
{
  "promptMaster": {
    "minQualityScore": 80,
    "maxValidationIterations": 3,
    "autoApplyFixes": true,
    "learningEnabled": true,
    "skillPreferences": {
      "ui": ["ui-ux-pro-max", "react-best-practices"],
      "performance": ["react-best-practices", "web-design-guidelines"]
    },
    "workflowPreferences": {
      "simpleThreshold": {"repos": 1, "domains": 2},
      "complexThreshold": {"repos": 3, "domains": 3}
    }
  }
}
```

---

## CLI Commands

### `/auto-workflow "<task>"`

Genera workflow completo automáticamente:

```bash
/auto-workflow "Add user profile page"

# Output:
# ✅ Classification: UI/UX (90%), Feature (80%)
# ✅ Skills selected: ui-ux-pro-max, react-best-practices
# ✅ Brief generated (Quality: 85/100)
# ✅ Workflow: SIMPLE (direct execution)
#
# Delegating to builder...
```

### `/smart-task "<task>"`

Task con routing inteligente y feedback:

```bash
/smart-task "Fix performance issues"

# Output:
# ⚠️  AMBIGUOUS INPUT (Confidence: 35%)
#
# Clarifying questions:
# 1. Which specific pages or features are slow?
# 2. Is it page load time or interaction lag?
# 3. Do you have performance metrics?
#
# Please provide more details...
```

---

## Integration con Orchestrator

```markdown
## Orchestrator Workflow (con Prompt Master)

USER: /task "Add catalogos feature"

ORCHESTRATOR:
1. AUTO-TRIGGER prompt-master:
   - Classify task
   - Generate brief
   - Validate quality
   - Select workflow
   - Route to skills/subagents

2. prompt-master returns:
   - Task Brief (validated, 88/100)
   - Skills to activate: [ui-ux-pro-max, intelligent-prompt-generator, documentation-sync]
   - Workflow type: MULTI-PHASE
   - Subagents: [repo-scout (x5), integration-builder, builder, reviewer]

3. ORCHESTRATOR executes workflow:
   - Phase A: Launch repo-scouts EN PARALELO
   - Phase B: Contracts validation
   - Phase C: Implementation with skills
   - Phase D: Integration
   - Phase E: Review
   - Phase F: Documentation

4. Post-task:
   - prompt-master saves learned pattern
   - Quality metrics stored in supermemory
```

---

## Best Practices

1. **Trust the classification** - Domain-classifier is data-driven
2. **Validate quality always** - Don't skip prompt-analyzer
3. **Learn from history** - Query supermemory for similar tasks
4. **Adapt mid-flight** - Re-classify if discovery reveals new info
5. **Fail fast** - If confidence < 50%, ask questions immediately
6. **Parallelize when possible** - Multi-repo discovery should be parallel
7. **Document learnings** - Every task teaches something

---

## Metrics & Monitoring

### Track:
- Classification accuracy (predicted vs actual domains)
- Brief quality scores (trend over time)
- Workflow success rate (by type)
- Skill activation frequency (which skills used most)
- Time to completion (by complexity)
- Rework rate (tasks needing fixes after review)

### Goals:
- Quality score avg: > 80
- Success rate: > 85%
- Classification accuracy: > 90%
- Rework rate: < 15%

---

## Notas

- **Meta-skill**: Prompt Master coordinates other skills, doesn't execute tasks directly
- **Learning required**: Works best after 10+ tasks (historical data)
- **Fallback**: If prompt-master unavailable, orchestrator can work manually
- **Override**: User can override routing decisions if needed

---

## Referencias

- **Source**: Adapted from huangserva skill-prompt-generator (prompt-master concept)
- **Dependencies**: domain-classifier, intelligent-prompt-generator, prompt-analyzer
- **Related**: All TIER 1, TIER 2, TIER 3 skills
- **Tools**: supermemory (critical for learning)

---

**Version**: 1.0
**Maintainer**: OpenCode Kit
**Last Updated**: 2026-01-15
