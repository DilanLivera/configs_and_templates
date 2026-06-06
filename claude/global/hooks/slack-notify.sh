#!/usr/bin/env bash
# Forwards a Claude Code hook event (JSON on stdin) to the griffin slack-notify
# handler, wherever it lives on this machine. No-ops (exit 0) if griffin isn't
# installed, so the hook never breaks on machines that don't have it.
#
# settings.json points its hooks at this stable path ($HOME/.claude/hooks/...),
# which install.sh symlinks into place — so the hook command is identical on
# every machine even though griffin's repo path differs (repos vs repositories).
set -euo pipefail

candidates=()
# Explicit override wins, if set.
[ -n "${GRIFFIN_SLACK_NOTIFY:-}" ] && candidates+=("$GRIFFIN_SLACK_NOTIFY")
# Known locations — the parent dir name varies across machines.
candidates+=(
  "$HOME/dev/repos/griffin/slack-notify/hook-handler.sh"
  "$HOME/dev/repositories/griffin/slack-notify/hook-handler.sh"
)

for handler in "${candidates[@]}"; do
  if [ -f "$handler" ]; then
    exec bash "$handler" "$@"
  fi
done

exit 0
