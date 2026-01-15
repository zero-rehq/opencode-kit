# OpenCode Multi‑Repo Kit (Definitivo)

Kit para trabajar **E2E en N repos** con OpenCode, usando **agentes + subagentes**, *targets por tarea*, trazabilidad (worklog) y gates (lint/typecheck/build/test) con foco en **E2E_TRACE**.

## Qué trae

- **Targets por tarea**: defines qué repos están “en scope”. Todo lo demás queda fuera.
- **Worklog** por tarea: snapshots (git status + diffstat), comandos corridos y resultados.
- **Gates**: best‑effort por repo (lint/typecheck/test/build si existen scripts).
- **No‑any**: escaneo rápido para evitar `any` en TypeScript.
- **E2E_TRACE**: plantilla y regla de oro para cambios cross‑repo.

## Instalación

1) Descomprime esta carpeta dentro del **workspace root** (donde están todos tus repos).
2) Ejecuta:

```bash
cd opencode-multirepo-kit-definitivo
./install.sh
```

3) Abre OpenCode desde el workspace root:

```bash
cd ..
opencode
```

## Daily flow (el camino feliz)

1) `/bootstrap` (opcional)
   - Genera `AGENTS.md` por repo (útil para que los agentes no pierdan contexto).

2) `/task <nombre>`
   - Crea `targets` + `worklog` + snapshot “before”.

3) Define targets (automático o manual):

```bash
./.opencode/bin/oc-targets auto "<nombre>" "<query>"
# o
./.opencode/bin/oc-targets set "<nombre>" repo1 repo2 repo3
```

4) Implementación (delegada por `@orchestrator` a `@builder`).

5) Gate + E2E:

```bash
./.opencode/bin/oc-gate "<nombre>"
./.opencode/bin/oc-e2e-trace "<nombre>"   # si es cross-repo
```

6) `/wrap <nombre>`
   - Corre CI best‑effort en targets, snapshot “after”, lista commits, y deja evidencia.

## Regla de oro: E2E_TRACE

Si tocas más de 1 repo, o cambias contratos (DTO/API/events/topics), **no se aprueba fase sin E2E_TRACE**.

## Carpeta de referencias

En `docs/references/` va todo el material que hemos ido usando (workflows/skills/plugins) para que el kit sea autosuficiente.
