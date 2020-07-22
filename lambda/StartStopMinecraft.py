import json
import boto3

region = 'us-west-1'
instances = ['i-021869b2f1e4e523d']
ec2 = boto3.client('ec2', region_name=region)
sns = boto3.client('sns', region_name="us-west-2")

def lambda_handler(event, context):
    print("Event:", event)

    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))

    sns.publish(
        TopicArn="arn:aws:sns:us-west-2:252475162445:MinecraftCosmos",
        Message="Minecraft Cosmos has launched a server! Join at mc.cryo3.net!"
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Cosmos launched successfully!')
    }
