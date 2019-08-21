#!/usr/bin/env bash

set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail




profile=""
region=""

#	Use -r to remove double quotes instead of tr -d '"'

#vpcid=$(aws $profile $region ec2 describe-vpcs --filters "Name=isDefault,Values=true" | jq '.Vpcs[].VpcId' | tr -d '"')
vpcid=$(aws $profile $region ec2 describe-vpcs --filters "Name=isDefault,Values=true" | jq -r '.Vpcs[].VpcId' )

echo "VPC ID: ${vpcid}"

sg=$(aws $profile $region ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcid,Name=description,Values=default VPC security group")
#sgid=$(echo $sg | jq '.SecurityGroups[].GroupId' | tr -d '"')
sgid=$(echo $sg | jq -r '.SecurityGroups[].GroupId' )
echo "Security Group Id: ${sgid}"






subnets=$(aws $profile $region ec2 describe-subnets --filters "Name=vpc-id,Values=${vpcid}"  )
#subnet_ids=$( echo $subnets | jq '.Subnets[].SubnetId' | paste -s -d',' | tr -d '"' )
subnet_ids=$( echo $subnets | jq -r '.Subnets[].SubnetId' | paste -s -d',' )
echo "Subnet IDs"
echo $subnet_ids


aws batch create-compute-environment --compute-environment-name CompEnv --type MANAGED --state ENABLED \
	--service-role arn:aws:iam::228985651235:role/service-role/AWSBatchServiceRole \
	--compute-resources "type=SPOT,minvCpus=0,maxvCpus=256,desiredvCpus=0,instanceTypes=optimal,subnets=${subnet_ids},securityGroupIds=${sgid},instanceRole=ecsInstanceRole,bidPercentage=10,spotIamFleetRole=arn:aws:iam::228985651235:role/SpotFleetRole"




aws batch create-job-queue --job-queue-name JobQueue --priority 100 \
	--compute-environment-order order=1,computeEnvironment=CompEnv






#	aws batch register-job-definition --job-definition-name sleep30 --type container \
#		--container-properties '{ "image": "gwendt/fetch_and_run", "vcpus": 1, "memory": 500, "command": [ "sleep", "30"]}'





