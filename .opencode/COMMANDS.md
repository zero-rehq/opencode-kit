# OpenCode Kit - System Commands

## Overview

OpenCode Kit provides a set of commands to manage multi-repo workflows, quality gates, and documentation. These commands are available via the `opencode.json` configuration.

## Table of Contents

- [Orchestration Commands](#orchestration-commands)
- [Quality Gate Commands](#quality-gate-commands)
- [Documentation Commands](#documentation-commands)
- [Validation Scripts](#validation-scripts)
- [Skill Scripts](#skill-scripts)

---

## Orchestration Commands

### `bootstrap`

Bootstraps documentation for a new repository.

**Description**: Creates AGENTS.md (and optional service.yaml) in target repositories.

**Usage**:
```bash
oc bootstrap
```

**Template**:
```
Bootstrap repo docs.
1) Run ./.opencode/bin/oc-bootstrap-repos --service-yaml
2) (Optional) Run ./.opencode/bin/oc-catalog-sync
3) Summarize which repos got AGENTS.md/service.yaml created.
```

**Output**:
- AGENTS.md file in each target repo
- service.yaml (optional) for service catalog
- Summary of repos bootstrapped

---

### `task`

Starts a multi-repo task with targets, worklog, and snapshot.

**Description**: Initializes a new task, sets target repos, creates worklog, and takes a before snapshot.

**Usage**:
```bash
oc task <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task (e.g., "add-catalogos-feature")

**Template**:
```
We are starting task: <task-name>.
1) Run ./.opencode/bin/oc-targets init "<task-name>"
2) Set targets: ./.opencode/bin/oc-targets auto "<task-name>" "<query>" (or set manually)
3) Run ./.opencode/bin/oc-snapshot "<task-name>" (before)
4) Write an ordered plan checklist into the worklog.
```

**Output**:
- Task initialized in worklog
- Target repos set
- Before snapshot taken
- Plan checklist created

---

### `wrap`

Wraps up a completed task with CI gates, snapshot, commits, and Jira note.

**Description**: Finalizes a task by running gates, taking after snapshot, generating Jira note, and ensuring DoD is satisfied.

**Usage**:
```bash
oc wrap <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task to wrap

**Template**:
```
We are wrapping task: <task-name>.
1) Run ./.opencode/bin/oc-gate "<task-name>"
2) Run ./.opencode/bin/oc-wrap "<task-name>"
3) Run ./.opencode/bin/oc-jira-note "<task-name>"
4) Ask @reviewer for final PASS/FAIL notes.
5) Ensure DoD is satisfied.
```

**Output**:
- All gates passed
- After snapshot taken
- Jira note generated
- Final review completed
- Definition of Done satisfied

---

## Quality Gate Commands

### `gate`

Runs quality gates on target repositories.

**Description**: Executes no-any scan and best-effort CI on target repos to ensure code quality.

**Usage**:
```bash
oc gate <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task

**Template**:
```
Run gates for task: <task-name>.
1) Run ./.opencode/bin/oc-gate "<task-name>"
2) Paste key failures/summaries into the worklog.
3) Ask @reviewer for PASS/FAIL using E2E_TRACE + diff.
```

**Output**:
- Lint results
- Format check results
- Typecheck results
- Build results
- Test results
- no-any scan results

---

### `no-any`

Scans target repositories for TypeScript `any` type usage.

**Description**: Searches for `any` types in TypeScript/TSX files and reports violations.

**Usage**:
```bash
oc no-any <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task

**Template**:
```
Run no-any scan for task: <task-name>.
1) Run ./.opencode/bin/oc-no-any "<task-name>"
2) If FAIL: remove/replace with unknown + narrowing, or document why unavoidable.
```

**Output**:
- List of files with `any` types
- Line numbers for each occurrence
- Recommendations for fixing

**Common Patterns**:
- `: any` - Explicit any type
- `as any` - Type assertion
- `<any>` - Generic any type

---

## Documentation Commands

### `e2e-trace`

Inserts E2E_TRACE template into worklog.

**Description**: Creates a structured E2E trace template for documenting cross-repo workflows.

