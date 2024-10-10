import boto3
import os

# Initialize the SSM and EC2 clients
ssm_client = boto3.client('ssm')
ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

# Fetch the latest Bottlerocket AMI details
def get_ami_details(eks_version, architecture):
    parameter_name = f"/aws/service/bottlerocket/aws-k8s-{eks_version}/{architecture}/latest/image_id"
    ami_version_name = f"/aws/service/bottlerocket/aws-k8s-{eks_version}/{architecture}/latest/image_version"
    
    ami_id = ssm_client.get_parameter(Name=parameter_name)['Parameter']['Value']
    ami_version = ssm_client.get_parameter(Name=ami_version_name)['Parameter']['Value']

    ami_details = ec2_client.describe_images(ImageIds=[ami_id])
    image = ami_details['Images'][0]
    creation_date = image.get('CreationDate', 'N/A')
    deprecation_time = image.get('DeprecationTime', 'N/A')

    return {
        'AMI_ID': ami_id,
        'AMI_VERSION': ami_version,
        'Creation Date': creation_date,
        'Deprecation Time': deprecation_time
    }

# Send SNS Notification
def send_sns_notification(ami_details):
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']  # SNS topic ARN from environment variables
    message = (
        f"AMI ID: {ami_details['AMI_ID']}\n"
        f"AMI Version: {ami_details['AMI_VERSION']}\n"
        f"Creation Date: {ami_details['Creation Date']}\n"
        f"Deprecation Time: {ami_details['Deprecation Time']}"
    )
    response = sns_client.publish(
        TopicArn=sns_topic_arn,
        Subject="Bottlerocket AMI Details",
        Message=message
    )
    return response

def lambda_handler(event, context):
    ami_details = get_ami_details('1.29', 'x86_64')
    sns_response = send_sns_notification(ami_details)
    return {
        'statusCode': 200,
        'body': sns_response
    }
