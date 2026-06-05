#!/usr/bin/env bash
set -euo pipefail

check_exported_for_external_instance() {
    local file_path="$1"
    if jq '.__inputs[] | select(.name == "DS_PROMETHEUS")' "$file_path" > /dev/null; then
        echo "__input 'DS_PROMETHEUS' is configured correctly in ${file_path}."
    else
        echo "Error: '__input DS_PROMETHEUS' is missing in ${file_path}. Ensure the dashboard is exported for an external instance."
        exit 1
    fi
}

check_title_and_uid() {
    local file_path="$1"
    local expected_title="$2"
    local expected_uid="$3"

    jq --arg title "$expected_title" --arg uid "$expected_uid" '
        .title = $title |
        .uid = $uid
    ' "$file_path" > "${file_path}.tmp"

    if ! diff -q "$file_path" "${file_path}.tmp" > /dev/null; then
        mv "${file_path}.tmp" "$file_path"
        echo "Dashboard updated in ${file_path}: title or UID was incorrect. Please commit the changes."
        exit 1
    else
        rm "${file_path}.tmp"
        echo "Dashboard title and UID are correctly set in ${file_path}."
    fi
}

validate_dashboard() {
    local file_path="$1"
    local expected_title="$2"
    local expected_uid="$3"
    check_exported_for_external_instance "$file_path"
    check_title_and_uid "$file_path" "$expected_title" "$expected_uid"
}

validate_dashboard "./dashboards/server-slis.json" "Server SLIs" "beg3u6ond4ydcb"
validate_dashboard "./dashboards/server-slis-server4.10.json" "Server SLIs (4.10+)" "beg3u6ond4y410"
