set -e 
working_folder=$(pwd)

log_action() {
    echo "${1^^} ..."
}

log_key_value_pair() {
    echo "    $1: $2"
}

set_up_aws_user_credentials() {
    unset AWS_SESSION_TOKEN
    export AWS_DEFAULT_REGION=$1
    export AWS_ACCESS_KEY_ID=$2
    export AWS_SECRET_ACCESS_KEY=$3
}

assume_role() {
    local CREDENTIALS_FILE_NAME="aws-credentials-$(basename "$0").json"
    if [[ ! -f "$CREDENTIALS_FILE_NAME" ]]; then
        local AWS_ACCOUNT_ID=$1
        local role_name=$2
        local ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$role_name"
        aws sts assume-role --role-arn $ROLE_ARN --role-session-name github-session > $CREDENTIALS_FILE_NAME
    fi

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' $CREDENTIALS_FILE_NAME)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' $CREDENTIALS_FILE_NAME)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' $CREDENTIALS_FILE_NAME)
}   

log_action "deploying cloudformation stack"

while getopts "a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:" flag
do
    case "${flag}" in
       a) region=${OPTARG};;
       b) access_key=${OPTARG};;
       c) secret_key=${OPTARG};;
       d) account_id=${OPTARG};;
       e) role_name=${OPTARG};;
       f) stack_name=${OPTARG};;
       g) template_body_path=${OPTARG};;
       h) cfn_parameters_path=${OPTARG};;
       i) stage=${OPTARG};;
       j) repository_url=${OPTARG};;
       k) client=${OPTARG};;
       l) service=${OPTARG};;
       m) service_group=${OPTARG};;
       n) team=${OPTARG};;
       o) datadog=${OPTARG};;
    esac
done

template_body="$working_folder/$template_body_path"
cfn_parameters_file="$working_folder/$cfn_parameters_path"

log_key_value_pair "region" $region
log_key_value_pair "access-key" $access_key
log_key_value_pair "account-id" $account_id
log_key_value_pair "role-name" $role_name
log_key_value_pair "stack-name" $stack_name
log_key_value_pair "template-body" $template_body
log_key_value_pair "cfn-parameters-file" $cfn_parameters_file
log_key_value_pair "stage" $stage
log_key_value_pair "repository-url" $repository_url
log_key_value_pair "client" $client
log_key_value_pair "service" $service
log_key_value_pair "service-group" $service_group
log_key_value_pair "team" $team
log_key_value_pair "datadog" $datadog

set_up_aws_user_credentials $region $access_key $secret_key
assume_role $account_id $role_name

stack=$(aws cloudformation describe-stacks --stack-name $stack_name | jq -r '.Stacks[0]')
stack_file="stack-file.json"
if [ -z "$stack" ]; 
then
    log_action "creating stack"
    aws cloudformation create-stack \
        --tags Key=Stage,Value=$stage \
               Key=IacRepo,Value=$repository_url \
               Key=Client,Value=$client \
               Key=Service,Value=$service \
               Key=ServiceGroup,Value=$service_group \
               Key=Team,Value=$team \
               Key=Datadog,Value=$datadog \
        --stack-name $stack_name \
        --template-body "file://$template_body" \
        --parameters "file://$cfn_parameters_file" \
        --capabilities "CAPABILITY_NAMED_IAM" >> $stack_file
    stack_arn=$(jq -r '.StackId' $stack_file)
    log_key_value_pair "stack-arn" $stack_arn
    aws cloudformation wait stack-create-complete \
        --stack-name $stack_arn
else
    log_action "updating stack"
    aws cloudformation update-stack \
        --tags Key=Stage,Value=$stage \
               Key=IacRepo,Value=$repository_url \
               Key=Client,Value=$client \
               Key=Service,Value=$service \
               Key=ServiceGroup,Value=$service_group \
               Key=Team,Value=$team \
               Key=Datadog,Value=$datadog \
        --stack-name $stack_name \
        --template-body "file://$template_body" \
        --parameters "file://$cfn_parameters_file" \
        --capabilities "CAPABILITY_NAMED_IAM" >> $stack_file
    stack_arn=$(jq -r '.StackId' $stack_file)
    log_key_value_pair "stack-arn" $stack_arn
    aws cloudformation wait stack-update-complete \
        --stack-name $stack_arn
fi