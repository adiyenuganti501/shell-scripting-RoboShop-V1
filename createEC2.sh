#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="khiranya.online"
hosted_zone_id="Z016823019WZ5N3TQQPKW"
if [ "$#" -eq 0 ] ; then
    echo "No arguments provided. Please provide at least one instance name."
    exit 1
fi

for instance in $@
do
 echo "Creating EC2 instance for $instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$ami_id" \
    --instance-type "$instance_type" \
    --security-groups "RS-Common" "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
    --region "us-east-1" \
    --query 'Instances[0].InstanceId' \
    --output text)
 
 echo "Instance ID: $INSTANCE_ID"

 if [ "$instance" != "frontend" ] ; then 
    IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text \
    --region us-east-1)

 r53_record=$instance.$domain_name

else 
   IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region us-east-1)
   
   r53_record=$domain_name
fi

#Update the Route53 record
 echo "Record: ${r53_record}"
 aws route53 change-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --change-batch "{
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$r53_record\",
                \"Type\": \"A\",
                \"TTL\": 60,
                \"ResourceRecords\": [{
                    \"Value\": \"$IP\"
                }]
            }
        }]
    }"

echo "Updated Route53 record for $instance"
done