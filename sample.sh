#!/bin/bash
N=("dev" "qas" "preprod" "prod")
INSTANCE_TYPE=""
ami_id=ami-03265a0778a880afb
sg_id=sg-0cb4841e0108eb3f0
subnet_id=subnet-0b7e209a25659cded
hosted_zone_id=Z05900492SKJC57XITYE4
domain_name=padmasrikanth.tech
for i in ${N[@]}
do
    if [[ $i == "preprod" || $i == "prod" ]]
    then 
    INSTANCE_TYPE=t3.micro
    else
    INSTANCE_TYPE=t2.micro
    fi
    instance_ids=$(aws ec2 describe-instances --filters Name=tag:Name,Values="'$i'" | jq -r '.Reservations[].Instances[].InstanceId')
    for instance_id in $instance_ids
    do
        running=$(aws ec2 describe-instances --instance-ids $instance_id | jq -r '.Reservations[].Instances[].State.Name')
            if [ "$running" == "running" ]
            then 
                echo "The EC2 instance $i --> $instance_id is already running. Not launching a new instance."
                exit 1
            fi
    done
    echo "Creating $i instance"
    j=$(aws ec2 run-instances --image-id $ami_id --instance-type $INSTANCE_TYPE --security-group-ids $sg_id --subnet-id $subnet_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "Respective private for the $i instance is $j" 
    aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
    {
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$i.$domain_name'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [{ "Value": "'$j'"}]
                }
            }
        ]
    }'
done

