---
name: web-design-guidelines
description: 100+ reglas de UI audit para accessibility, UX y performance
compatibility: opencode
trigger_keywords: ["review UI", "check accessibility", "audit design", "UX", "best practices"]
source: Vercel Labs - Web Interface Guidelines
---

# Web Design Guidelines Skill

Auditoría de código UI contra **100+ reglas** de Web Interface Guidelines (Vercel Labs). Cubre accessibility, performance, UX, dark mode, i18n y más.

## Cuándo Usar

AUTO-TRIGGER cuando:
- "Review my UI"
- "Check accessibility"
- "Audit design"
- "Review UX"
- "Check my site against best practices"
- Files touched: componentes UI, páginas, forms

## Categorías Cubiertas (17 categorías)

### 1. **Accessibility** (10 reglas)
### 2. **Focus States** (4 reglas)
### 3. **Forms** (12 reglas)
### 4. **Animation** (6 reglas)
### 5. **Typography** (6 reglas)
### 6. **Content Handling** (4 reglas)
### 7. **Images** (3 reglas)
### 8. **Performance** (6 reglas)
### 9. **Navigation & State** (4 reglas)
### 10. **Touch & Interaction** (5 reglas)
### 11. **Safe Areas & Layout** (3 reglas)
### 12. **Dark Mode & Theming** (3 reglas)
### 13. **Locale & i18n** (3 reglas)
### 14. **Hydration Safety** (3 reglas)
### 15. **Hover & Interactive States** (2 reglas)
### 16. **Content & Copy** (7 reglas)
### 17. **Anti-patterns** (13 reglas)

**Total**: 100+ reglas

---

## 1. Accessibility (10 reglas)

### Icon buttons require `aria-label`

❌ **Incorrect**:
```tsx
<button onClick={handleClose}>
  <XIcon />
</button>
```

✅ **Correct**:
```tsx
<button onClick={handleClose} aria-label="Close dialog">
  <XIcon />
</button>
```

---

### Form controls need `<label>` or `aria-label`

❌ **Incorrect**:
```tsx
<input type="email" />
```

✅ **Correct**:
```tsx
<label>
  Email
  <input type="email" />
</label>
// OR
<input type="email" aria-label="Email address" />
```

---

### Interactive elements require keyboard handlers

❌ **Incorrect**:
```tsx
<div onClick={handleClick}>Click me</div>
```

✅ **Correct**:
```tsx
<button onClick={handleClick}>Click me</button>
// OR (if div is necessary)
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Click me
</div>
```

---

### Use `<button>` for actions; `<a>`/`<Link>` for navigation

❌ **Incorrect**:
```tsx
<div onClick={() => router.push('/settings')}>Settings</div>
<a onClick={handleSave}>Save</a>
```

✅ **Correct**:
```tsx
<Link href="/settings">Settings</Link>
<button onClick={handleSave}>Save</button>
```

---

### Images need `alt` text

❌ **Incorrect**:
```tsx
<img src="/logo.png" />
```

✅ **Correct**:
```tsx
<img src="/logo.png" alt="Company Logo" />
// Decorative images:
<img src="/decoration.png" alt="" />
```

---

### Decorative icons need `aria-hidden="true"`

✅ **Correct**:
```tsx
<button>
  <CheckIcon aria-hidden="true" />
  Save
</button>
```

---

### Async updates require `aria-live="polite"`

✅ **Correct**:
```tsx
<div role="status" aria-live="polite">
  {message && <p>{message}</p>}
</div>
```

---

### Prioritize semantic HTML over ARIA

❌ **Incorrect**:
```tsx
<div role="button" tabIndex={0} onClick={handleClick}>
  Submit
</div>
```

✅ **Correct**:
```tsx
<button onClick={handleClick}>Submit</button>
```

---

### Hierarchical headings; include skip link

✅ **Correct**:
```tsx
<a href="#main" className="skip-link">Skip to main content</a>

<h1>Page Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>
```

---

### Heading anchors need `scroll-margin-top`

✅ **Correct**:
```css
h2[id], h3[id] {
  scroll-margin-top: 80px; /* Account for sticky header */
}
```