**Usage**:
```bash
oc e2e-trace <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task

**Template**:
```
Insert E2E_TRACE template for task: <task-name>.
1) Run ./.opencode/bin/oc-e2e-trace "<task-name>"
2) Fill the template with real paths/endpoints/payloads and verification steps.
```

**Output**:
- E2E_TRACE template in worklog
- Structured format for documenting flows

**E2E_TRACE Sections**:
- Entry UI
- Front client/hook
- Backend endpoint
- Service/internal call(s)
- External integration (proxy/storage/DB)
- Response shape
- UI states affected

---

### `jira-note`

Generates a Jira comment draft from worklog.

**Description**: Creates a formatted Jira comment summarizing task work.

**Usage**:
```bash
oc jira-note <task-name>
```

**Arguments**:
- `<task-name>`: Name of the task

**Template**:
```
Generate Jira note for task: <task-name>.
1) Run ./.opencode/bin/oc-jira-note "<task-name>"
2) Optionally ask @scribe to refine it into a final Jira comment.
```

**Output**:
- Formatted Jira comment
- Task summary
- Changes made
- Repos affected
- Evidence pack

---

## Validation Scripts

### `validate-skills.sh`

Validates skill structure across the opencode-kit system.

**Description**: Checks all skills for proper frontmatter, naming conventions, and required files.

**Usage**:
```bash
.opencode/scripts/validate-skills.sh
```

**Location**: `.opencode/scripts/validate-skills.sh`

**Checks**:
- SKILL.md exists for each skill
- Frontmatter has `name` and `description` fields
- Name in frontmatter matches directory name
- Template skills marked properly
- Router documentation exists (WORKFLOW_ROUTER.md or RULES_ROUTER.md)
- No duplicate skill names

**Output**:
- Validation report
- Errors and warnings
- Pass/Fail status

---

### `validate-agents.sh`

Validates agent configuration and permissions.

**Description**: Checks all agents for proper frontmatter, mode, and required fields.

**Usage**:
```bash
.opencode/scripts/validate-agents.sh
```

**Location**: `.opencode/scripts/validate-agents.sh`

**Checks**:
- Agent files exist for all expected agents
- Frontmatter has required fields: description, mode, model, temperature
- Mode is valid (primary or subagent)
- Tools section exists and has skill enabled
- Permission section exists

**Expected Agents**:
- orchestrator
- builder
- reviewer
- scribe
- skills-router-agent
- repo-scout
- contract-keeper
- docs-specialist
- bootstrap-scout
- integration-builder

---

### `validate-permissions.sh`

Validates specific permission rules across agents.

**Description**: Ensures agents have correct permissions based on their role.

**Usage**:
```bash
.opencode/scripts/validate-permissions.sh
```

**Location**: `.opencode/scripts/validate-permissions.sh`

**Rules**:
- **Orchestrator**: NO edit, NO bash (except allow-list)
- **Builder**: YES edit, YES bash (with restrictions)
- **Reviewer**: NO edit, bash: ask for most, allow for git/rg
- **Scribe/Repo-Scout/Contract-Keeper**: NO edit, NO bash
- **Docs-Specialist/Bootstrap-Scout**: YES edit, NO bash
- **Integration-Builder**: YES edit, YES bash

---

## Skill Scripts

### Next.js SSR Optimization

#### `analyze-ssr.sh`

Analyzes Next.js project for SSR optimization opportunities.

**Usage**:
```bash
.opencode/skill/nextjs-ssr-optimization/scripts/analyze-ssr.sh [project-path]
```

**Location**: `.opencode/skill/nextjs-ssr-optimization/scripts/analyze-ssr.sh`

**Checks**:
- Server vs Client Components ratio
- Suspense boundaries usage
- Async/await patterns
- React.cache() usage
- Parallel data fetching (Promise.all)
- Client-side data fetching (waterfalls)
- Static generation (generateStaticParams)
- ISR usage (revalidate)

**Output**:
- Analysis report
- Warnings for optimization opportunities
- Recommendations

#### `checklist-ssr.sh`

Displays SSR optimization checklist.

**Usage**:
```bash
.opencode/skill/nextjs-ssr-optimization/scripts/checklist-ssr.sh
```

**Location**: `.opencode/skill/nextjs-ssr-optimization/scripts/checklist-ssr.sh`

**Categories**:
- Critical (Do First)
- High Priority
- Medium Priority
- Metrics to Improve
- Anti-Patterns to Avoid

---

### API Documentation Generator

#### `generate-openapi.sh`

Generates OpenAPI spec from code.

**Usage**:
```bash
.opencode/skill/api-documentation-generator/scripts/generate-openapi.sh [framework] [output-file]
```

**Location**: `.opencode/skill/api-documentation-generator/scripts/generate-openapi.sh`

**Supported Frameworks**:
- express
- nextjs
- nestjs

**Output**:
- OpenAPI 3.0 spec JSON
- Setup instructions for the framework

#### `validate-openapi.sh`

Validates OpenAPI spec and checks for drift.

**Usage**:
```bash
.opencode/skill/api-documentation-generator/scripts/validate-openapi.sh [openapi.json]
```

**Location**: `.opencode/skill/api-documentation-generator/scripts/validate-openapi.sh`

**Checks**:
- Valid JSON structure
- Required OpenAPI fields (openapi version, info.title)
- Paths documented
- Descriptions for paths
- Response schemas
- Tags
- Operation IDs
- Drift between code and documentation

---

### GitHub Actions Automation

#### `setup-ci.sh`

Sets up GitHub Actions CI/CD workflow for a repository.

**Usage**:
```bash
.opencode/skill/github-actions-automation/scripts/setup-ci.sh [project-type] [repo-path]
```

**Location**: `.opencode/skill/github-actions-automation/scripts/setup-ci.sh`

**Supported Project Types**:
- nodejs
- nextjs
- react
- python

**Creates**:
- `.github/workflows/ci.yml` with quality gates

**Quality Gates**:
- Lint
- Format check
- Type check (for TypeScript)
- Build
- Test
- no-any scan

---

### Vercel Deploy

#### `deploy.sh`

Deploys a project to Vercel.

**Usage**:
```bash
.opencode/skill/vercel-deploy/scripts/deploy.sh [project-path]
```

**Location**: `.opencode/skill/vercel-deploy/scripts/deploy.sh`

**Features**:
- Auto-detects framework (40+ frameworks supported)
- Creates deployment package
- Deploys to Vercel preview
- Returns preview URL and claim URL

**Output**:
- JSON with deployment details
- Preview URL
- Claim URL
- Deployment ID
- Project ID

---

### Release Notes

#### `generate-release-notes.sh`

Generates release notes from git commits.

**Usage**:
```bash
.opencode/skill/release-notes/scripts/generate-release-notes.sh [tag] [prev-tag]
```

**Location**: `.opencode/skill/release-notes/scripts/generate-release-notes.sh`

**Arguments**:
- `tag`: Current tag (default: HEAD)
- `prev-tag`: Previous tag (default: auto-detected)

**Output**:
- Markdown release notes
- Categorized by commit type (feat, fix, docs, refactor, etc.)
- Statistics (commits, authors, contributors)

**Categories**:
- feat: New features
- fix: Bug fixes
- docs: Documentation changes
- refactor: Code refactoring
- perf: Performance improvements
- test: Test changes
- ci: CI/CD changes
- chore: Maintenance
- style: Code style changes
- build: Build system changes
- other: Other changes

---

## Quick Reference

| Command | Purpose | Alias |
|---------|---------|-------|
| `oc bootstrap` | Initialize new repo docs | - |
| `oc task` | Start new task | - |
| `oc wrap` | Complete task | - |
| `oc gate` | Run quality gates | - |
| `oc no-any` | Scan for `any` types | - |
| `oc e2e-trace` | Insert E2E trace template | - |
| `oc jira-note` | Generate Jira comment | - |

---

## Best Practices

1. **Always run `oc gate` before committing** to ensure code quality
2. **Use `oc e2e-trace` at the start** of any multi-repo task
3. **Run `oc no-any` after changes** to catch type issues early
4. **Use `oc jira-note`** when task is complete for documentation
5. **Validate skills/agents** after any changes to `.opencode/` structure

---

## Troubleshooting

### Command not found

If you see "command not found" for an `oc` command:
1. Verify `opencode.json` is in the correct location
2. Check that the command is defined in `opencode.json`
3. Ensure the tool calling the commands has access to `opencode.json`

### Validation failures

If validation scripts fail:
1. Check the error message for specific issues
2. Fix the reported problems
2. Re-run the validation script
3. All errors should be resolved before proceeding

### Script execution errors

If skill scripts fail:
1. Verify the script is executable: `chmod +x script.sh`
2. Check that required tools are installed (bash, jq, ripgrep, etc.)
3. Review script error messages for details

---

**Last Updated**: 2026-01-16
