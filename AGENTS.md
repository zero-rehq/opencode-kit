# Reglas del workspace (Multi‑repo E2E)

Estas reglas son **no negociables** cuando una tarea afecta 2+ repos.

## Principios

- **Targets first**: si un repo no está en targets, NO se toca.
- **Cambios pequeños**: commits por repo, y sin refactors de paseo.
- **Contratos primero**: si cambias DTO/API/eventos, actualiza consumidor + proveedor.
- **E2E_TRACE obligatorio** para cross‑repo.

## Roles (agents)

- `@orchestrator` (primary): router + gatekeeper. Divide en fases y **autoriza avance**.
- `@builder`: implementa y ejecuta comandos. Entrega diffs + evidencia.
- `@reviewer`: PASS/FAIL. Valida E2E_TRACE, no‑any, gates y coherencia.
- `@scribe`: worklog + nota para Jira. No inventa.

## Definition of Done (por fase)

- [ ] Targets correctos (lista de repos en scope).
- [ ] Gates en repos afectados: lint/format/typecheck/build (y test si aplica).
- [ ] No aparece `any` nuevo (o está justificado y aislado).
- [ ] E2E_TRACE completado y consistente con el diff.
- [ ] Worklog actualizado con snapshot + comandos corridos + resultados.

## Convenciones Git

- Rama por repo: `oc/<task>`
- Commits: `oc(<task>): <mensaje>`

## Evidence Pack (formato)

El builder debe entregar:

- `PHASE_SUMMARY` (qué y por qué)
- `COMMANDS_RUN` (comandos exactos)
- `E2E_TRACE` (si aplica)
- `FILES_CHANGED` (paths principales)

El reviewer debe entregar:

- `REVIEW_DECISION` PASS|FAIL
- `REQUIRED_CHANGES` (si FAIL)
- `EVIDENCE` (qué revisó y por qué)
