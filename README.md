# MinecraftCosmosArchitecture

Uploaded zip file should include the code at the top level (not in a folder)
Update lambda with aws lambda update-function-code --function-name StartStopMinecraftAuto --s3-bucket minecraft-cosmos --s3-key lambda.zip
Update cloudformation with aws cloudformation update-stack --stack-name minecraftcosmos --template-body file://stack.yaml --capabilities CAPABILITY_NAMED_IAM
