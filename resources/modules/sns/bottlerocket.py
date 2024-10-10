import boto3
import os
import re

# Initialize the SSM, EC2, and SNS clients
ssm_client = boto3.client('ssm')
ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

# Function to extract version from the AMI name
def extract_version(ami_name):
    match = re.search(r'-v([\d\.]+)', ami_name)
    return match.group(1) if match else '0.0.0'

# Fetch the latest and previous Bottlerocket AMIs for a specific EKS version and architecture
def get_latest_and_previous_ami(eks_version, architecture):
    # Filter for the AMIs with the given EKS version and architecture
    filters = [
        {'Name': 'name', 'Values': [f"bottlerocket-aws-k8s-{eks_version}-{architecture}-*"]}
    ]
    
    # Fetch all AMIs that match the filter
    response = ec2_client.describe_images(Filters=filters, Owners=['amazon'])
    images = response['Images']
    
    # Sort AMIs by version (extracted from Name)
    sorted_images = sorted(
        images,
        key=lambda image: [int(x) for x in extract_version(image['Name']).split('.')],
        reverse=True
    )
    
    # Select the latest and second latest AMIs
    if len(sorted_images) < 2:
        raise ValueError("Not enough AMIs found to select the latest and previous versions.")
    
    latest_image = sorted_images[0]  # This is the latest AMI
    previous_image = sorted_images[1]  # This is latest - 1
    latest_ami_version = extract_version(latest_image['Name'])
    previous_ami_version = extract_version(previous_image['Name'])

    return {
        'Latest': {
            'AMI_ID': latest_image['ImageId'],
            'AMI_VERSION': latest_ami_version,
            'Creation Date': latest_image.get('CreationDate', 'N/A'),
            'Deprecation Time': latest_image.get('DeprecationTime', 'N/A')
        },
        'Previous': {
            'AMI_ID': previous_image['ImageId'],
            'AMI_VERSION': previous_ami_version,
            'Creation Date': previous_image.get('CreationDate', 'N/A'),
            'Deprecation Time': previous_image.get('DeprecationTime', 'N/A')
        }
    }

# Fetch currently running instance's AMI details
def get_running_instance_ami_details():
    filters = [{'Name': 'tag:eks:cluster-name', 'Values': ['eks']}]
    instances = ec2_client.describe_instances(Filters=filters)['Reservations']
    
    if not instances:
        return {
            'Deprecation Time': 'N/A',
            'AMI ID': 'N/A',
            'AMI Name': 'N/A',
            'AMI Version': 'N/A'
        }
    
    instance = instances[0]['Instances'][0]
    ami_id = instance['ImageId']
    ami_details = ec2_client.describe_images(ImageIds=[ami_id])
    
    if not ami_details['Images']:
        return {
            'Deprecation Time': 'N/A',
            'AMI ID': ami_id,
            'AMI Name': 'N/A',
            'AMI Version': 'N/A'
        }
    
    image = ami_details['Images'][0]
    
    # Extracting the AMI version from the Name field
    ami_name = image.get('Name', 'N/A')
    ami_version = extract_version(ami_name)
    deprecation_time = image.get('DeprecationTime', 'N/A')  # Ensure fetching DeprecationTime

    return {
        'Deprecation Time': deprecation_time,
        'AMI ID': ami_id,
        'AMI Name': ami_name,
        'AMI Version': ami_version
    }

# Send SNS Notification
def send_sns_notification(ami_details, instance_ami_details):
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']  # SNS topic ARN from environment variables
    message = (
        f"Hi Team,\n\n"
        f"Please find below details regarding Bottlerocket AMI (Latest and Previous) and the running instance's AMI details:\n\n"
        f"Latest Bottlerocket AMI Details:\n"
        f"AMI ID: {ami_details['Latest']['AMI_ID']}\n"
        f"AMI Version: {ami_details['Latest']['AMI_VERSION']}\n"
        f"Creation Date: {ami_details['Latest']['Creation Date']}\n"
        f"Deprecation Time: {ami_details['Latest']['Deprecation Time']}\n\n"
        f"Previous Bottlerocket AMI Details:\n"
        f"AMI ID: {ami_details['Previous']['AMI_ID']}\n"
        f"AMI Version: {ami_details['Previous']['AMI_VERSION']}\n"
        f"Creation Date: {ami_details['Previous']['Creation Date']}\n"
        f"Deprecation Time: {ami_details['Previous']['Deprecation Time']}\n\n"
        f"Running Instance AMI Details:\n"
        f"Deprecation Time: {instance_ami_details['Deprecation Time']}\n"
        f"AMI ID: {instance_ami_details['AMI ID']}\n"
        f"AMI Name: {instance_ami_details['AMI Name']}\n"
        f"AMI Version: {instance_ami_details['AMI Version']}"
    )
    
    response = sns_client.publish(
        TopicArn=sns_topic_arn,
        Subject="Bottlerocket AMI (Latest and Previous) and Instance AMI Details",
        Message=message
    )
    return response

def lambda_handler(event, context):
    ami_details = get_latest_and_previous_ami('1.29', 'x86_64')
    instance_ami_details = get_running_instance_ami_details()
    sns_response = send_sns_notification(ami_details, instance_ami_details)
    
    return {
        'statusCode': 200,
        'body': sns_response
    }
