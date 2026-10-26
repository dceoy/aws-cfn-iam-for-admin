# aws-cfn-iam-for-admin

AWS CloudFormation stacks for IAM administrator roles and user groups.

[![CI](https://github.com/dceoy/aws-cfn-iam-for-admin/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/dceoy/aws-cfn-iam-for-admin/actions/workflows/ci.yml)

IAM users authenticate with browser-based `aws login` instead of long-term IAM access keys. The administrator and CloudFormation roles and all IAM groups managed by these stacks have an explicit deny for `iam:CreateAccessKey`. Existing access keys are **not** deleted by these stacks.

## Installation

1. Install [AWS CLI v2.32.0 or later](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
2. Check out this repository:

   ```sh
   git clone https://github.com/dceoy/aws-cfn-iam-for-admin.git
   cd aws-cfn-iam-for-admin
   ```

3. Sign in with an existing principal that can deploy IAM CloudFormation stacks (and has permission to use `aws login`):

   ```sh
   aws login --profile bootstrap
   ```

4. Deploy the IAM role and group stack:

   ```sh
   aws cloudformation deploy \
     --template-file iam-role-and-group-for-admin.cfn.yml \
     --stack-name iam-role-and-group-for-admin \
     --capabilities CAPABILITY_NAMED_IAM \
     --profile bootstrap
   ```

   The optional `iam-role-and-group-for-cloudformation.cfn.yml` stack provides a CloudFormation execution role and group with the same access-key guardrail.

## Usage

1. Create an IAM user with AWS Management Console sign-in enabled, configure MFA, and add the user to `account-roles-switch-group` and `self-managed-iam-user-group`. The latter grants the AWS-managed `SignInLocalDevelopmentAccess` policy required by `aws login`.
2. Sign in interactively (no static entries in `~/.aws/credentials` are needed):

   ```sh
   aws login --profile operator
   aws sts get-caller-identity --profile operator
   ```

3. Configure an administrator role profile in `~/.aws/config`, replacing the account ID:

   ```ini
   [profile admin]
   role_arn = arn:aws:iam::123456789012:role/AdminRoleToSwitch
   source_profile = operator
   ```

4. Use the assumed administrator role. The AWS CLI retrieves temporary role credentials automatically:

   ```sh
   aws sts get-caller-identity --profile admin
   ```

5. Sign out when finished:

   ```sh
   aws logout --profile operator
   ```

## Security considerations

- The deny policies prevent **creating new long-term IAM access keys** for principals covered by these stacks, but intentionally do not deny `iam:UpdateAccessKey`: existing keys can still be deactivated during incident response (or reactivated by principals otherwise authorized). They do not block temporary session credentials issued by `aws login` or AWS STS.
- An administrator with IAM policy-modification privileges can detach or change these policies, and other IAM roles or users may not be covered. Enforce an account-wide, tamper-resistant restriction with an AWS Organizations service control policy (SCP) where applicable.
- Deactivate and delete any existing long-term access keys separately. Stack updates do not revoke or delete them. To block reactivation account-wide, remove legacy keys and establish separate organization-level guardrails.

See [AWS CLI sign-in documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html) for the browser login workflow.
