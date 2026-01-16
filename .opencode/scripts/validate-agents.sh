#!/bin/bash

# validate-agents.sh - Validates agent configuration and permissions across the opencode-kit system
# Usage: ./validate-agents.sh
# Output: Validation report with any issues found

set -e

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENTS_DIR="$KIT_ROOT/.opencode/agent"
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

echo "=========================================="
echo "Agents Configuration Validation"
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

echo "Found ${#agent_files[@]} agent files"
echo ""

# Expected agents
declare -A expected_agents=(
    ["orchestrator"]="primary"
    ["builder"]="subagent"
    ["reviewer"]="subagent"
    ["scribe"]="subagent"
    ["skills-router-agent"]="subagent"
    ["repo-scout"]="subagent"
    ["contract-keeper"]="subagent"
    ["docs-specialist"]="subagent"
    ["bootstrap-scout"]="subagent"
    ["integration-builder"]="subagent"
)

# Track found agents
declare -A found_agents

# Validate each agent
for agent_file in "${agent_files[@]}"; do
    agent_name=$(basename "$agent_file" .md)

    echo "Validating agent: $agent_name"

    # Check if agent is in expected list
    if [ -z "${expected_agents[$agent_name]+isset}" ]; then
        print_warning "Agent '$agent_name' not in expected list"
    else
        found_agents[$agent_name]=1
    fi

    # Extract frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -n -1 | tail -n +2)

    # Check required fields in frontmatter
    required_fields=("description" "mode" "model" "temperature")
    for field in "${required_fields[@]}"; do
        if ! echo "$frontmatter" | grep -q "^${field}:"; then
            print_error "Missing required field '$field' in frontmatter for: $agent_name"
        else
            print_success "Has field '$field'"
        fi
    done

    # Check mode is valid
    mode=$(echo "$frontmatter" | grep "^mode:" | sed 's/mode: *//' | sed 's/"//g')
    if [ "$mode" != "primary" ] && [ "$mode" != "subagent" ]; then
        print_error "Invalid mode '$mode' for: $agent_name (must be 'primary' or 'subagent')"
    fi

    # Check if tools section exists
    if ! echo "$frontmatter" | grep -q "^tools:"; then
        print_error "Missing 'tools' section in frontmatter for: $agent_name"
    else
        # Check if skill is enabled in tools
        if ! echo "$frontmatter" | grep -A 5 "^tools:" | grep -q "skill:"; then
            print_error "Missing 'skill:' in tools section for: $agent_name"
        else
            skill_value=$(echo "$frontmatter" | grep -A 5 "^tools:" | grep "skill:" | sed 's/.*skill: *//' | sed 's/"//g')
            if [ "$skill_value" != "true" ]; then
                print_warning "Skill not enabled (value: $skill_value) for: $agent_name"
            else
                print_success "Skill tool enabled"
            fi
        fi
    fi

    # Check if permission section exists
    if ! echo "$frontmatter" | grep -q "^permission:"; then
        print_error "Missing 'permission' section in frontmatter for: $agent_name"
    else
        # Validate permission structure
        permission_section=$(echo "$frontmatter" | sed -n '/^permission:/,/^---$/p' | head -n -1)
        print_success "Has permission section"
    fi

    echo ""
done

# Check for missing expected agents
echo "Checking for missing expected agents..."
for agent_name in "${!expected_agents[@]}"; do
    if [ -z "${found_agents[$agent_name]+isset}" ]; then
        print_error "Expected agent not found: $agent_name"
    else
        print_success "Expected agent found: $agent_name"
    fi
done

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
