#!/usr/bin/env bash

set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail

#	Use -r to remove double quotes instead of tr -d '"'

#existing_roles=$( aws iam list-roles | jq '.Roles[].RoleName' | paste -s -d' ' | tr -d '"' )
existing_roles=$( aws iam list-roles | jq -r '.Roles[].RoleName' | paste -s -d' ' )
#	"AWSServiceRoleForSupport" "AWSServiceRoleForTrustedAdvisor"
echo "Existing roles:"
echo $existing_roles


if [[ " ${existing_roles} " =~ " batchJobRole " ]]; then
	echo "batchJobRole exists."
else
	echo "batchJobRole doesn't exist. Creating."
	aws iam create-role --role-name batchJobRole \
		--assume-role-policy-document file://AssumeRolePolicyDocumentECSTasks.json \
		--description "Allows ECS tasks to call AWS services on your behalf."
	aws iam attach-role-policy --role-name batchJobRole \
		--policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
fi


if [[ " ${existing_roles} " =~ " ecsInstanceRole " ]]; then
	echo "ecsInstanceRole exists."
else
	echo "ecsInstanceRole doesn't exist. Creating."
	aws iam create-role --role-name ecsInstanceRole \
		--assume-role-policy-document file://AssumeRolePolicyDocumentEC2.json \
		--description "For Compute Environment"
	aws iam attach-role-policy --role-name ecsInstanceRole \
		--policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
fi


if [[ " ${existing_roles} " =~ " AWSBatchServiceRole " ]]; then
	echo "AWSBatchServiceRole exists."
else
	echo "AWSBatchServiceRole doesn't exist. Creating."
	aws iam create-role --role-name AWSBatchServiceRole --path "/service-role/" \
		--assume-role-policy-document file://AssumeRolePolicyDocumentBatch.json \
		--description "For Compute Environment"
	aws iam attach-role-policy --role-name AWSBatchServiceRole \
		--policy-arn arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole
fi


if [[ " ${existing_roles} " =~ " SpotFleetRole " ]]; then
	echo "SpotFleetRole exists."
else
	echo "SpotFleetRole doesn't exist. Creating."
	aws iam create-role --role-name SpotFleetRole \
		--assume-role-policy-document file://AssumeRolePolicyDocumentSpotFleet.json
	aws iam attach-role-policy --role-name SpotFleetRole \
		--policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole
fi


if [[ " ${existing_roles} " =~ " AWSServiceRoleForECS " ]]; then
	echo "AWSServiceRoleForECS exists."
else
	echo "AWSServiceRoleForECS doesn't exist. Creating."
	aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
#	aws iam attach-role-policy --role-name AWSServiceRoleForECS \
#		--policy-arn arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy
fi


