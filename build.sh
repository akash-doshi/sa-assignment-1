#! /bin/sh

# Figure out AWS profile to use
[[ -z "${AWS_PROFILE}" ]] && profile='default' || profile="${AWS_PROFILE}"
[[ -z "${2}" ]] && profile=$profile || profile="${2}"

# Figure out install region
[[ -z "${AWS_DEFAULT_REGION}" ]] && region='eu-west-1' || region="${AWS_DEFAULT_REGION}"
[[ -z "${1}" ]] && region=$region || region="${1}"
account=`aws sts get-caller-identity --output text --query Account --profile ${profile}`
bucket_name="stackset-resource-${account}-${region}"
bucket_prefix='templates'

CANDIDATENAME="Akash Doshi"
STACKNAME="sa-assignment"
REGION="eu-west-1"

OLD="template.yaml"
NEW="template-new.yaml"

DIR="file://$(pwd)"

echo "Creating/validating bucket ${bucket_name}"
aws s3 mb s3://${bucket_name} \
  --region $REGION \
  --profile ${profile}

echo "Deploying function code to S3 location: ${bucket_name}/${bucket_prefix}"
aws cloudformation package \
  --template-file template.yaml \
  --s3-bucket ${bucket_name} \
  --s3-prefix 'templates' \
  --output-template-file packaged-template.yaml \
  --force-upload \
  --region $REGION \
  --profile ${profile}

echo "Deploying packaged template to stack in $region"
aws cloudformation deploy \
  --template-file packaged-template.yaml \
  --stack-name StackSetCustomResource \
  --capabilities CAPABILITY_IAM \
  --region ${region} \
  --profile ${profile}

echo "Done"
pause
cmd /k