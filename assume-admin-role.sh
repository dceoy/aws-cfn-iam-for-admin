#!/usr/bin/env bash
#
# Usage:
#   assume-admin-role.sh

set -euo pipefail

if [[ ${#} -gt 0 ]] && [[ "${1}" == "--debug" ]]; then
  set -x
fi

TMP_ROLE_SH="$(realpath "${0}" | xargs dirname)/tmp.role.sh"

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

tmp_credentials="$( \
  aws sts get-caller-identity \
    | jq -r .Account \
    | xargs -t -I {} \
      aws sts assume-role \
      --role-arn arn:aws:iam::{}:role/AdminRoleToSwitch \
      --role-session-name "admin-session-${RANDOM}" \
      --duration-seconds 3600 \
)"

cat << EOF > "${TMP_ROLE_SH}"
export \
  AWS_ACCESS_KEY_ID=$(echo "${tmp_credentials}" | jq -r .Credentials.AccessKeyId) \
  AWS_SECRET_ACCESS_KEY=$(echo "${tmp_credentials}" | jq -r .Credentials.SecretAccessKey) \
  AWS_SESSION_TOKEN=$(echo "${tmp_credentials}" | jq -r .Credentials.SessionToken)
EOF

chmod +x "${TMP_ROLE_SH}"
echo
echo '# Load credentials'
echo "$ source ${TMP_ROLE_SH}"
echo
echo '# Unload credentials'
echo '$ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN'
