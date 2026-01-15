---
description: "Quality gate: lint/format/typecheck/build en repos targets (dinámico, N repos)"
agent: builder
---

Corre el quality gate multi-repo para los **repos en targets** (no hardcoded).

## Workflow

1) **Detectar targets**:
   - Si existe `.opencode/targets/<task>.txt`: leer repos de ahí (uno por línea)
   - Si NO existe: auto-detectar carpetas con `package.json` en workspace root
   - Skip carpetas: `node_modules`, `.git`, `.opencode`

2) **Por cada repo target**:
   - `cd <repo>`
   - `pwd` y verificar que existe `package.json`
   - Detectar Node version: `node -v` (si aplica)
   - Leer scripts disponibles: `node -p "Object.keys(require('./package.json').scripts||{})"`
   - Correr scripts si existen (en orden):
     * `lint` o `lint:check`
     * `format:check` o `format`
     * `typecheck` o `type-check`
     * `build`
   - Capturar exit codes

3) **Reportar resultados**:

```
### GATE_RESULTS
- repo: <repo_name>
  - lint: ok/fail/na
  - format: ok/fail/na
  - typecheck: ok/fail/na
  - build: ok/fail/na
- repo: <repo_name>
  ...
```

## Flags opcionales

- `--task <name>`: especifica task name para leer `.opencode/targets/<task>.txt`
- `--repos <repo1,repo2>`: override manual de repos (ignora targets file)

## Notas

- Si un script no existe → `na` (not applicable)
- Si un script falla (exit code != 0) → `fail`
- Si un script pasa (exit code == 0) → `ok`
- **Best-effort**: continúa aunque un repo falle
