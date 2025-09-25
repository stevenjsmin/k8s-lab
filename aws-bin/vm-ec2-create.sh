#!/bin/sh

## [t2.micro | t2.small | t2.medium]
INSTANCE_TYPE=t2.micro
#INSTANCE_TYPE=t2.small
# INSTANCE_TYPE=t2.medium

#AMI_ID=ami-01bb2de94edafd6b5
AMI_ID=ami-03297c1192a3624d3

SECURITY_GRP=sg-0bbbd437c66b62068
SUBNET_ID=subnet-0b2836719b6c5fa27


# Create instances
for OUTPUT in $@
do
    aws ec2 run-instances --image-id $AMI_ID --subnet-id $SUBNET_ID --count 1 --instance-type $INSTANCE_TYPE --key-name stevenKey --security-group-ids $SECURITY_GRP --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$OUTPUT}]"
done

sleep 3

# Check running instances
echo "\n\n\nRunning instances........"
#aws ec2 describe-instances  --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PublicIpAddress,PrivateIpAddress,PrivateDnsName,InstanceId,Tags[?Key==`Name`].Value]'
#aws ec2 describe-instances  --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,PrivateDnsName,PublicIpAddress]'
aws ec2 describe-instances  --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PrivateDnsName,PublicDnsName,PublicIpAddress,Tags[?Key==`Name`].Value]'


