---
name: API Documentation Generator
description: Genera documentación de API OpenAPI/Swagger desde código (TypeScript, Express, Next.js).
compatibility: opencode
---

# Skill: API Documentation Generator

**Status**: Template para nuevo skill (detectado por skills-router-agent como gap)

## Para qué sirve
- Generar documentación OpenAPI 3.0 desde código
- Sincronizar documentación con implementación
- Detectar endpoints no documentados
- Validar contratos cross-repo (DTOs, request/response shapes)
- Generar clientes API tipados desde OpenAPI spec

## Casos de uso
- Endpoints sin documentación
- Drift entre README y código
- Documentación desactualizada
- Contratos inconsistentes entre repos
- Necesidad de generar clientes tipados

## Características principales
1. **Auto-generation**: Parsea código y genera OpenAPI spec
2. **Validation**: Valida que todos los endpoints estén documentados
3. **Type safety**: Genera TypeScript types para DTOs
4. **Client generation**: Crea API clients tipados
5. **Drift detection**: Reporta discrepancias entre docs y código
6. **Integration**: Funciona con Express, Next.js, Fastify, etc.

## Soporte de frameworks
- **Express**: `@decorators`, JSDoc, Swagger UI
- **Next.js**: Route handlers (`export async function GET()`)
- **Fastify**: `fastify-swagger`
- **NestJS**: `@ApiTags`, `@ApiOperation`, DTO decorators
- **tRPC**: Auto-generated docs

## Workflow de uso

```bash
# 1. Generar OpenAPI spec desde código
pnpm api-docs:generate

# 2. Validar que todos los endpoints estén documentados
pnpm api-docs:validate

# 3. Detectar drift entre docs y código
pnpm api-docs:drift

# 4. Generar cliente tipado
pnpm api-docs:client
```

## Ejemplo de implementación (Express)

```typescript
// ❌ SIN: Endpoint sin documentación
app.get('/api/catalogos', async (req, res) => {
  const catalogos = await catalogosService.list();
  res.json(catalogos);
});

// ✅ CON: Documentación con JSDoc
/**
 * @openapi
 * /api/catalogos:
 *   get:
 *     summary: Listar catálogos
 *     tags: [Catalogos]
 *     responses:
 *       200:
 *         description: Lista de catálogos
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/CatalogoDTO'
 */
app.get('/api/catalogos', async (req, res) => {
  const catalogos = await catalogosService.list();
  res.json(catalogos);
});

// ✅ MEJOR: Con DTOs tipados y decorators
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

@ApiTags('Catalogos')
@Controller('catalogos')
export class CatalogosController {
  @Get()
  @ApiOperation({ summary: 'Listar catálogos' })
  @ApiResponse({ type: CatalogoDTO, isArray: true })
  async list() {
    return this.catalogosService.list();
  }
}
```

## Integración con documentation-sync
- documentation-sync detecta drift a nivel de README
- api-documentation-generator detecta drift a nivel de endpoints/DTOs
- Complementarios: uno valida docs humanas, otro valida specs técnicas

## Checklist de validación
- [ ] Todos los endpoints tienen @openapi JSDoc o decorators
- [ ] Todos los DTOs están tipados (TypeScript interfaces)
- [ ] Response schemas están definidos
- [ ] Query params y request bodies documentados
- [ ] Códigos de error documentados (4xx, 5xx)
- [ ] OpenAPI spec generado y actualizado
- [ ] No drift entre docs y código
- [ ] Cliente tipado generado (si aplica)

## Output esperado

### openapi.json (generated)
```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Signage Service API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/catalogos": {
      "get": {
        "summary": "Listar catálogos",
        "tags": ["Catalogos"],
        "responses": {
          "200": {
            "description": "Lista de catálogos",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": { "$ref": "#/components/schemas/CatalogoDTO" }
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "CatalogoDTO": {
        "type": "object",
        "properties": {
          "id": { "type": "number" },
          "nombre": { "type": "string" },
          "imagen": { "type": "string" }
        }
      }
    }
  }
}
```

### Drift Report
```markdown
## API Documentation Drift Report

### Missing Documentation
- POST /api/catalogos (line 45): No JSDoc or decorators found
- PUT /api/catalogos/:id (line 67): No JSDoc or decorators found

### Outdated Documentation
- GET /api/catalogos (line 12): OpenAPI doc says response is CatalogoDTO[], but code returns object

### Inconsistent DTOs
- CatalogoDTO in code: { id, nombre, imagen, activo }
- CatalogoDTO in OpenAPI: { id, nombre, imagen }
- Missing field: activo
```

## Scripts necesarios
1. `scripts/generate-openapi.ts` - Parse code and generate OpenAPI spec
2. `scripts/validate-openapi.ts` - Validate all endpoints documented
3. `scripts/detect-drift.ts` - Compare docs vs code
4. `scripts/generate-client.ts` - Generate typed API client

## Implementación pendiente
- Scripts de análisis de código
- Integración con Express/Next.js parsers
- Validación de contratos cross-repo
- Generación de clientes tipados
- Workflow de actualización automática

---
Generated as gap template from skills-router-agent
