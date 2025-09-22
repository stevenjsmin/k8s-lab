#!/usr/bin/env bash

for OUTPUT in $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --output text --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value | [0], `k8s`)].InstanceId')
do
    aws ec2 start-instances --instance-ids ${OUTPUT}
done

sleep 10

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running,pending" \
  --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value | [0], `k8s`)].[Tags[?Key==`Name`].Value | [0], PublicIpAddress]' \
  --output table


# AWS CLI에서 PublicIP와 Name을 탭으로 구분해 출력
instances=$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[PublicIpAddress, Tags[?Key==`Name`].Value|[0]]' \
  --output text)
