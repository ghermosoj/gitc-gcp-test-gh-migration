#!/bin/bash
set -o errexit
setup_env_vars() {
    source "/home/user/.toolbox/load_config"
    source "/home/user/.toolbox/load_cmdb_client"

    export toolbox_version="1.7.5+test~1"
    export project_number=${DEFAULT[$env_char, "pipeline_project_number"]}
    export region=${DEFAULT_REGION}
    export region_short="${REGION_SHORT[$DEFAULT_REGION]}"
    export repo="gitc-gcp-test-gh-migration"
    export pipeline_project_id="${DEFAULT[$env_char, pipeline_project_id]}"
    export connection_name="conn-gcpf-${env_char}-github"
    export secret_name="sec-gcpf-${env_char}-gh-token"
    export application_id="sec-gcpf-${env_char}-gh-app-id"
    export repo_url="https://github.com/ghermosoj/gitc-gcp-test-gh-migration"
    export branch="main"

    export build_yaml_path="cloudbuild.yaml"

    local current_url="${repo_url%/}"
    export repo_name="${current_url##*/}"
    export trigger_base_name="trg-${repo_name}-${env_char}"
    
    export pubsub_topic="test-github-topic"
    export repo_name="${repo_name%.git}"
}

. parse_args_init "$@"

if ! is_valid_env_char ${env}; then
    show_usage_and_exit
fi

env_char="${env}"

setup_env_vars

github_connect_host --project_id "${pipeline_project_id}" --connection_name "${connection_name}" --secret_name "${secret_name}" --installation_id "${application_id}"

github_link_repository --project_id "${pipeline_project_id}" --connection "${connection_name}" --repo_url "${repo_url}"


create_github_trigger --project_id "${pipeline_project_id}" --trigger_name "${trigger_base_name}-push" --connection "${connection_name}" --repo_name "${repo_name}" --event "push" --branch "${branch}" --build_yaml_path "${build_yaml_path}"

create_github_trigger --project_id "${pipeline_project_id}" --trigger_name "${trigger_base_name}-manual" --connection "${connection_name}" --repo_name "${repo_name}" --event "manual" --branch "${branch}" --build_yaml_path "${build_yaml_path}"

create_github_trigger --project_id "${pipeline_project_id}" --trigger_name "${trigger_base_name}-pubsub" --connection "${connection_name}" --repo_name "${repo_name}" --event "pubsub" --topic "${pubsub_topic}" --branch "${branch}" --build_yaml_path "${build_yaml_path}"