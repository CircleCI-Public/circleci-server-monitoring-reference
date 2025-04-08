#!/usr/bin/env bash
set -euo pipefail

file_path="./dashboards/server-slis.json"

check_exported_for_external_instance() {
    if jq '.__inputs[] | select(.name == "DS_PROMETHEUS")' "$file_path" > /dev/null; then
        echo "__input 'DS_PROMETHEUS' is configured correctly."
    else
        echo "Error: '__input DS_PROMETHEUS' is missing. Ensure the dashboard is exported for an external instance."
        exit 1
    fi
}

check_title_and_uid() {
    jq --arg title "Server SLIs" --arg uid "beg3u6ond4ydcb" '
        .title = $title |
        .uid = $uid
    ' "$file_path" > "${file_path}.tmp"

    if ! diff -q "$file_path" "${file_path}.tmp" > /dev/null; then
        mv "${file_path}.tmp" "$file_path"
        echo "Dashboard updated: title or UID was incorrect. Please commit the changes."
        exit 1
    else
        rm "${file_path}.tmp"
        echo "Dashboard title and UID are correctly set."
    fi
}

check_exported_for_external_instance
check_title_and_uid