---

## 2. Focus States (4 reglas)

### Interactive elements must have visible focus

❌ **Incorrect**:
```css
button {
  outline: none; /* NEVER do this */
}
```

✅ **Correct**:
```css
button:focus-visible {
  outline: 2px solid blue;
  outline-offset: 2px;
}
/* Tailwind: */
.focus-visible:ring-2.focus-visible:ring-blue-500
```

---

### Prefer `:focus-visible` over `:focus`

✅ **Correct**:
```css
button:focus-visible {
  outline: 2px solid blue;
}
/* Only shows when keyboard navigating, not on mouse click */
```

---

### Compound controls use `:focus-within`

✅ **Correct**:
```css
.search-wrapper:focus-within {
  border-color: blue;
}
```

---

## 3. Forms (12 reglas)

### Inputs need `autocomplete` and meaningful `name`

✅ **Correct**:
```tsx
<input
  type="email"
  name="email"
  autocomplete="email"
/>
<input
  type="password"
  name="current-password"
  autocomplete="current-password"
/>
```

---

### Use semantic `type` attributes

✅ **Correct**:
```tsx
<input type="email" inputmode="email" />
<input type="tel" inputmode="tel" />
<input type="url" inputmode="url" />
<input type="number" inputmode="numeric" />
```

---

### Never block paste functionality

❌ **Incorrect**:
```tsx
<input type="password" onPaste={(e) => e.preventDefault()} />
```

✅ **Correct**:
```tsx
<input type="password" />
```

---

### Labels must be clickable

❌ **Incorrect**:
```tsx
<label>Email</label>
<input id="email" type="email" />
```

✅ **Correct**:
```tsx
<label htmlFor="email">Email</label>
<input id="email" type="email" />
// OR
<label>
  Email
  <input type="email" />
</label>
```

---

### Disable spellcheck on emails/codes/usernames

✅ **Correct**:
```tsx
<input type="email" spellcheck="false" autocorrect="off" />
<input type="text" name="code" spellcheck="false" />
```

---

### Checkboxes/radios: single unified hit target

✅ **Correct**:
```tsx
<label className="flex items-center gap-2 cursor-pointer p-2">
  <input type="checkbox" />
  <span>Accept terms</span>
</label>
```

---

### Submit button enabled until request; show spinner during request

❌ **Incorrect**:
```tsx
<button disabled={isLoading}>
  {isLoading ? 'Submitting...' : 'Submit'}
</button>
```

✅ **Correct**:
```tsx
<button type="submit">
  {isLoading ? (
    <>
      <Spinner />
      Submitting…
    </>
  ) : (
    'Submit'
  )}
</button>
```

---

### Inline error messages; focus first error on submit

✅ **Correct**:
```tsx
{errors.email && (
  <p className="text-red-500 text-sm" role="alert">
    {errors.email}
  </p>
)}

// On submit:
const firstErrorField = document.querySelector('[aria-invalid="true"]');
firstErrorField?.focus();
```

---

### Placeholders end with `…` and show patterns

✅ **Correct**:
```tsx
<input
  type="email"
  placeholder="name@example.com"
/>
<input
  type="tel"
  placeholder="(555) 123-4567"
/>
```

---

### Non-auth fields use `autocomplete="off"`

✅ **Correct**:
```tsx
<input
  type="text"
  name="search"
  autocomplete="off"
/>
```

---

### Warn before navigation with unsaved changes

✅ **Correct**:
```tsx
useEffect(() => {
  const handler = (e: BeforeUnloadEvent) => {
    if (hasUnsavedChanges) {
      e.preventDefault();
      e.returnValue = '';
    }
  };
  window.addEventListener('beforeunload', handler);
  return () => window.removeEventListener('beforeunload', handler);
}, [hasUnsavedChanges]);
```

---

## 4. Animation (6 reglas)

### Honor `prefers-reduced-motion`

✅ **Correct**:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

### Animate only `transform`/`opacity`

❌ **Incorrect**:
```css
.slide {
  transition: left 300ms; /* Causes reflow */
}
```

