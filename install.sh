#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
KIT_ROOT="$SCRIPT_DIR"
WORKSPACE_ROOT="$(cd "$KIT_ROOT/.." && pwd)"

force=0
[[ "${1:-}" == "--force" ]] && force=1

echo "Kit root:       $KIT_ROOT"
echo "Workspace root: $WORKSPACE_ROOT"

mkdir -p "$WORKSPACE_ROOT/.opencode/bin" "$WORKSPACE_ROOT/.opencode/targets" "$WORKSPACE_ROOT/worklog"

# Link agent/skill/command/templates (targets remain real)
for p in agent skill command templates; do
  src="$KIT_ROOT/.opencode/$p"
  dst="$WORKSPACE_ROOT/.opencode/$p"
  if [[ -e "$dst" && "$force" -ne 1 ]]; then
    echo "Skip existing: $dst"
  else
    rm -rf "$dst" 2>/dev/null || true
    ln -s "$src" "$dst"
    echo "Linked: $dst -> $src"
  fi
done

# Link bin wrappers
for name in oc-repos oc-targets oc-bootstrap-repos oc-snapshot oc-run-ci oc-wrap oc-catalog-sync oc-no-any oc-e2e-trace oc-gate oc-jira-note; do
  src="$KIT_ROOT/scripts/$name"
  dst="$WORKSPACE_ROOT/.opencode/bin/$name"
  if [[ -e "$dst" && "$force" -ne 1 ]]; then
    echo "Skip existing bin: $dst"
  else
    rm -f "$dst" 2>/dev/null || true
    ln -s "$src" "$dst"
    echo "Linked bin: $dst -> $src"
  fi
done

CFG="$WORKSPACE_ROOT/opencode.json"
if [[ -f "$CFG" && "$force" -ne 1 ]]; then
  ts="$(date +%s)"
  cp "$CFG" "$CFG.bak.$ts"
  echo "Backed up existing opencode.json -> $CFG.bak.$ts"
fi

cat > "$CFG" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "share": "manual",
  "instructions": [
    "opencode-multirepo-kit-definitivo/AGENTS.md",
    "opencode-multirepo-kit-definitivo/docs/workflow.md",
    "opencode-multirepo-kit-definitivo/docs/e2e-trace.md",
    "opencode-multirepo-kit-definitivo/catalog/services.yaml",
    "opencode-multirepo-kit-definitivo/docs/references/README.md"
  ],
  "command": {
    "bootstrap": {
      "description": "Bootstrap docs per repo (AGENTS.md + optional service.yaml)",
      "template": "Bootstrap repo docs.\n1) Run ./.opencode/bin/oc-bootstrap-repos --service-yaml\n2) (Optional) Run ./.opencode/bin/oc-catalog-sync\n3) Summarize which repos got AGENTS.md/service.yaml created.\n"
    },
    "task": {
      "description": "Start a multi-repo task (targets + worklog + snapshot before)",
      "template": "We are starting task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-targets init \"$ARGUMENTS\"\n2) Set targets: ./.opencode/bin/oc-targets auto \"$ARGUMENTS\" \"<query>\" (or set manually)\n3) Run ./.opencode/bin/oc-snapshot \"$ARGUMENTS\" (before)\n4) Write an ordered plan checklist into the worklog.\n"
    },
    "gate": {
      "description": "Run gates (no-any + best-effort CI) on target repos",
      "template": "Run gates for task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-gate \"$ARGUMENTS\"\n2) Paste key failures/summaries into the worklog.\n3) Ask @reviewer for PASS/FAIL using E2E_TRACE + diff.\n"
    },
    "no-any": {
      "description": "Scan target repos for TypeScript any usage",
      "template": "Run no-any scan for task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-no-any \"$ARGUMENTS\"\n2) If FAIL: remove/replace with unknown + narrowing, or document why unavoidable.\n"
    },
    "e2e-trace": {
      "description": "Insert E2E_TRACE template into worklog",
      "template": "Insert E2E_TRACE template for task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-e2e-trace \"$ARGUMENTS\"\n2) Fill the template with real paths/endpoints/payloads and verification steps.\n"
    },
    "jira-note": {
      "description": "Generate a quick Jira comment draft from worklog",
      "template": "Generate Jira note for task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-jira-note \"$ARGUMENTS\"\n2) Optionally ask @scribe to refine it into a final Jira comment.\n"
    },
    "wrap": {
      "description": "Wrap task (CI on targets + snapshot after + commits + Jira note)",
      "template": "We are wrapping task: $ARGUMENTS.\n1) Run ./.opencode/bin/oc-gate \"$ARGUMENTS\"\n2) Run ./.opencode/bin/oc-wrap \"$ARGUMENTS\"\n3) Run ./.opencode/bin/oc-jira-note \"$ARGUMENTS\"\n4) Ask @reviewer for final PASS/FAIL notes.\n5) Ensure DoD is satisfied.\n"
    }
  }
}
EOF

echo "Wrote: $CFG"
echo "Install done. Run: cd \"$WORKSPACE_ROOT\" && opencode"
