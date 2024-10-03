

AMI_ID=$(aws ssm get-parameter --name "/aws/service/bottlerocket/aws-k8s-1.29/x86_64/latest/image_id" --query "Parameter.Value" --output text)

AMI_DETAILS=$(aws ec2 describe-images --image-ids $AMI_ID --query "Images[0].[ImageId,CreationDate,Name]" --output text)



AMI_NAME=$(echo $AMI_DETAILS | awk '{print $3}')
VERSION=$(echo $AMI_NAME | grep -oP '(v[0-9]+\.[0-9]+\.[0-9]+)')
CREATION_DATE=$(echo $AMI_DETAILS | awk '{print $2}')

echo "AMI ID: $AMI_ID"
echo "Creation Date: $CREATION_DATE"
echo "Bottlerocket Version: $VERSION"

