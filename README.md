# CREATE-OR-UPDATE-CFN-STACK-GH-ACTION

Repository containing Ohpen's Github Action to create or update cloudformation stack with Ohpen standard.

* [code-of-conduct](#code-of-conduct)
  * [github-action](#github-action)

## code-of-conduct

Go crazy on the pull requests :) ! The only requirements are:

> * Use [conventional-commits](#check-conventional-commits).
> * Include [jira-tickets](#check-jira-tickets-commits) in your commits.
> * Create/Update the documentation of the use case you are creating, improving or fixing. **[Boy scout](https://biratkirat.medium.com/step-8-the-boy-scout-rule-robert-c-martin-uncle-bob-9ac839778385) rules apply**. That means, for example, if you fix an already existing workflow, please include the necessary documentation to help everybody. The rule of thumb is: _leave the place (just a little bit)better than when you came_.

### github-action

This action will create or update cloudformation stack in AWS account. The action is build to get json file as cloudformation parameters. For more information about Cloudformation parameters see [docu](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)

On backend action is built as shell script implementing [aws cli](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/index.html#cli-aws-cloudformation)

example usage:

```yaml
name: CD
on:
  push:
    branches: ["main"]
jobs:
    cfn-deployment:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: create-or-update-stack
          uses: ohpensource/create-or-update-cfn-stack-gh-action@v1.0.0
          with:
            region: "eu-west-1"
            access-key: "${{ secrets.COR_CICD_AUTOMATION_AWS_ACCESS_KEY_ID }}"
            secret-key: "${{ secrets.COR_CICD_AUTOMATION_AWS_SECRET_ACCESS_KEY }}"
            account: "543***"
            role-name: "admin-role"
            stack-name: "this-is-a-stack"
            template-body-path: "cfn/template.yaml"
            cfn-parameters-path: "cfn/parameters.json"
            stage: "dev"
            repository-url: "https://github.com/ohpensource/create-or-update-cfn-stack-gh-action"
            client: "me"
            service: "just-for-testing"
            service-group: "main"
            team: "team-A"
            datadog: "false"
```
