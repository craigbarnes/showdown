#!/bin/sh
set -eu

export VPREFIX="$1"

# These values are filled automatically for git-archive(1) tarballs.
# See: "export-subst" in gitattributes(5).
distinfo_commit_full='$Format:%H$'
distinfo_commit_short='$Format:%h$'
distinfo_author_date='$Format:%ai$'

if expr "$distinfo_commit_short" : '[0-9a-f]\{7,40\}$' >/dev/null; then
    echo "${VPREFIX}-g${distinfo_commit_short}-dist"
    exit 0
fi

git_describe_ver=$(git describe --match="$VPREFIX" 2>/dev/null || true)
if test -n "$git_describe_ver"; then
    echo "$git_describe_ver"
    exit 0
fi

echo "$VPREFIX-unknown"
