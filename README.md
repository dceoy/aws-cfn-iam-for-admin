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
