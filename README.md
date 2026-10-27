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

   The optional `iam-role-and-group-for-cloudformation.cfn.yml` stack provides a CloudFormation execution role and the fixed `cloudformation-user-group` IAM group with the same access-key guardrail.

## Migrating an existing CloudFormation group

Renaming `cloudformation-user-group-<account-id>` to `cloudformation-user-group`
**replaces** the `AWS::IAM::Group` resource. CloudFormation cannot delete a group
that still contains IAM users. **Do not deploy the updated
`iam-role-and-group-for-cloudformation.cfn.yml` stack until the old group is
empty.** Plan a maintenance window: users temporarily lose permissions granted
only by this group. Use a separately authenticated administrator that does not
depend on this group for the migration, and confirm the destination group name
is not already in use.

1. Inventory the existing members. Run these commands in the same shell and
   preserve `cloudformation-group-members.txt` until migration is verified.

   ```sh
   export AWS_PROFILE=bootstrap
   ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
   OLD_GROUP="cloudformation-user-group-${ACCOUNT_ID}"
   NEW_GROUP=cloudformation-user-group
   aws iam get-group --group-name "$OLD_GROUP" \
     --query 'Users[].UserName' --output text \
     | tr '\t' '\n' > cloudformation-group-members.txt
   cat cloudformation-group-members.txt
   ```

2. After confirming the inventory and the administrator's independent access,
   detach those IAM users from the old group and update the **existing** stack.
   Substitute the deployed stack name if different.

   ```sh
   while IFS= read -r username; do
     [ -n "$username" ] || continue
     aws iam remove-user-from-group \
       --group-name "$OLD_GROUP" --user-name "$username"
   done < cloudformation-group-members.txt

   aws cloudformation deploy \
     --template-file iam-role-and-group-for-cloudformation.cfn.yml \
     --stack-name iam-role-and-group-for-cloudformation \
     --capabilities CAPABILITY_NAMED_IAM
   ```

3. Once the stack is `UPDATE_COMPLETE`, reattach the recorded members to
   the new group and verify the membership:

   ```sh
   while IFS= read -r username; do
     [ -n "$username" ] || continue
     aws iam add-user-to-group \
       --group-name "$NEW_GROUP" --user-name "$username"
   done < cloudformation-group-members.txt

   aws iam get-group --group-name "$NEW_GROUP" \
     --query 'Users[].UserName' --output text
   ```

If the stack update fails and rolls back, confirm that the old group still
exists before restoring the recorded members **to the old group**, then
investigate the CloudFormation stack events. Externally attached IAM group
policies or unmanaged dependencies may also require attention.

## Usage

1. Create an IAM user with AWS Management Console sign-in enabled, configure MFA, and add the user to `account-roles-switch-group` and `self-managed-iam-user-group`. The latter grants the AWS-managed `SignInLocalDevelopmentAccess` policy required by `aws login`, password and MFA self-management, and access-key deletion. SSH public-key and service-specific credential management are not granted by default.
   For virtual MFA self-service, use a device name **exactly matching the IAM username**. The policy restricts virtual MFA creation, tagging, and deletion to that name. Existing devices with other names require administrator-assisted cleanup.
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
