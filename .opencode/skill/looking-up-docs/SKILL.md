---
name: looking-up-docs
description: Busca documentación oficial de APIs/libraries (version-specific). Usa Context7 o WebFetch para docs reales, no inventa.
compatibility: opencode
trigger_keywords: ["docs", "documentation", "API reference", "how to use", "library"]
source: SkillsMP - alexei-led looking-up-docs
---

# Looking Up Docs Skill

Busca **documentación oficial** de APIs y libraries externas (version-specific). Evita inventar sintaxis - siempre busca docs reales.

## Cuándo Usar

AUTO-TRIGGER cuando:
- Builder duda de sintaxis de API externa
- User pregunta "how to use [library]"
- Implementando integración con library nueva
- Error sugiere revisar docs (deprecation warning, wrong signature)
- Migrating entre versiones de library

## Features

✅ **Version-specific search**: Busca docs para versión exacta en package.json
✅ **Official sources only**: Prioriza docs oficiales sobre Stack Overflow
✅ **No hallucinations**: No inventa sintaxis - busca o reporta "no encontrado"
✅ **Multiple sources**: Docs oficiales, GitHub README, TypeScript definitions

---

## Supported Libraries

### Frontend Frameworks & Libraries

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **React** | https://react.dev | New docs site (2023+) |
| **Next.js** | https://nextjs.org/docs | Version-specific via /docs/[version] |
| **Vue** | https://vuejs.org/guide/ | Vue 3 default |
| **Svelte** | https://svelte.dev/docs | SvelteKit separate docs |
| **Tailwind CSS** | https://tailwindcss.com/docs | Version-specific via GitHub tags |
| **shadcn/ui** | https://ui.shadcn.com/docs | Component-specific pages |

### State Management

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **Zustand** | https://docs.pmnd.rs/zustand | Simple API, one-page docs |
| **Jotai** | https://jotai.org/docs | Atomic state management |
| **Pinia** | https://pinia.vuejs.org | Vue state management |
| **Redux Toolkit** | https://redux-toolkit.js.org | RTK Query included |

### Data Fetching

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **React Query** | https://tanstack.com/query/latest | TanStack Query v5 |
| **SWR** | https://swr.vercel.app | Vercel's data fetching |
| **tRPC** | https://trpc.io/docs | End-to-end typesafe APIs |

### Form Validation

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **React Hook Form** | https://react-hook-form.com | Performance-focused |
| **Zod** | https://zod.dev | TypeScript-first validation |
| **Yup** | https://github.com/jquense/yup | Schema validation |

### UI Components

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **Radix UI** | https://www.radix-ui.com/primitives/docs | Unstyled primitives |
| **Headless UI** | https://headlessui.com | Tailwind Labs |
| **Chakra UI** | https://chakra-ui.com/docs | Component library |
| **Mantine** | https://mantine.dev | Full-featured UI |

### Backend & APIs

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **Fastify** | https://fastify.dev/docs/latest | Fast Node.js framework |
| **Express** | https://expressjs.com/en/4x/api.html | Classic framework |
| **Hono** | https://hono.dev | Edge-first framework |
| **Prisma** | https://www.prisma.io/docs | ORM for Node.js |

### Testing

| Library | Official Docs URL | Notes |
|---------|------------------|-------|
| **Vitest** | https://vitest.dev | Vite-native testing |
| **Jest** | https://jestjs.io/docs/getting-started | Classic testing framework |
| **Playwright** | https://playwright.dev | E2E testing |
| **Testing Library** | https://testing-library.com | React/Vue/Svelte testing |

---

## Workflow de Búsqueda

### Step 1: Identify Library and Version

Leer `package.json` para obtener versión exacta:

```bash
# Leer versión de library
cat package.json | grep '"react"' | head -1

# Output: "react": "^18.2.0"
```

**Versión**: 18.2.0 → Buscar docs para React 18

### Step 2: Search Official Docs

Usar WebFetch para obtener docs oficiales:

```bash
# Ejemplo: Buscar docs de React useEffect
WebFetch("https://react.dev/reference/react/useEffect",
  "Extract useEffect API signature, parameters, and examples")
```

### Step 3: Parse and Extract

Extraer información relevante:
- **API signature** (function name, params, return type)
- **Parameters** (descripción, tipos, opcionales)
- **Examples** (code snippets)
- **Notes** (deprecation warnings, best practices)

### Step 4: Return Structured Info

Formato de output:

```
📚 Docs Found: React useEffect

API Signature:
  useEffect(setup, dependencies?)

Parameters:
  - setup: () => void | (() => void)
    Effect function. Runs after render.
    Optional cleanup function return.

  - dependencies?: any[]
    Optional array of reactive values.
    Effect re-runs when dependencies change.
    Omit to run every render.

Examples:
  // Basic usage
  useEffect(() => {
    console.log('Component mounted');
  }, []);

  // With cleanup
  useEffect(() => {
    const subscription = api.subscribe();
    return () => subscription.unsubscribe();
  }, []);

  // With dependencies
  useEffect(() => {
    fetchData(userId);
  }, [userId]);

Notes:
  - Runs AFTER paint (non-blocking)
  - Use useLayoutEffect for synchronous DOM reads
  - Empty deps [] = runs once on mount
  - No deps = runs every render

Source: https://react.dev/reference/react/useEffect
Version: React 18
```

---

## Example Queries

### Query 1: Zod Validation Syntax

**Builder pregunta**: "How to use Zod `.refine()` method?"

**Skill ejecuta**:
```bash
WebFetch("https://zod.dev/?id=refine",
  "Extract .refine() method signature and examples")
```

