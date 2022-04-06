# CREATE-OR-UPDATE-CFN-STACK-GH-ACTION

Repository containing Ohpen's Github Action to create or update cloudformation stack with Ohpen standard.

<!-- vscode-markdown-toc -->
* [code-of-conduct](#code-of-conduct)
	* [github-action](#github-action)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=false
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


## <a name='code-of-conduct'></a>code-of-conduct

Go crazy on the pull requests :) ! The only requirements are:

> - Use [conventional-commits](#check-conventional-commits).
> - Include [jira-tickets](#check-jira-tickets-commits) in your commits.
> - Create/Update the documentation of the use case you are creating, improving or fixing. **[Boy scout](https://biratkirat.medium.com/step-8-the-boy-scout-rule-robert-c-martin-uncle-bob-9ac839778385) rules apply**. That means, for example, if you fix an already existing workflow, please include the necessary documentation to help everybody. The rule of thumb is: _leave the place (just a little bit)better than when you came_.

### <a name='github-action'></a>github-action

This action will create or update cloudformation stack in AWS account. The action is build to get json file as cloudformation parameters. For more information about Cloudformation parameters see [docu](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)

On backend action is built as shell script implementing [aws cli](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/index.html#cli-aws-cloudformation) 

example usage:

```yaml
name: CD
on:
  push:
    branches: ["main"]
jobs:
    build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
       - name: create-or-update-stack
        uses: ohpensource/create-or-update-cfn-stack-gh-action@v0.0.2
        with:
          region: ${{ secrets.AWS_REGION }}
          access-key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          secret-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          account: ${{steps.get-properties.outputs.account_id}}
          role-name: <ROLE_NAME>
          stack-name: <NAME OF THE STACK TO UPDATE>
          template-body-path: <PATH TO THE CFN TEMPLATE>
          cfn-parameters-path: <PATH TO THE PARAMETERS JSON FILE>
          
```