#!/usr/bin/env bash

set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail


#	Use -r to remove double quotes instead of tr -d '"'



for ce in $( aws batch describe-job-queues  | jq -r '.jobQueues | map(select( .state == "ENABLED" ).jobQueueName)[] ' ) ; do
	echo ${ce}

	aws batch update-job-queue --job-queue ${ce} --state DISABLED

done

#	It takes a few to DISABLE

sleep 10

for ce in $( aws batch describe-job-queues  | jq -r '.jobQueues | map(select( .state == "DISABLED" ).jobQueueName)[] ' ) ; do
	echo ${ce}

	aws batch delete-job-queue --job-queue ${ce}

done




for ce in $( aws batch describe-compute-environments  | jq -r '.computeEnvironments | map(select( .state == "ENABLED" ).computeEnvironmentName)[] ' ) ; do
	echo ${ce}

	aws batch update-compute-environment --compute-environment ${ce} --state DISABLED

done

#	It takes a few to DISABLE

sleep 10

for ce in $( aws batch describe-compute-environments  | jq -r '.computeEnvironments | map(select( .state == "DISABLED" ).computeEnvironmentName)[] ' ) ; do
	echo ${ce}

	aws batch delete-compute-environment --compute-environment ${ce}

done


