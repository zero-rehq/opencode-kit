# Workflow (Targets + Agentes + Evidencia)

## 1) Targets
Cada tarea define un set de repos “en scope”.

- Archivo: `.opencode/targets/YYYY-MM-DD_<task>.txt`
- Crear: `./.opencode/bin/oc-targets init <task>`
- Auto: `./.opencode/bin/oc-targets auto <task> "<query>"`
- Manual: `./.opencode/bin/oc-targets set <task> repo1 repo2 ...`

## 2) Evidencia (worklog)
- Archivo: `worklog/YYYY-MM-DD_<task>.md`
- `oc-snapshot <task>` agrega *git status* + diffstat por repo target.
- `oc-run-ci <task>` genera `worklog/YYYY-MM-DD_ci_<task>.md`.
- `oc-wrap <task>` agrega snapshot after + últimos commits.

## 3) Gates
El kit corre gates best-effort (solo si existen scripts en package.json):
- lint / typecheck / test / build

Si un repo no es Node, extiende los scripts.

## 4) E2E_TRACE
Si hay cross-repo o cambios de contrato, se exige E2E_TRACE.

Usa `oc-e2e-trace <task>` para insertar una plantilla en el worklog.
