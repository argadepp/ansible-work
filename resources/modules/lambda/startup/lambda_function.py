import json
import boto3

ec2 = boto3.resource('ec2', region_name='ap-south-1')

def lambda_handler(event, context):
    # Filter for instances that are stopped and have the tag auto-start-stop set to 'Yes'
    instances = ec2.instances.filter(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['stopped']},
            {'Name': 'tag:auto-start-stop', 'Values': ['Yes']}
        ]
    )
    
    # Start each instance
    for instance in instances:
        instance_id = instance.id
        ec2.instances.filter(InstanceIds=[instance_id]).start()
        print("Instance ID started: " + instance_id)
    
    return "success"