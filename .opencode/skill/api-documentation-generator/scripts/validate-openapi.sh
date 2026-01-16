#!/bin/bash

# validate-openapi.sh - Validate OpenAPI spec and check for drift
# Usage: ./validate-openapi.sh [openapi.json]
# Output: Validation report with missing endpoints and drift

set -e

OPENAPI_FILE="${1:-openapi.json}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "OpenAPI Validation & Drift Detection"
echo "=========================================="
echo "File: $OPENAPI_FILE"
echo ""

# Check if OpenAPI file exists
if [ ! -f "$OPENAPI_FILE" ]; then
    echo -e "${RED}ERROR:${NC} OpenAPI file not found: $OPENAPI_FILE"
    echo ""
    echo "Generate it first:"
    echo "  npm run api-docs:generate"
    exit 1
fi

# Validate JSON structure
if ! jq empty "$OPENAPI_FILE" 2>/dev/null; then
    echo -e "${RED}ERROR:${NC} Invalid JSON in OpenAPI file"
    exit 1
fi

echo -e "${GREEN}✓${NC} Valid JSON structure"
echo ""

# Check required OpenAPI fields
echo "Checking required OpenAPI fields..."

openapi_version=$(jq -r '.openapi // .swagger' "$OPENAPI_FILE")
if [ -n "$openapi_version" ]; then
    echo -e "${GREEN}✓${NC} OpenAPI version: $openapi_version"
else
    echo -e "${RED}ERROR:${NC} Missing openapi/swagger version"
fi

api_title=$(jq -r '.info.title' "$OPENAPI_FILE")
if [ -n "$api_title" ]; then
    echo -e "${GREEN}✓${NC} API title: $api_title"
else
    echo -e "${RED}ERROR:${NC} Missing info.title"
fi

paths_count=$(jq '.paths | length' "$OPENAPI_FILE")
echo -e "${GREEN}✓${NC} Paths documented: $paths_count"

if [ "$paths_count" -eq 0 ]; then
    echo -e "${YELLOW}WARNING:${NC} No paths documented in OpenAPI spec"
fi

echo ""

# Check for common documentation issues
echo "Checking for documentation issues..."

# 1. Check for paths without descriptions
no_desc_paths=$(jq '.paths | to_entries[] | select(.value | type == "object") | select(.value.description == null) | .key' "$OPENAPI_FILE" | wc -l)
if [ "$no_desc_paths" -gt 0 ]; then
    echo -e "${YELLOW}WARNING:${NC} $no_desc_paths paths missing description"
fi

# 2. Check for responses without schemas
no_schema_responses=$(jq '[.paths[][] | .responses[]? | select(.content?."application/json".schema == null)] | length' "$OPENAPI_FILE")
if [ "$no_schema_responses" -gt 0 ]; then
    echo -e "${YELLOW}WARNING:${NC} $no_schema_responses responses missing schemas"
fi

# 3. Check for missing tags
no_tags=$(jq '[.paths[][] | select(.tags == null)] | length' "$OPENAPI_FILE")
if [ "$no_tags" -gt 0 ]; then
    echo -e "${YELLOW}WARNING:${NC} $no_tags operations missing tags"
fi

# 4. Check for missing operation IDs
no_op_ids=$(jq '[.paths[][] | select(.operationId == null)] | length' "$OPENAPI_FILE")
if [ "$no_op_ids" -gt 0 ]; then
    echo -e "${YELLOW}WARNING:${NC} $no_op_ids operations missing operationId"
fi

echo ""
echo "=========================================="
echo "Drift Detection"
echo "=========================================="
echo ""
echo "Checking for drift between code and documentation..."

# Framework-specific drift detection
if [ -f "package.json" ]; then
    # Check if Express
    if grep -q '"express"' package.json; then
        echo "Express project detected"
        echo ""
        echo "Scanning for undocumented endpoints..."

        # Find all Express route definitions
        undocumented_count=0

        # app.get, app.post, etc.
        for method in get post put delete patch; do
            # Count route definitions without JSDoc
            count=$(grep -r "app\.$method\|router\.$method" --include="*.ts" --include="*.js" . 2>/dev/null | \
                    grep -v "//" | \
                    grep -v "\*\s*$method" | \
                    grep -v "@openapi" | \
                    wc -l)

            if [ "$count" -gt 0 ]; then
                echo -e "  ${YELLOW}WARNING:${NC} $count $method() calls without @openapi JSDoc"
                undocumented_count=$((undocumented_count + count))
            fi
        done

        if [ "$undocumented_count" -eq 0 ]; then
            echo -e "${GREEN}✓${NC} All Express routes appear documented"
        else
            echo ""
            echo -e "${RED}Total undocumented endpoints: $undocumented_count${NC}"
        fi
    fi

    # Check if NestJS
    if grep -q '"@nestjs/core"' package.json; then
        echo "NestJS project detected"
        echo ""
        echo "Scanning for undocumented endpoints..."

        # Find controllers without decorators
        undocumented_controllers=$(grep -r "@Controller" --include="*.ts" . 2>/dev/null | wc -l)
        documented_controllers=$(grep -r "@ApiOperation" --include="*.ts" . 2>/dev/null | wc -l)

        if [ "$documented_controllers" -lt "$undocumented_controllers" ]; then
            echo -e "${YELLOW}WARNING:${NC} Some controller methods may be missing @ApiOperation decorator"
        else
            echo -e "${GREEN}✓${NC} Controllers appear to have operation decorators"
        fi
    fi
fi

echo ""
echo "=========================================="
echo "Recommendations"
echo "=========================================="
echo ""

if [ "$paths_count" -eq 0 ]; then
    echo "• Generate OpenAPI spec: npm run api-docs:generate"
    echo "• Add @openapi JSDoc annotations to all endpoints"
fi

if [ "$no_schema_responses" -gt 0 ]; then
    echo "• Add response schemas for all endpoints"
fi

if [ "$undocumented_count" -gt 0 ]; then
    echo "• Add @openapi JSDoc to undocumented endpoints"
    echo "• Run 'grep -r \"app.get\"' to find undocumented routes"
fi

echo ""
echo "Next steps:"
echo "  1. Fix documentation issues listed above"
echo "  2. Re-generate OpenAPI spec"
echo "  3. Re-run this validation script"
echo "  4. Generate typed client: ./generate-client.sh"
