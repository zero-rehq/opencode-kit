---
description: "Busca usos peligrosos de any (heurístico)"
agent: reviewer
---

Ejecuta búsqueda heurística de `any` en el workspace y reporta agrupado por repo:

- `rg -n "(:\s*any\b|\bas any\b|<any\b)" -S .`

Formato:
### ANY_SCAN
- repo: ...
  - file:line -> snippet
