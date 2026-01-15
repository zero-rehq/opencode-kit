---
description: "Quality gate: lint/format/typecheck/build en repos detectados"
agent: builder
---

Corre el quality gate multi-repo (solo los repos que existan aquí):

1) Detecta por carpeta:
- cloud_tag_back
- cloud_tag_front
- ftp_signed_proxy

2) Por cada repo encontrado:
- `pwd` y `node -v`
- scripts: `node -p "Object.keys(require('./package.json').scripts||{})"`
- corre si existen:
  - `lint`
  - `format:check` o `format`
  - `typecheck`
  - `build`

3) Reporta resultados con exit codes.

Formato final:
### GATE_RESULTS
- repo: ...
  - lint: ok/fail/na
  - format: ok/fail/na
  - typecheck: ok/fail/na
  - build: ok/fail/na

### NOTES
- ...
