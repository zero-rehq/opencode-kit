#!/bin/bash

# validate-skills.sh - Validates skill structure across the opencode-kit system
# Usage: ./validate-skills.sh
# Output: Validation report with any issues found

set -e

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="$KIT_ROOT/.opencode/skill"
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

echo "=========================================="
echo "Skills Structure Validation"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print errors
print_error() {
    echo -e "${RED}ERROR:${NC} $1"
    ((TOTAL_ERRORS++))
}

# Function to print warnings
print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
    ((TOTAL_WARNINGS++))
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if skills directory exists
if [ ! -d "$SKILLS_DIR" ]; then
    print_error "Skills directory not found: $SKILLS_DIR"
    exit 1
fi

# Get all skill directories
skill_dirs=($(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d -not -name ".*" | sort))

echo "Found ${#skill_dirs[@]} skill directories"
echo ""

# Validate each skill
for skill_dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    echo "Validating skill: $skill_name"

    # Check if SKILL.md exists
    if [ ! -f "$skill_file" ]; then
        print_error "SKILL.md not found for skill: $skill_name"
        continue
    fi

    # Check frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | head -n -1 | tail -n +2)

    # Extract name from frontmatter
    frontmatter_name=$(echo "$frontmatter" | grep -E '^name:' | sed 's/name: *//' | sed 's/"//g')

    if [ -z "$frontmatter_name" ]; then
        print_error "No 'name' field found in SKILL.md frontmatter for: $skill_name"
    elif [ "$frontmatter_name" != "$skill_name" ]; then
        print_error "Name mismatch: directory='$skill_name' but frontmatter name='$frontmatter_name'"
    else
        print_success "Name matches directory: $skill_name"
    fi

    # Check description field
    frontmatter_desc=$(echo "$frontmatter" | grep -E '^description:' | sed 's/description: *//' | sed 's/"//g')

    if [ -z "$frontmatter_desc" ]; then
        print_error "No 'description' field found in SKILL.md frontmatter for: $skill_name"
    else
        print_success "Description found: ${frontmatter_desc:0:60}..."
    fi

    # Check if it's a template skill (marked in content)
    if grep -q "Template para nuevo skill" "$skill_file"; then
        print_warning "Skill marked as template (pending implementation): $skill_name"

        # Check if scripts directory is empty or missing
        scripts_dir="$skill_dir/scripts"
        if [ ! -d "$scripts_dir" ] || [ -z "$(ls -A "$scripts_dir" 2>/dev/null)" ]; then
            print_warning "No scripts found for template skill: $skill_name"
        fi
    fi

    # Check for WORKFLOW_ROUTER.md or RULES_ROUTER.md
    has_router=false
    if [ -f "$skill_dir/WORKFLOW_ROUTER.md" ]; then
        has_router=true
        print_success "Has WORKFLOW_ROUTER.md"
    fi
    if [ -f "$skill_dir/RULES_ROUTER.md" ]; then
        has_router=true
        print_success "Has RULES_ROUTER.md"
    fi

    if [ "$has_router" = false ]; then
        print_warning "No router documentation (WORKFLOW_ROUTER.md or RULES_ROUTER.md) found"
    fi

    # Check for scripts directory
    if [ -d "$skill_dir/scripts" ]; then
        script_count=$(find "$skill_dir/scripts" -type f | wc -l)
        if [ "$script_count" -gt 0 ]; then
            print_success "Has $script_count script(s) in scripts/ directory"
        fi
    fi

    echo ""
done

# Check for duplicates in frontmatter names
echo "Checking for duplicate skill names..."
all_names=($(find "$SKILLS_DIR" -name "SKILL.md" -exec grep -h "^name:" {} \; | sed 's/name: *//' | sed 's/"//g' | sort))
unique_names=($(printf "%s\n" "${all_names[@]}" | uniq -u))
duplicate_names=($(printf "%s\n" "${all_names[@]}" | uniq -d))

if [ ${#duplicate_names[@]} -gt 0 ]; then
    print_error "Found duplicate skill names: ${duplicate_names[*]}"
else
    print_success "No duplicate skill names found"
fi

echo ""
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
if [ $TOTAL_ERRORS -eq 0 ] && [ $TOTAL_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
elif [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Passed with $TOTAL_WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}Failed with $TOTAL_ERRORS error(s) and $TOTAL_WARNINGS warning(s)${NC}"
    exit 1
fi
