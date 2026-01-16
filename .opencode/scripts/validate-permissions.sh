#!/bin/bash

# validate-permissions.sh - Validates specific permission rules across agents
# Usage: ./validate-permissions.sh
# Output: Validation report with permission issues

set -e

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENTS_DIR="$KIT_ROOT/.opencode/agent"
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

echo "=========================================="
echo "Agent Permissions Validation"
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

# Check if agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    print_error "Agents directory not found: $AGENTS_DIR"
    exit 1
fi

# Get all agent files
agent_files=($(find "$AGENTS_DIR" -name "*.md" -type f | sort))

echo "Validating permissions for ${#agent_files[@]} agents"
echo ""

# Validate each agent
for agent_file in "${agent_files[@]}"; do
    agent_name=$(basename "$agent_file" .md)
    echo "Checking permissions for: $agent_name"

    # Extract frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -n -1 | tail -n +2)
    mode=$(echo "$frontmatter" | grep "^mode:" | sed 's/mode: *//' | sed 's/"//g')
    permission_section=$(echo "$frontmatter" | sed -n '/^permission:/,/^---$/p' | head -n -1)

    # Check permission based on agent type and mode
    case "$agent_name" in
        orchestrator)
            # Orchestrator (primary): NO edit, NO bash (except allow-list)
            echo "  Checking orchestrator permissions..."

            # Should NOT have edit: allow
            if echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "Orchestrator should NOT have edit:allow"
            else
                print_success "Orchestrator has edit:deny (correct)"
            fi

            # Should NOT have bash: *: allow (only specific allow-list)
            if echo "$permission_section" | grep -q 'bash:\|.*"\\*": *allow' | grep -q '"\*":.*allow'; then
                print_error "Orchestrator should NOT have bash wildcard allow"
            else
                print_success "Orchestrator has restricted bash access (correct)"
            fi
            ;;

        builder)
            # Builder (subagent): YES edit, YES bash (with restrictions)
            echo "  Checking builder permissions..."

            # Should have edit: allow
            if ! echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "Builder should have edit:allow"
            else
                print_success "Builder has edit:allow (correct)"
            fi

            # Should have bash access
            if ! echo "$permission_section" | grep -q "^bash:"; then
                print_warning "Builder has no bash permission defined"
            fi
            ;;

        reviewer)
            # Reviewer (subagent): NO edit, bash: ask for most, allow for some
            echo "  Checking reviewer permissions..."

            # Should NOT have edit: allow
            if echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "Reviewer should NOT have edit:allow"
            else
                print_success "Reviewer has edit:deny (correct)"
            fi

            # Should have specific bash permissions (git status, git diff, rg)
            if ! echo "$permission_section" | grep -qE 'git status|git diff|rg'; then
                print_warning "Reviewer should have specific bash permissions for git/rg"
            else
                print_success "Reviewer has git/rg bash permissions (correct)"
            fi
            ;;

        scribe|skills-router-agent|repo-scout|contract-keeper)
            # NO edit, NO bash (except allow-list)
            echo "  Checking $agent_name permissions..."

            # Should NOT have edit: allow
            if echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "$agent_name should NOT have edit:allow"
            else
                print_success "$agent_name has edit:deny (correct)"
            fi
            ;;

        docs-specialist|bootstrap-scout)
            # docs-specialist: YES edit (for documentation)
            # bootstrap-scout: YES edit (for AGENTS.md generation)
            echo "  Checking $agent_name permissions..."

            if ! echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "$agent_name should have edit:allow"
            else
                print_success "$agent_name has edit:allow (correct)"
            fi
            ;;

        integration-builder)
            # integration-builder: YES edit, YES bash
            echo "  Checking integration-builder permissions..."

            if ! echo "$permission_section" | grep -q "edit: *allow"; then
                print_error "integration-builder should have edit:allow"
            else
                print_success "integration-builder has edit:allow (correct)"
            fi
            ;;

        *)
            print_warning "Unknown agent type: $agent_name"
            ;;
    esac

    # Check task permissions
    task_permission=$(echo "$permission_section" | grep "^task:")
    if [ -n "$task_permission" ]; then
        echo "  Has task permissions configured"
    else
        print_warning "No task permissions defined for: $agent_name"
    fi

    echo ""
done

echo "=========================================="
echo "Validation Summary"
echo "=========================================="
if [ $TOTAL_ERRORS -eq 0 ] && [ $TOTAL_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All permission checks passed!${NC}"
    exit 0
elif [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Passed with $TOTAL_WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}Failed with $TOTAL_ERRORS error(s) and $TOTAL_WARNINGS warning(s)${NC}"
    exit 1
fi
