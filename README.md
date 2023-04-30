aws-cfn-iam-for-admin
=====================

AWS CloudFormation stacks of IAM user groups for administrators

[![Lint](https://github.com/dceoy/aws-cfn-iam-for-admin/actions/workflows/lint.yml/badge.svg)](https://github.com/dceoy/aws-cfn-iam-for-admin/actions/workflows/lint.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone --recurse-submodules git@github.com:dceoy/aws-cfn-iam-for-admin.git
    $ cd aws-cfn-iam-for-admin
    ```

2.  Install [Rain](https://github.com/aws-cloudformation/rain) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Deploy stacks for IAM user groups.

    ```sh
    $ rain deploy \
        iam-role-and-group-for-admin.cfn.yml iam-role-and-group-for-admin
    ```

Usage
-----

1.  Install [AWS CLI](https://aws.amazon.com/cli/).

2.  Assume the administrator role.

    ```sh
    $ aws sts get-caller-identity \
        | jq -r .Account \
        | xargs -t -I {} \
          aws sts assume-role \
          --role-arn arn:aws:iam::{}:role/AdminRole-{} \
          --role-session-name "my-admin-session-${RANDOM}" \
          --duration-seconds 3600 \
        > tmp.role.json
    $ export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId tmp.role.json)
    $ export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey tmp.role.json)
    $ export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken tmp.role.json)
    ```

3.  Execute some commands with the administrator role.

4.  Clear temporary credentials.

    ```sh
    $ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    $ rm -f tmp.role.json
    ```
