#!/bin/bash

## AWS Config
stackName="MinecraftCosmos"
stackTemplate="MinecraftCosmosCFT.yaml"
lambdaRootS3Bucket="minecraft-cosmos"
lambdaRootS3Key="lambda"

## Local Config
lambdaFolder="lambda"
buildRoot="build"
## -----------

# Make sure we're running from repository root
if [[ ! -d "$lambdaFolder" ]]; then
  echo "Couldn't find lambda dir \"$lambdaFolder\", are we running from project root?"
  exit
fi

# Clean build dir
rm -r $buildRoot
mkdir $buildRoot
mkdir $buildRoot/$lambdaFolder
echo "Cleaned build directory"

# Zip up lambdas
for i in "$lambdaFolder"/*; do
  if test -f "$i"; then
    filenameAndExtension=${i##*/}                        # strip folders
    filename=${filenameAndExtension%.*}                  # strip extension
    zip -q $buildRoot/$lambdaFolder/"$filename".zip "$i" # zip file alone
  fi
done
echo "Created lambda zips"

# Upload lambdas
for i in "$buildRoot/$lambdaFolder"/*; do
  if test -f "$i"; then
    filenameAndExtension=${i##*/}
    aws s3 cp "$i" s3://$lambdaRootS3Bucket/$lambdaRootS3Key/"$filenameAndExtension"
  fi
done
echo "Uploaded lambdas to S3"

# Try to update cloudformation
output=$(aws cloudformation update-stack --stack-name $stackName --template-body file://$stackTemplate --capabilities CAPABILITY_NAMED_IAM)

if [[ $output == *"does not exist"* ]]; then # Stack doesn't exist, need to create it. No need to update lambdas since they haven't been created
  echo "Stack didn't exist, will create it now"
  aws cloudformation create-stack --stack-name $stackName --template-body file://$stackTemplate --capabilities CAPABILITY_NAMED_IAM

else
  echo "Now updating lambdas"
  # Now update the lambdas
  for i in "$buildRoot/$lambdaFolder"/*; do
    if test -f "$i"; then
      filenameAndExtension=${i##*/}
      filename=${filenameAndExtension%.*}
      aws lambda update-function-code --function-name "$filename" --s3-bucket $lambdaRootS3Bucket --s3-key $lambdaRootS3Key/"$filenameAndExtension"
    fi
  done
  echo "Updated all lambdas"
fi