✅ **Correct**:
```css
.slide {
  transition: transform 300ms;
  transform: translateX(100%);
}
```

---

### Avoid "transition: all"

❌ **Incorrect**:
```css
button {
  transition: all 200ms;
}
```

✅ **Correct**:
```css
button {
  transition: background-color 200ms, transform 200ms;
}
```

---

### Set correct `transform-origin`

✅ **Correct**:
```css
.menu {
  transform-origin: top right;
  animation: slideDown 200ms;
}
```

---

### SVG transforms on `<g>` wrapper

✅ **Correct**:
```tsx
<svg>
  <g className="animate-spin" style={{ transformBox: 'fill-box', transformOrigin: 'center' }}>
    <circle cx="50" cy="50" r="40" />
  </g>
</svg>
```

---

### Animations must be interruptible

✅ **Correct**:
```tsx
const [isAnimating, setIsAnimating] = useState(false);

const handleClick = () => {
  setIsAnimating(false); // Stop current animation
  setTimeout(() => setIsAnimating(true), 10);
};
```

---

## 5. Typography (6 reglas)

### Use ellipsis `…` not `...`

❌ **Incorrect**: `"Loading..."`
✅ **Correct**: `"Loading…"`

---

### Curly quotes `"` `"` not straight quotes

❌ **Incorrect**: `"Hello World"`
✅ **Correct**: `"Hello World"`

---

### Non-breaking spaces

✅ **Correct**:
```tsx
<p>10&nbsp;MB</p>
<p>⌘&nbsp;K</p>
<p>Next.js&nbsp;15</p>
```

---

### Loading states

✅ **Correct**:
```tsx
{isLoading ? "Loading…" : "Load More"}
{isSaving ? "Saving…" : "Save"}
```

---

### Number columns: `tabular-nums`

✅ **Correct**:
```css
.stats-column {
  font-variant-numeric: tabular-nums;
}
```

---

### Headings: `text-wrap`

✅ **Correct**:
```css
h1, h2, h3 {
  text-wrap: balance;
}

p {
  text-wrap: pretty;
}
```

---

## 6. Content Handling (4 reglas)

### Text containers: truncate or line-clamp

✅ **Correct**:
```tsx
{/* Tailwind: */}
<p className="truncate">Long text here</p>
<p className="line-clamp-3">Multiline text here</p>
<p className="break-words">VeryLongWordWithNoSpaces</p>
```

---

### Flex children need `min-w-0` for truncation

❌ **Incorrect**:
```tsx
<div className="flex">
  <p className="truncate">Long text</p>
</div>
```

✅ **Correct**:
```tsx
<div className="flex">
  <p className="truncate min-w-0">Long text</p>
</div>
```

---

### Handle empty states explicitly

✅ **Correct**:
```tsx
{items.length > 0 ? (
  items.map(item => <Item key={item.id} {...item} />)
) : (
  <EmptyState />
)}
```

---

### Anticipate short, average, very long user inputs

Test con:
- Corto: "A"
- Promedio: "John Smith"
- Largo: "Jean-Baptiste Emmanuel Zorg III"

---

## 7. Images (3 reglas)

### `<img>` needs explicit `width` and `height`

❌ **Incorrect**:
```tsx
<img src="/photo.jpg" alt="Photo" />
```

✅ **Correct**:
```tsx
<img src="/photo.jpg" alt="Photo" width={800} height={600} />
{/* Next.js Image: */}
<Image src="/photo.jpg" alt="Photo" width={800} height={600} />
```

---

### Below-fold images: `loading="lazy"`

✅ **Correct**:
```tsx
<img src="/below-fold.jpg" alt="..." loading="lazy" width={800} height={600} />
```

---

### Critical above-fold images: `priority`

✅ **Correct**:
```tsx
<Image src="/hero.jpg" alt="Hero" priority width={1200} height={630} />
{/* OR native: */}
<img src="/hero.jpg" alt="Hero" fetchpriority="high" width={1200} height={630} />
```

---

## 8. Performance (6 reglas)

### Lists >50 items: virtualize

