---
name: Prompt Generator (bridge)
description: Puente para usar el Prompt Generator (skillsmp) para generar prompts largos/consistentes para tareas E2E.
compatibility: opencode
---

# Skill (bridge): Prompt Generator

Referencia:
- `docs/references/huangserva-skill-prompt-generator-...txt`

## Para qué sirve aquí
- Generar un **task brief** largo y consistente para el orchestrator.
- Normalizar inputs: objetivos, constraints, repos en scope, contratos, DoD.

## Checklist
- Contexto de negocio
- Alcance multi-repo
- Contratos (API/DTO/events/topics)
- DoD + gates + E2E_TRACE
