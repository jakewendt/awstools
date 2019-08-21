#!/usr/bin/env bash

set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail

#	Use -r to remove double quotes instead of tr -d '"'

#existing_roles=$( aws iam list-roles | jq '.Roles[].RoleName' | paste -s -d' ' | tr -d '"' )
existing_roles=$( aws iam list-roles | jq -r '.Roles[].RoleName' | paste -s -d' ' )

do_not_delete_roles="AWSServiceRoleForSupport AWSServiceRoleForTrustedAdvisor"

echo "Existing roles:"
echo $existing_roles

#	There does not appear to be any flag to determine if a role is "service-linked"
service_linked_roles="AWSServiceRoleForECS"

for role in ${existing_roles} ; do
	echo "Processing role :${role}:"

	if [[ " ${do_not_delete_roles} " =~ " ${role} " ]]; then
		echo "Skipping ${role}."
	else
	
		if [[ " ${existing_roles} " =~ " ${role} " ]]; then

			if [[ " ${service_linked_roles} " =~ " ${role} " ]] ; then

				#echo "Can't modify service linked roles."
				echo "Deleting service linked role"
				aws iam delete-service-linked-role --role-name ${role}

			else

				#for arn in $( aws iam list-attached-role-policies --role-name $role | jq '.AttachedPolicies[].PolicyArn' | tr -d '"' ) ; do
				for arn in $( aws iam list-attached-role-policies --role-name $role | jq -r '.AttachedPolicies[].PolicyArn' ) ; do
					echo "Detaching Arn:${arn}:"
					aws iam detach-role-policy --role-name ${role} --policy-arn ${arn}
				done

				echo "Deleting role"
				aws iam delete-role --role-name ${role}

			fi
		fi
	fi

done



