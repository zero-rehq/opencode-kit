---
name: Microservice Multi-Repo E2E (Targets + Gates + E2E_TRACE)
description: "Workflow E2E multi-repo: targets → snapshot → implement → no-any + ci → E2E_TRACE → review → wrap."
compatibility: opencode
---

# Skill: Multi-repo E2E

## TL;DR
1) `/task <t>` → targets + snapshot
2) `oc-targets set/auto` → define repos
3) Builder implementa SOLO targets
4) `oc-gate <t>` → no-any + ci report
5) `oc-e2e-trace <t>` y rellenar si cross-repo
6) Reviewer PASS/FAIL
7) `/wrap <t>` → wrap + jira note

## Definition of Done
- targets correctos
- gates ok en repos afectados
- no `any` nuevo
- E2E_TRACE consistente con diff
- worklog con evidencia
