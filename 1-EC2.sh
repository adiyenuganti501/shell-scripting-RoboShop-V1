#!/bin/bash

ami_id="ami-0220d79f3f480ecf5"
instance_type="t3.micro"
domain_name="khiranya.online"
hosted_zone_id="Z016823019WZ5N3TQQPKW"

for instance in $@
do
 echo "Creating EC2 instance for $instance..."
done