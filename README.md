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
    $ rain deploy -y \
        iam-role-and-group-for-admin.cfn.yml iam-role-and-group-for-admin
    ```

Usage
-----

1.  Create an IAM user and add it to the administrator IAM group.

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Switch to the IAM role.

    - Option 1: Use an AWS CLI profile.

      1.  Write a profile for the administrator IAM role in `~/.aws/config`.
          (Replace `123456789012` below with your account ID.)

          ```ini
          [profile admin]
          role_arn = arn:aws:iam::123456789012:role/AdminRoleToSwitch
          source_profile = default
          ```

      2.  Execute some commands using the profile.

          ```sh
          $ aws --profile admin sts get-caller-identity
          ```

    - Option 2: Generate temporary credentials.

      1.  Assume the administrator IAM role.

          ```sh
          $ ./assume-admin-role.sh
          $ source tmp.role.sh
          ```

      2.  Execute some commands with the administrator role.

          ```sh
          $ aws sts get-caller-identity
          ```

      3.  Clear temporary credentials.

          ```sh
          $ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
          $ rm -f tmp.role.json
          ```