✅ **Correct**:
```tsx
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={600}
  itemCount={items.length}
  itemSize={50}
  width="100%"
>
  {({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  )}
</FixedSizeList>
```

---

### No layout reads in render

❌ **Incorrect**:
```tsx
function Component() {
  const width = element.offsetWidth; // Layout read in render
  return <div style={{ width: width * 2 }} />;
}
```

✅ **Correct**:
```tsx
function Component() {
  const [width, setWidth] = useState(0);

  useEffect(() => {
    setWidth(element.offsetWidth);
  }, []);

  return <div style={{ width: width * 2 }} />;
}
```

---

### Batch DOM operations

❌ **Incorrect**:
```tsx
items.forEach(item => {
  const el = document.createElement('div');
  el.textContent = item.name;
  container.appendChild(el); // DOM write per item
});
```

✅ **Correct**:
```tsx
const fragment = document.createDocumentFragment();
items.forEach(item => {
  const el = document.createElement('div');
  el.textContent = item.name;
  fragment.appendChild(el);
});
container.appendChild(fragment); // Single DOM write
```

---

### Prefer uncontrolled inputs

❌ **Incorrect (if not needed)**:
```tsx
const [value, setValue] = useState('');
<input value={value} onChange={e => setValue(e.target.value)} />
```

✅ **Correct**:
```tsx
<input defaultValue="" />
// Access via ref when needed
```

---

### Add `<link rel="preconnect">` for CDNs

✅ **Correct**:
```tsx
<link rel="preconnect" href="https://cdn.example.com" />
<link rel="dns-prefetch" href="https://cdn.example.com" />
```

---

### Critical fonts: `<link rel="preload">`

✅ **Correct**:
```tsx
<link
  rel="preload"
  as="font"
  href="/fonts/inter.woff2"
  type="font/woff2"
  crossOrigin="anonymous"
/>
<style>
  @font-face {
    font-family: 'Inter';
    src: url('/fonts/inter.woff2') format('woff2');
    font-display: swap;
  }
</style>
```

---

## 9. Navigation & State (4 reglas)

### URL reflects state

✅ **Correct**:
```tsx
// Filters, tabs, pagination in URL
const [tab, setTab] = useQueryState('tab', { defaultValue: 'overview' });
const [page, setPage] = useQueryState('page', { defaultValue: 1 });
```

---

### Use `<a>`/`<Link>` for navigation

❌ **Incorrect**:
```tsx
<button onClick={() => router.push('/settings')}>Settings</button>
```

✅ **Correct**:
```tsx
<Link href="/settings">Settings</Link>
```

---

### Deep-link stateful UI

✅ **Correct**:
```tsx
// Modal state in URL
const [isOpen, setIsOpen] = useQueryState('modal', { defaultValue: false });
```

---

### Destructive actions need confirmation/undo

✅ **Correct**:
```tsx
const handleDelete = () => {
  if (confirm('Are you sure you want to delete this item?')) {
    deleteItem();
  }
};
// OR undo:
const handleDelete = () => {
  deleteItem();
  toast.success('Deleted', {
    action: {
      label: 'Undo',
      onClick: () => restoreItem()
    }
  });
};
```

---

## 10. Touch & Interaction (5 reglas)

### `touch-action: manipulation`

✅ **Correct**:
```css
button, a, [role="button"] {
  touch-action: manipulation; /* Removes 300ms tap delay */
}
```

---

### Set `-webkit-tap-highlight-color`

✅ **Correct**:
```css
* {
  -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
}
```

---

### Modals/drawers: `overscroll-behavior: contain`

✅ **Correct**:
```css
.modal {
  overscroll-behavior: contain;
}
```

---

### Disable text selection during drag

✅ **Correct**:
```css
.draggable {
  user-select: none;
}
```

---

### `autoFocus` sparingly (desktop only)

✅ **Correct**:
```tsx
<input autoFocus={!isMobile} />
```

---

## 11. Safe Areas & Layout (3 reglas)

### Full-bleed layouts: `env(safe-area-inset-*)`

✅ **Correct**:
```css
.full-bleed {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
  padding-bottom: env(safe-area-inset-bottom);
}
```

