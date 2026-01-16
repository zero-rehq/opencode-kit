#!/bin/bash

# analyze-ssr.sh - Analyze Next.js project for SSR optimization opportunities
# Usage: ./analyze-ssr.sh [project-path]
# Output: SSR optimization report with recommendations

set -e

PROJECT_PATH="${1:-.}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Next.js SSR Optimization Analysis"
echo "=========================================="
echo "Project: $PROJECT_PATH"
echo ""

# Check if this is a Next.js project
if [ ! -f "$PROJECT_PATH/package.json" ]; then
    echo -e "${RED}ERROR:${NC} package.json not found"
    exit 1
fi

if ! grep -q '"next"' "$PROJECT_PATH/package.json"; then
    echo -e "${RED}ERROR:${NC} Next.js not found in dependencies"
    exit 1
fi

echo -e "${GREEN}✓${NC} Next.js project detected"
echo ""

# Check for common SSR patterns
echo "Checking SSR patterns..."

# 1. Server Components vs Client Components
echo -e "\n${YELLOW}1. Server vs Client Components:${NC}"
server_components=$(find "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" -name "*.tsx" -o -name "*.ts" 2>/dev/null | wc -l)
client_components=$(grep -r "'use client'" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)

echo "  Server components: $server_components"
echo "  Client components: $client_components"

if [ $client_components -gt $((server_components / 2)) ]; then
    echo -e "  ${YELLOW}WARNING:${NC} High ratio of client components - consider using Server Components where possible"
fi

# 2. Check for Suspense boundaries
echo -e "\n${YELLOW}2. Suspense Boundaries:${NC}"
suspense_count=$(grep -r "Suspense" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | grep -c "from 'react'" || echo 0)
echo "  Suspense boundaries: $suspense_count"

if [ $suspense_count -eq 0 ]; then
    echo -e "  ${YELLOW}WARNING:${NC} No Suspense boundaries found - consider adding for slow data fetching"
fi

# 3. Check for async/await patterns
echo -e "\n${YELLOW}3. Async/Await Patterns:${NC}"
async_server_components=$(grep -r "export default async function" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  Async server components: $async_server_components"

if [ $async_server_components -eq 0 ]; then
    echo -e "  ${YELLOW}WARNING:${NC} No async server components found - consider using async data fetching"
fi

# 4. Check for React.cache
echo -e "\n${YELLOW}4. React.cache Usage:${NC}"
react_cache_count=$(grep -r "React.cache\|react/cache" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  React.cache usage: $react_cache_count"

if [ $react_cache_count -eq 0 ]; then
    echo -e "  ${YELLOW}WARNING:${NC} React.cache not found - consider using for duplicate server fetches"
fi

# 5. Check for parallel data fetching
echo -e "\n${YELLOW}5. Parallel Data Fetching (Promise.all):${NC}"
promise_all_count=$(grep -r "Promise.all" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  Promise.all usage: $promise_all_count"

# 6. Check for client-side data fetching (potential waterfalls)
echo -e "\n${YELLOW}6. Client-Side Data Fetching (Potential Waterfalls):${NC}"
use_effect_fetch=$(grep -r "useEffect.*fetch\|useEffect.*axios\|useEffect.*get" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  useEffect fetch patterns: $use_effect_fetch"

if [ $use_effect_fetch -gt 5 ]; then
    echo -e "  ${YELLOW}WARNING:${NC} High number of client-side fetches - consider moving to server-side"
fi

# 7. Check for generateStaticParams
echo -e "\n${YELLOW}7. Static Generation (generateStaticParams):${NC}"
generate_static=$(grep -r "generateStaticParams" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  generateStaticParams usage: $generate_static"

# 8. Check for ISR (revalidate)
echo -e "\n${YELLOW}8. ISR (revalidate):${NC}"
revalidate_count=$(grep -r "revalidate" "$PROJECT_PATH/app" "$PROJECT_PATH/src/app" 2>/dev/null | wc -l)
echo "  Revalidate usage: $revalidate_count"

echo ""
echo "=========================================="
echo "Recommendations"
echo "=========================================="
echo ""

if [ $client_components -gt $((server_components / 2)) ]; then
    echo "• Reduce Client Components - use Server Components by default"
    echo "  - Remove unnecessary 'use client' directives"
    echo "  - Move stateful logic to Client Components only"
fi

if [ $suspense_count -eq 0 ]; then
    echo "• Add Suspense boundaries for slow data fetching"
    echo "  - Wrap slow components with <Suspense fallback={...}>"
fi

if [ $react_cache_count -eq 0 ]; then
    echo "• Use React.cache() for duplicate server fetches"
    echo "  - Wrap fetch functions with React.cache() to avoid duplicate requests"
fi

if [ $promise_all_count -eq 0 ]; then
    echo "• Use Promise.all() for parallel data fetching"
    echo "  - Avoid sequential awaits that cause waterfalls"
fi

if [ $use_effect_fetch -gt 5 ]; then
    echo "• Move data fetching from useEffect to server"
    echo "  - Use async server components instead of client fetching"
fi

echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Review the recommendations above"
echo "2. Run './checklist-ssr.sh' to see optimization checklist"
echo "3. Implement high-priority optimizations first"
echo "4. Re-run this script to measure improvements"
