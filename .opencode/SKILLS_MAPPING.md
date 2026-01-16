# Skills Name-to-Index Mapping

Este archivo contiene el mapeo entre los nombres de skills y sus índices correspondientes en el sistema opencode (0-17).

El orden de índices se basa en el orden alfabético de los nombres de los skills.

| Nombre del Skill | Índice | Archivo |
|------------------|--------|---------|
| API Documentation Generator | 0 | .opencode/skill/api-documentation-generator/SKILL.md |
| Documentation Sync (Drift Detection) | 1 | .opencode/skill/documentation-sync/SKILL.md |
| Domain Classifier | 2 | .opencode/skill/domain-classifier/SKILL.md |
| GitHub Actions Automation (CI/CD) | 3 | .opencode/skill/github-actions-automation/SKILL.md |
| Intelligent Prompt Generator | 4 | .opencode/skill/intelligent-prompt-generator/SKILL.md |
| Looking Up Docs (Context7) | 5 | .opencode/skill/looking-up-docs/SKILL.md |
| Microservice Multi-Repo E2E (Targets + Gates + E2E_TRACE) | 6 | .opencode/skill/microservices/SKILL.md |
| Next.js SSR Optimization | 7 | .opencode/skill/nextjs-ssr-optimization/SKILL.md |
| Prompt Analyzer | 8 | .opencode/skill/prompt-analyzer/SKILL.md |
| Prompt Generator (bridge) | 9 | .opencode/skill/prompt-generator/SKILL.md |
| Prompt Master | 10 | .opencode/skill/prompt-master/SKILL.md |
| React Best Practices (Vercel Engineering) | 11 | .opencode/skill/react-best-practices/SKILL.md |
| Release Notes (Changelog Generator) | 12 | .opencode/skill/release-notes/SKILL.md |
| Smart Router (Multi-Repo E2E Workflows) | 13 | .opencode/skill/smart-router/SKILL.md |
| UI/UX Pro Max (Design Intelligence) | 14 | .opencode/skill/ui-ux-pro-max/SKILL.md |
| Vercel Deploy (Preview Deployments) | 15 | .opencode/skill/vercel-deploy/SKILL.md |
| Web Design Guidelines (Vercel Labs) | 16 | .opencode/skill/web-design-guidelines/SKILL.md |
| Workflow Orchestration (Multi-Script Sequential) | 17 | .opencode/skill/workflow-orchestration/SKILL.md |

---

## Resumen

- **Total de skills**: 18
- **Rango de índices**: 0-17
- **Criterio de ordenamiento**: Alfabético por nombre del skill

---

## Uso

Este mapeo es útil para:

1. **Referencia rápida**: Verificar qué índice corresponde a cada skill
2. **Debugging**: Cuando el sistema intenta cargar un skill por nombre en lugar de índice
3. **Integración**: Convertir nombres de skills a índices para llamadas al sistema

---

## Notas

- Los nombres de skills se extraen del campo `name` en el frontmatter YAML de cada archivo `SKILL.md`
- Los nombres pueden incluir descriptores adicionales entre paréntesis (ej: "(Vercel Labs)")
- El índice es el identificador numérico usado internamente por el sistema opencode para cargar skills

---

**Generado**: 2026-01-16
**Total skills**: 18
