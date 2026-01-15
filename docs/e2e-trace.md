# E2E_TRACE (plantilla)

Un E2E_TRACE es la prueba **narrada** de que el cambio funciona de punta a punta.

Úsalo cuando:
- 2+ repos están en targets, o
- cambias contratos (API/DTO/events/topics), o
- cambias rutas/proxy/URLs, o
- tocas UI + backend.

## Plantilla (pegar en el worklog)

```md
## E2E_TRACE
- Entry (UI): <pantalla/componente/acción>
- Repo UI: <repo> (archivos clave)
- Request: <METHOD URL> (headers/payload si aplica)
- Backend: <repo servicio> (handler/controller/ruta)
- Data: <db/tabla/cola/tópico> (migraciones si aplica)
- Response: <status + shape>
- UI render: <qué cambia en pantalla>
- Verificación: <comandos corridos + pasos manuales>
```

## Señales de buen trace
- Menciona los *paths* reales cambiados.
- Si cambiaste backend, nombras el endpoint y el consumidor.
- Si cambiaste UI, nombras la pantalla y el request.