---

### Prevent unwanted scrollbars

✅ **Correct**:
```css
body {
  overflow-x: hidden;
}
```

---

### Prefer Flex/Grid over JS measurement

❌ **Incorrect**:
```tsx
const [height, setHeight] = useState(0);
useEffect(() => {
  setHeight(window.innerHeight - headerHeight);
}, []);
```

✅ **Correct**:
```css
.container {
  display: grid;
  grid-template-rows: auto 1fr auto;
  height: 100vh;
}
```

---

## 12. Dark Mode & Theming (3 reglas)

### "color-scheme: dark" on `<html>`

✅ **Correct**:
```html
<html style="color-scheme: dark">
```
```css
:root {
  color-scheme: light dark;
}
```

---

### `<meta name="theme-color">` matches background

✅ **Correct**:
```tsx
<meta name="theme-color" content="#000000" media="(prefers-color-scheme: dark)" />
<meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
```

---

### Native `<select>`: explicit colors

✅ **Correct**:
```css
select {
  background-color: white;
  color: black;
}

@media (prefers-color-scheme: dark) {
  select {
    background-color: #1a1a1a;
    color: white;
  }
}
```

---

## 13. Locale & i18n (3 reglas)

### Dates/times: `Intl.DateTimeFormat`

❌ **Incorrect**:
```tsx
const formatted = new Date().toLocaleDateString(); // Uses user's locale
```

✅ **Correct**:
```tsx
const formatted = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
}).format(new Date());
```

---

### Numbers/currency: `Intl.NumberFormat`

✅ **Correct**:
```tsx
const price = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
}).format(1234.56);
// "$1,234.56"
```

---

### Detect language via headers, not IP

✅ **Correct**:
```tsx
// Server-side
const locale = request.headers.get('accept-language')?.split(',')[0] || 'en';
```

---

## 14. Hydration Safety (3 reglas)

### Inputs with `value` need `onChange`

❌ **Incorrect**:
```tsx
<input value={value} />
```

✅ **Correct**:
```tsx
<input value={value} onChange={e => setValue(e.target.value)} />
// OR uncontrolled:
<input defaultValue={value} />
```

---

### Guard date/time rendering against mismatches

✅ **Correct**:
```tsx
const [mounted, setMounted] = useState(false);

useEffect(() => {
  setMounted(true);
}, []);

if (!mounted) return <span>--:--</span>;

return <span>{new Date().toLocaleTimeString()}</span>;
```

---

### Use `suppressHydrationWarning` sparingly

✅ **Correct**:
```tsx
<time suppressHydrationWarning>
  {new Date().toISOString()}
</time>
```

---

## 15. Hover & Interactive States (2 reglas)

### Buttons/links need `hover:` states

✅ **Correct**:
```css
button {
  background: blue;
  transition: background 200ms;
}

button:hover {
  background: darkblue;
}
```

---

### Interactive states increase contrast

✅ **Correct**:
```css
a {
  color: #0066cc;
}

a:hover {
  color: #004499; /* Darker for higher contrast */
}
```

---

## 16. Content & Copy (7 reglas)

### Active voice preferred

❌ **Incorrect**: "Your file was uploaded"
✅ **Correct**: "File uploaded"

---

### Title Case for headings/buttons

✅ **Correct**: "Sign Up", "Learn More", "Get Started"

---

### Numerals for counts

✅ **Correct**: "3 items", "15 messages", "1 notification"

---

### Specific button labels

❌ **Incorrect**: "OK", "Submit", "Yes"
✅ **Correct**: "Save Changes", "Delete Account", "Confirm Purchase"

---

### Error messages include solutions

❌ **Incorrect**: "Invalid email"
✅ **Correct**: "Invalid email. Please use format: name@example.com"

---

### Second person (avoid first person)

❌ **Incorrect**: "We couldn't find your account"
✅ **Correct**: "Account not found. Please check your email address."

---

### `&` over "and" when space-constrained

✅ **Correct**: "Terms & Conditions", "Privacy & Security"

---

## 17. Anti-patterns (13 reglas)

### ❌ Zoom-disabling viewport settings

