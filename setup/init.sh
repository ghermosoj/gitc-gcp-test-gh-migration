#!/bin/bash
set -o errexit
setup_env_vars() {
    source load_config
    source load_cmdb_client

    export toolbox_version="1.7.5+test~1"
    export project_number=${DEFAULT[$env_char, "pipeline_project_number"]}
    export region=${DEFAULT_REGION}
    export region_short="${REGION_SHORT[$DEFAULT_REGION]}"
    export repo="gitc-gcp-test-gh-migration"
    export pipeline_project_id="${DEFAULT[$env_char, pipeline_project_id]}"
    export connection_name="conn-gcpf-${env_char}-github"
    export secret_name="sec-gcpf-${env_char}-gh-token"
    export application_id="sec-gcpf-${env_char}-gh-app-id"
    export repo_url="https://github.com/ghermosoj/csr-github"
}

. parse_args_init "$@"

if ! is_valid_env_char ${env}; then
    show_usage_and_exit
fi

env_char="${env}"

setup_env_vars

export PATH="/workspace/.toolbox:$PATH"

activate_pipeline_service_account --env_char "${env_char}" --no_delete --credentials_file_path "/workspace/account.json"

github_connect_host --project_id "${pipeline_project_id}" --connection_name "${connection_name}" --secret_id "${secret_name}" --application_id "${application_id}"

github_link_repository --project_id "${pipeline_project_id}" --connection "${connection_name}" --repo_url "${repo_url}"

