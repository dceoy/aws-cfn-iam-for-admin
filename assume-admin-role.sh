#!/usr/bin/env bash
#
# Usage:
#   assume-admin-role.sh

set -euox pipefail

TMP_ROLE_JSON="$(realpath "${0}" | xargs dirname)/tmp.role.json"

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

aws sts get-caller-identity \
  | jq -r .Account \
  | xargs -t -I {} \
    aws sts assume-role \
    --role-arn arn:aws:iam::{}:role/AdminRole-{} \
    --role-session-name "my-admin-session-${RANDOM}" \
    --duration-seconds 3600 \
  > "${TMP_ROLE_JSON}"

export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId "${TMP_ROLE_JSON}")
export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey "${TMP_ROLE_JSON}")
export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken "${TMP_ROLE_JSON}")
