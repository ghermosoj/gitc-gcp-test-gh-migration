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
    export bucket_name="cs-gcpf-${env_char}-gitc-${region_short}-test-rm"
    export build_yaml_path="app-cloudbuild.yaml"
    local current_url="${repo_url%/}"
    export repo_name="${current_url##*/}"
    export trigger_name="trg-${repo_name}-${env_char}-deploy"
}

. parse_args_init "$@"

if ! is_valid_env_char ${env}; then
    show_usage_and_exit
fi

env_char="${env}"

setup_env_vars

export PATH="/workspace/.toolbox:$PATH"

activate_pipeline_service_account --env_char "${env_char}" --no_delete --credentials_file_path "/workspace/account.json"

github_link_repository --project_id "${pipeline_project_id}" --connection "${connection_name}" --repo_url "${repo_url}"

if gcloud storage buckets describe "gs://${BUCKET_NAME}"; then
    echo "[SUCCESS] Bucket gs://${BUCKET_NAME} already exists. Skipping."
else
    echo "[ACTION] Creating bucket gs://${BUCKET_NAME} in project ${pipeline_project_id}"
    
    if command -v create_tfstate_bucket &> /dev/null; then
        create_tfstate_bucket --context "migration"
    else
        gcloud storage buckets create "gs://${BUCKET_NAME}" \
          --project="${pipeline_project_id}" \
          --location="${region}" \
          --uniform-bucket-level-access
    fi
    echo "[SUCCESS] Bucket gs://${BUCKET_NAME} created successfully."
fi

echo "[INFO] Starting target app trigger creation phase..."

create_github_trigger \
  --project_id "${pipeline_project_id}" \
  --region "${region}" \
  --connection "${connection_name}" \
  --repo_name "${repo_name}" \
  --trigger_name "${trigger_name}" \
  --event "push" \
  --branch "main" \
  --build_yaml_path "${build_yaml_path}"
