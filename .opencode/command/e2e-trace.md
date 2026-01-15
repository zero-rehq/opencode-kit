---
description: "Genera un E2E_TRACE antes de implementar (UI -> svc -> integración -> UI)"
agent: builder
---

Antes de tocar código, genera un `E2E_TRACE` del flujo afectado:

Formato:
### E2E_TRACE
- Entry UI:
- Front client/hook:
- Backend endpoint:
- Service/internal call(s):
- External integration (proxy/storage/DB):
- Response shape:
- UI states affected:

Después del trace, NO implementes todavía: espera confirmación del Orchestrator si el scope es ambiguo.
