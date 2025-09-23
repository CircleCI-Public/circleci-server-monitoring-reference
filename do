#!/usr/bin/env bash
set -euo pipefail

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_version="Print the chart version"
version() {
  check-helm

  helm show chart . | grep '^version:' | cut -d' ' -f2
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_kubeconform="Run helm kubeconform"
kubeconform() {
    check-helm
    install-plugin kubeconform https://github.com/jtyr/kubeconform-helm

    # Add schemas not included in any catalogs
    schemas_dir="./target/schemas"
    mkdir -p "${schemas_dir}"
    cd "${schemas_dir}"
    curl -s https://raw.githubusercontent.com/yannh/kubeconform/master/scripts/openapi2jsonschema.py | \
        python3 - https://raw.githubusercontent.com/grafana/tempo-operator/refs/heads/main/config/crd/bases/tempo.grafana.com_tempomonolithics.yaml
    cd -

    helm kubeconform --verbose --summary --strict "$@" \
        --schema-location default \
        --schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
        --schema-location "${schemas_dir}/{{ .ResourceKind }}_{{.ResourceAPIVersion}}.json" \
        .
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_lint_dashboards="Lint the Grafana dashboards using dashboard-linter."
lint-dashboards() {
    install-go-bin "github.com/grafana/dashboard-linter@latest"
    
    for dashboard in dashboards/*.json; do
        ./bin/dashboard-linter lint --strict --verbose "$dashboard"
    done
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_validate_dashboards="Validate the configurations of default Grafana dashboards."
validate-dashboards() {
    bash scripts/validate_dashboards.sh
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_unit_tests="Run helm unittest"
unit-tests() {
    check-helm

    install-plugin unittest https://github.com/helm-unittest/helm-unittest.git

    helm unittest -f 'tests/**/*_test.yaml' . "$@"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_helm_docs="Run helm-docs"
helm-docs() {
    if ! [ -x "$(command -v helm-docs)" ]; then
        docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest
    else
      helm-docs
    fi
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_package_chart="Package the Helm chart"
package-chart() {
    check-helm

    local arg="${1:-}"
    if [ -n "${arg}" ]; then
        shift
    fi

    echo 'Updating dependencies'
    helm dependency update

    mkdir -p target

    echo 'Packaging Helm chart'
    case ${arg} in
    "sign")
        echo 'Signing Helm chart'
        # shellcheck disable=SC2086
        helm package --sign --key "${KEY:-<eng-on-prem@circleci.com>}" --keyring ${KEYRING:-~/.gnupg/secring.gpg} \
          --destination ./target . "$@"
        echo 'Verifying Helm chart signature'
        helm verify ./target/server-monitoring-stack-"$(version)".tgz
        ;;
    *)
        helm package --destination ./target .
        ;;
    esac
}

check-helm() {
    if ! [ -x "$(command -v helm)" ]; then
        echo 'Helm is required. See: https://helm.sh/docs/intro/install/'
        exit 1
    fi
}

install-plugin() {
    name="${1}"
    repo="${2}"

    if ! helm plugin list | grep ${name} >/dev/null; then
        echo "Installing helm ${name}"
        helm plugin install "${repo}"
    fi
}

install-go-bin() {
    for pkg in "${@}"; do
        GOBIN="${PWD}/bin" go install "${pkg}" &
    done
    wait
}

help-text-intro() {
    echo "
DO

A set of simple repetitive tasks that adds minimally
to standard tools used to build and test the service.
(e.g. go and docker)
"
}

### START FRAMEWORK ###
# Do Version 0.0.4
# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_self_update="Update the framework from a file.

Usage: $0 self-update FILENAME
"
self-update() {
    local source selfpath pattern
    source="$1"
    selfpath="${BASH_SOURCE[0]}"
    cp "$selfpath" "$selfpath.bak"
    pattern='/### START FRAMEWORK/,/END FRAMEWORK ###$/'
    (
        sed "${pattern}d" "$selfpath"
        sed -n "${pattern}p" "$source"
    ) \
        >"$selfpath.new"
    mv "$selfpath.new" "$selfpath"
    chmod --reference="$selfpath.bak" "$selfpath"
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_completion="Print shell completion function for this script.

Usage: $0 completion SHELL"
completion() {
    local shell
    shell="${1-}"

    if [ -z "$shell" ]; then
        echo "Usage: $0 completion SHELL" 1>&2
        exit 1
    fi

    case "$shell" in
    bash)
        (
            echo
            echo '_dotslashdo_completions() { '
            # shellcheck disable=SC2016
            echo '  COMPREPLY=($(compgen -W "$('"$0"' list)" "${COMP_WORDS[1]}"))'
            echo '}'
            echo 'complete -F _dotslashdo_completions '"$0"
        )
        ;;
    zsh)
        cat <<EOF
_dotslashdo_completions() {
  local -a subcmds
  subcmds=()
  DO_HELP_SKIP_INTRO=1 $0 help | while read line; do
EOF
        cat <<'EOF'
    cmd=$(cut -f1  <<< $line)
    cmd=$(awk '{$1=$1};1' <<< $cmd)

    desc=$(cut -f2- <<< $line)
    desc=$(awk '{$1=$1};1' <<< $desc)

    subcmds+=("$cmd:$desc")
  done
  _describe 'do' subcmds
}

compdef _dotslashdo_completions do
EOF
        ;;
    fish)
        cat <<EOF
complete -e -c do
complete -f -c do
for line in (string split \n (DO_HELP_SKIP_INTRO=1 $0 help))
EOF
        cat <<'EOF'
  set cmd (string split \t $line)
  complete -c do  -a $cmd[1] -d $cmd[2]
end
EOF
        ;;
    esac
}

list() {
    declare -F | awk '{print $3}'
}

# This variable is used, but shellcheck can't tell.
# shellcheck disable=SC2034
help_help="Print help text, or detailed help for a task."
help() {
    local item
    item="${1-}"
    if [ -n "${item}" ]; then
        local help_name
        help_name="help_${item//-/_}"
        echo "${!help_name-}"
        return
    fi

    if [ -z "${DO_HELP_SKIP_INTRO-}" ]; then
        type -t help-text-intro >/dev/null && help-text-intro
    fi
    for item in $(list); do
        local help_name text
        help_name="help_${item//-/_}"
        text="${!help_name-}"
        [ -n "$text" ] && printf "%-30s\t%s\n" "$item" "$(echo "$text" | head -1)"
    done
}

case "${1-}" in
list) list ;;
"" | "help") help "${2-}" ;;
*)
    if ! declare -F "${1}" >/dev/null; then
        printf "Unknown target: %s\n\n" "${1}"
        help
        exit 1
    else
        "$@"
    fi
    ;;
esac
### END FRAMEWORK ###
