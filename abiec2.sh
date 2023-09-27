#!/bin/bash
a=("dev" "qas" "preprod" "prod")
image_id=ami-03265a0778a880afb
INSTANCE_TYPE=""
sg_id=sg-0cb4841e0108eb3f0
subnet_id=subnet-0b7e209a25659cded
hosted_zone_id=Z05900492SKJC57XITYE4
domain_name=padmasrikanth.tech
for i in ${a[@]}
do
    if [[ $i == "preprod" || $i == "prod" ]]
    then
        INSTANCE_TYPE=t3.micro
    else
        INSTANCE_TYPE=t2.micro
    fi
    instance_ids=$(aws ec2 describe-instances --filters Name=tag:Name,Values="'$i'" | jq -r '.Reservations[].Instances[].InstanceId')
        for instance in $instance_ids
        do
            running=$(aws ec2 describe-instances --instance-ids $instance | jq -r '.Reservations[].Instances[].State.Name')
            if [ $running == running ]
            then
                echo " I cant launch new instance because your previous script insatnces are runnng. Please do terminate previous instance and launch the script again"
                exit 1
            fi
        done    
    echo "Creating $i instance"
    b=$(aws ec2 run-instances --image-id $image_id --instance-type $INSTANCE_TYPE --security-group-ids $sg_id --subnet-id $subnet_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo " For $i instance private IP adress is :$b"
    aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
    {
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$i.$domain_name'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [{ "Value": "'$b'"}]
                }
            }
        ]
    }'
done

