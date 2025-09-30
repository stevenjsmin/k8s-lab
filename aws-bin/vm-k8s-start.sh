#!/usr/bin/env bash

for OUTPUT in $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --output text --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value | [0], `k8s`)].InstanceId')
do
    aws ec2 start-instances --instance-ids ${OUTPUT}
done

sleep 10

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*k8s*" "Name=instance-state-name,Values=running,pending" \
  --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`]|[0].Value, PublicIP: PublicIpAddress}' \
  --output table