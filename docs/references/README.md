# Referencias incluidas

Esta carpeta contiene los documentos/skills que usamos para construir este kit y que sirven como *fuente de verdad* cuando quieras extenderlo.

## Qué hay aquí

- **CloudAI‑X opencode‑workflow**: guía de workflow multi‑repo con fases.
- **Personal Agent Systems**: patrón de *commands + context + agents*.
- **OpenAgents / Oh‑my‑opencode**: ideas para subagentes y routing/gating.
- **Opencode plugin starter**: skeleton para plugins.
- **Opencode skills example**: estructura estándar de skills.
- **Opencode supermemory**: persistencia/memoria para sesiones largas.
- **skillsmp**: *UI/UX Pro Max* y *Prompt Generator* (como skills reutilizables).

## Cómo lo aplicamos en este kit

- Orchestrator como **router + gatekeeper**, y subagentes `builder/reviewer/scribe`.
- Regla: sin **E2E_TRACE + gates** no se aprueban fases.
- Scripts de evidencia: targets, snapshots, ci y wrap.
- Comandos OpenCode (opencode.json) para que el flujo sea repetible.
