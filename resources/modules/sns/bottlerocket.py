import boto3
import os

# Initialize the SSM, EC2, and SNS clients
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

# Fetch currently running instance's AMI details
def get_running_instance_ami_details():
    filters = [{'Name': 'tag:eks:cluster-name', 'Values': ['eks']}]
    instances = ec2_client.describe_instances(Filters=filters)['Reservations']
    
    if not instances:
        return "No running instances found."

    instance = instances[0]['Instances'][0]
    ami_id = instance['ImageId']
    ami_details = ec2_client.describe_images(ImageIds=[ami_id])
    image = ami_details['Images'][0]
    
    # Extracting the AMI version from the Name field
    ami_name = image.get('Name', 'N/A')
    ami_version = ami_name.split('-v')[-1] if 'v' in ami_name else 'N/A'

    return {
        'Instance ID': instance['InstanceId'],
        'AMI ID': ami_id,
        'AMI Name': ami_name,
        'AMI Version': ami_version
    }

# Send SNS Notification
def send_sns_notification(ami_details, instance_ami_details):
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']  # SNS topic ARN from environment variables
    message = (
        f"Hi Team,\n\n"
        f"Please find below details regarding Bottlerocket AMI and the running instance's AMI details:\n\n"
        f"Latest Bottlerocket AMI Details:\n"
        f"AMI ID: {ami_details['AMI_ID']}\n"
        f"AMI Version: {ami_details['AMI_VERSION']}\n"
        f"Creation Date: {ami_details['Creation Date']}\n"
        f"Deprecation Time: {ami_details['Deprecation Time']}\n\n"
        f"Running Instance AMI Details:\n"
        f"Instance ID: {instance_ami_details['Instance ID']}\n"
        f"AMI ID: {instance_ami_details['AMI ID']}\n"
        f"AMI Name: {instance_ami_details['AMI Name']}\n"
        f"AMI Version: {instance_ami_details['AMI Version']}"
    )
    
    response = sns_client.publish(
        TopicArn=sns_topic_arn,
        Subject="Bottlerocket AMI and Instance AMI Details",
        Message=message
    )
    return response

def lambda_handler(event, context):
    ami_details = get_ami_details('1.29', 'x86_64')
    instance_ami_details = get_running_instance_ami_details()
    sns_response = send_sns_notification(ami_details, instance_ami_details)
    return {
        'statusCode': 200,
        'body': sns_response
    }