**Output**:
```
📚 Docs Found: Zod .refine()

API Signature:
  schema.refine(validator, params?)

Parameters:
  - validator: (data: T) => boolean
    Validation function. Return true if valid.

  - params?: { message?: string; path?: string[] }
    Optional error message and path

Examples:
  const schema = z.object({
    email: z.string().email()
  }).refine(
    (data) => data.email.includes('@company.com'),
    { message: "Must be company email" }
  );

  // Multiple refinements
  const schema = z.number()
    .refine((n) => n > 0, "Must be positive")
    .refine((n) => n < 100, "Must be less than 100");

Source: https://zod.dev
```

---

### Query 2: React Query Mutation

**Builder pregunta**: "How to use React Query mutation with error handling?"

**Skill ejecuta**:
```bash
WebFetch("https://tanstack.com/query/latest/docs/framework/react/guides/mutations",
  "Extract useMutation API and error handling examples")
```

**Output**:
```
📚 Docs Found: React Query useMutation

API Signature:
  const mutation = useMutation({
    mutationFn: (variables) => Promise,
    onSuccess: (data) => void,
    onError: (error) => void,
    onSettled: (data, error) => void
  })

Examples:
  const mutation = useMutation({
    mutationFn: (newUser) => {
      return axios.post('/users', newUser);
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (error) => {
      console.error('Failed to create user:', error);
    }
  });

  // Trigger mutation
  mutation.mutate({ name: 'John', email: 'john@example.com' });

Error Handling:
  - mutation.isError (boolean)
  - mutation.error (Error object)
  - onError callback
  - error boundaries

Source: https://tanstack.com/query/latest/docs/framework/react/guides/mutations
Version: TanStack Query v5
```

---

### Query 3: Next.js Image Component

**Builder pregunta**: "How to use next/image with priority and sizes?"

**Skill ejecuta**:
```bash
WebFetch("https://nextjs.org/docs/app/api-reference/components/image",
  "Extract Image component props: priority, sizes, fill")
```

**Output**:
```
📚 Docs Found: Next.js Image

API Signature:
  import Image from 'next/image'

  <Image
    src="/photo.jpg"
    alt="Photo"
    width={800}
    height={600}
    priority?
    sizes?
    fill?
  />

Props:
  - priority: boolean
    Preload image (for LCP images above fold)

  - sizes: string
    Media query sizes for responsive images
    Example: "(max-width: 768px) 100vw, 50vw"

  - fill: boolean
    Image fills parent container (no width/height needed)
    Parent must have position: relative

Examples:
  // Hero image (priority)
  <Image
    src="/hero.jpg"
    alt="Hero"
    width={1200}
    height={630}
    priority
  />

  // Responsive with sizes
  <Image
    src="/photo.jpg"
    alt="Photo"
    width={800}
    height={600}
    sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 800px"
  />

  // Fill parent
  <div style={{ position: 'relative', width: '100%', height: '400px' }}>
    <Image
      src="/photo.jpg"
      alt="Photo"
      fill
      style={{ objectFit: 'cover' }}
    />
  </div>

Notes:
  - Use priority for above-fold images (LCP)
  - sizes improves responsive performance
  - fill requires parent with position: relative

Source: https://nextjs.org/docs/app/api-reference/components/image
Version: Next.js 14
```

---

## Integration con Builder

**AUTO-TRIGGER** cuando builder encuentra:

1. **Syntax error** con library externa
2. **Deprecation warning** en console
3. **Type error** con API de library
4. **Builder menciona**: "I'm not sure about [library] syntax"

**Workflow**:
```
Builder: "Need to use Zod for DTO validation, not sure about .refine() syntax"

AUTO-TRIGGER looking-up-docs:
1. Detect library: Zod
2. Read version from package.json: "zod": "^3.22.0"
3. Search: https://zod.dev (buscar .refine())
4. Extract: signature + examples
5. Return: Structured docs

Builder: [Uses docs to implement correctly]
```

---

## Fallback Strategy

Si docs oficiales no encontradas:

### Priority 1: Official Docs
- Library website
- GitHub README
- Official npm package README

### Priority 2: TypeScript Definitions
```bash
# Leer .d.ts files
cat node_modules/zod/lib/index.d.ts | grep -A 10 "refine"
```

### Priority 3: GitHub Examples
```bash
# Search examples in GitHub repo
WebFetch("https://github.com/colinhacks/zod/tree/main/examples",
  "Find examples using .refine() method")
```

### Priority 4: Report Not Found
```
❌ Docs Not Found

Library: [library-name]
Query: [method/feature]

Tried:
- Official docs: [URL] (404 or not found)
- GitHub README: [URL] (no mention)
- TypeScript definitions: (no JSDoc)

Suggestion: Check Stack Overflow or ask user for clarification
```

---

## Best Practices

1. **Always check version** - API changes between versions
2. **Prefer official sources** - More accurate than Stack Overflow
3. **Extract examples** - Code snippets más útiles que descripciones
4. **Check deprecations** - Warn si method está deprecated
5. **Multiple queries OK** - Search múltiples términos si necesario
6. **Cache results** - Docs no cambian frecuentemente (cache 1 day)

---

## Notas

- **Rate limiting**: WebFetch tiene limits, usar sparingly
- **Offline mode**: Si no hay internet, usar TypeScript definitions como fallback
- **Version mismatches**: Warn si docs son para versión diferente
- **Beta APIs**: Flag si API es experimental/beta

---

## Referencias

- **Source**: SkillsMP - alexei-led looking-up-docs
- **Tool**: WebFetch para obtener docs remotas
- **Related**: documentation-sync (para mantener docs internos sincronizados)

---

**Version**: 1.0
**Maintainer**: OpenCode Kit
**Last Updated**: 2026-01-15
