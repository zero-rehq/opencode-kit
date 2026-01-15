# Review Decision (Reviewer → Orchestrator)

## REVIEW_DECISION
**PASS** | **FAIL**

## REQUIRED_CHANGES
<si FAIL, lista específica con paths exactos y qué hacer>

Ejemplo:
```
1. cloud_front/src/types/Catalogo.ts:8
   - Issue: CatalogoDTO usa `any` para campo imagen
   - Fix: Cambiar `imagen: any` a `imagen?: string`

2. signage_service/src/api/catalogos.ts:45
   - Issue: No validation en POST body
   - Fix: Agregar Zod schema para CatalogoCreateDTO

3. E2E_TRACE incomplete
   - Issue: No menciona qué pasa si API falla (error state)
   - Fix: Agregar error handling en E2E_TRACE
```

## NICE_TO_HAVE
<opcional, mejoras no bloqueantes>

Ejemplo:
```
- Considerar agregar loading skeleton en CatalogosPage
- Agregar tests para useCatalogos hook
- Considerar pagination para lista de catálogos
```

## EVIDENCE
<comandos corridos + observaciones clave del diff>

### Gates Checked
```bash
# Verified all repos pass gates
cloud_front: lint ✅ typecheck ✅ build ✅
signage_service: lint ✅ typecheck ✅ build ✅
```

### E2E_TRACE Validation
```
✅ Entry UI: CatalogosPage exists (line 18)
✅ Hook: useCatalogos exists (hooks/useCatalogos.ts:12)
✅ Client: apiClient.get('/api/catalogos') exists (lib/apiClient.ts:45)
✅ Backend: GET /api/catalogos exists (api/catalogos.ts:12)
✅ Service: catalogosService.list() exists (services/catalogosService.ts:23)
✅ Response: CatalogoDTO[] shape matches
```

### Contract Validation
```
✅ CatalogoDTO: signage_service line 8 matches cloud_front line 5
   - All fields present: id, nombre, imagen
   - Types match: number, string, string | undefined
```

### No-Any Scan
```
✅ Scanned 23 files, 0 new `any` types
```

### Security/Performance Check
```
✅ No obvious security issues (SQL injection, XSS)
✅ No performance red flags (N+1 queries, memory leaks)
```

## SUMMARY
<1-2 oraciones explicando decisión>

Ejemplo PASS:
```
All gates pass, E2E_TRACE is complete and matches the diff, contracts are validated cross-repo, and no `any` types were introduced. Implementation follows existing patterns and is ready to merge.
```

Ejemplo FAIL:
```
Found 3 blocking issues: `any` type in CatalogoDTO, missing validation in POST endpoint, and incomplete E2E_TRACE (missing error handling). Fix required changes before re-review.
```

---
Reviewed by: @reviewer
Date: <timestamp>
