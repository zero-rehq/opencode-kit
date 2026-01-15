# E2E_TRACE (plantilla)

Un E2E_TRACE es el hilo completo **UI → servicio → integración → UI**.

## Plantilla

- **Entry UI**: pantalla/componente y acción del usuario
- **Repo front**: archivo(s) clave
- **API call**: método, ruta, headers, payload
- **Repo backend**: handler, servicio, validaciones
- **Persistencia**: tablas/queries/migraciones (si aplica)
- **Respuesta**: DTO / shape / status codes
- **Render UI**: cómo se refleja el cambio
- **Prueba manual**: pasos reproducibles
- **Riesgos**: cache, auth, flags, compat

## Regla
Si el diff no respalda el trace, el reviewer debe poner FAIL.
