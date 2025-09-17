#!/bin/sh


for OUTPUT in $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --output text --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value | [0], `k8s`)].InstanceId')
do
    aws ec2 stop-instances --instance-ids ${OUTPUT}   
done