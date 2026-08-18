#!/bin/sh
set -eu

pattern='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk_live_[A-Za-z0-9]{16,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'

if git grep -IEn "$pattern" -- ':!Scripts/check-secrets.sh' >/dev/null; then
    echo "Potential credential found in the working tree." >&2
    exit 1
fi

if git log -p --all -- . ':!Scripts/check-secrets.sh' | grep -E "$pattern" >/dev/null; then
    echo "Potential credential found in git history." >&2
    exit 1
fi

echo "No high-confidence credential patterns found."
