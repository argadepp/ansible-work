import json
import boto3

ec2 = boto3.resource('ec2', region_name='ap-south-1')
def lambda_handler(event, context):
   instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']},{'Name': 'tag:auto-start-stop','Values':['Yes']}])
   for instance in instances:
       id=instance.id
       ec2.instances.filter(InstanceIds=[id]).stop()
       print("Instance ID is stopped:- "+instance.id)
   return "success"