```html
<!-- NEVER do this -->
<meta name="viewport" content="width=device-width, user-scalable=no">
```

### ❌ Paste-blocking code

```tsx
// NEVER do this
<input onPaste={e => e.preventDefault()} />
```

### ❌ "transition: all"

```css
/* NEVER do this */
button { transition: all 200ms; }
```

### ❌ "outline-none" without replacement

```css
/* NEVER do this */
button { outline: none; }
```

### ❌ Inline `onClick` navigation

```tsx
// NEVER do this
<div onClick={() => router.push('/page')}>Go</div>
```

### ❌ `<div>`/`<span>` as buttons

```tsx
// NEVER do this
<div onClick={handleClick}>Click me</div>
```

### ❌ Images without dimensions

```tsx
// NEVER do this
<img src="/photo.jpg" alt="Photo" />
```

### ❌ Unvirtualized large arrays

```tsx
// NEVER do this for >50 items
{items.map(item => <Item key={item.id} {...item} />)}
```

### ❌ Unlabeled form inputs

```tsx
// NEVER do this
<input type="email" />
```

### ❌ Icon buttons without aria-label

```tsx
// NEVER do this
<button><XIcon /></button>
```

### ❌ Hardcoded dates/numbers

```tsx
// NEVER do this
const price = `$${amount.toFixed(2)}`;
// Use Intl.NumberFormat instead
```

### ❌ Unjustified `autoFocus`

```tsx
// NEVER do this on mobile
<input autoFocus />
```

### ❌ Layout reads in render

```tsx
// NEVER do this
function Component() {
  const width = element.offsetWidth; // Causes layout thrashing
  return <div />;
}
```

---

## Workflow de Uso

### 1. Auditoría Manual

Builder o Reviewer valida código contra checklist:

**CRITICAL**:
- [ ] Icon buttons tienen aria-label
- [ ] Form inputs tienen labels
- [ ] Interactive elements son `<button>` o `<a>`
- [ ] Images tienen alt text
- [ ] Focus states visibles

**HIGH**:
- [ ] Autocomplete en inputs
- [ ] prefers-reduced-motion respetado
- [ ] Curly quotes usadas
- [ ] Images tienen width/height
- [ ] Lists >50 items virtualizadas

**MEDIUM**:
- [ ] URL refleja state
- [ ] Dark mode color-scheme
- [ ] Intl para dates/numbers

### 2. Auto-Audit (WebFetch)

Para auditoría automática con reglas latest:

```tsx
// Fetch latest guidelines
const guidelines = await fetch('https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md');

// Apply rules to files
const results = await auditFiles(files, guidelines);

// Output findings
results.forEach(finding => {
  console.log(`${finding.file}:${finding.line} - ${finding.rule}`);
});
```

### 3. Integration con Reviewer

**AUTO-TRIGGER** durante review phase:
1. Leer files touched (*.tsx, *.jsx)
2. Aplicar reglas por categoría (Accessibility primero)
3. Reportar findings en formato `file:line - rule`

**Output esperado**:
```
✅ Web design audit complete

ACCESSIBILITY issues (3):
- Button.tsx:15 - Icon button missing aria-label
- Form.tsx:42 - Input missing label
- Modal.tsx:8 - Interactive div should be <button>

PERFORMANCE issues (1):
- List.tsx:120 - Large array not virtualized (200 items)

Suggested fixes:
[Fixes con code snippets]
```

---

## Guidelines Source (Latest)

Para obtener las reglas más recientes, usar WebFetch:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

Las reglas se actualizan frecuentemente. Este skill documenta las 100+ reglas core, pero siempre verificar source para últimas actualizaciones.

---

## Referencias

- **Source**: Vercel Labs - Web Interface Guidelines
- **Repo**: https://github.com/vercel-labs/web-interface-guidelines
- **Docs**: https://vercel.com/docs/concepts/best-practices
- **WCAG**: https://www.w3.org/WAI/WCAG21/quickref/

---

**Version**: 1.0
**Maintainer**: Vercel Labs
**Last Updated**: 2026-01-15
**Total Rules**: 100+
