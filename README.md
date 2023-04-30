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

##### AWS CLI

Assume the administrator role using [AWS CLI](https://aws.amazon.com/cli/).

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

##### AWS Management Console

See [the user guide of IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html).
