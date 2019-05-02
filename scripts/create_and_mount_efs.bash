#!/usr/bin/env bash

script_name=$(basename $0)

function usage(){
	echo
	echo "Create an AWS EFS and mount locally (linux only)"
	echo
	echo "https://aws.amazon.com/blogs/aws/amazon-elastic-file-system-shared-file-storage-for-amazon-ec2/"
	echo "https://docs.aws.amazon.com/efs/latest/ug/efs-onpremises.html"
	echo
	echo "sudo apt install nfs-common"
	echo
	echo "Glacier - ~0.004 / GB / Month"
	echo "S3  - ~0.023 / GB / Month"
	echo "EBS - ~0.100 / GB / Month"
	echo "EFS - ~0.300 / GB / Month"
	echo
	echo "Yep, more expensive, but if works, nice single flexible solution for varying needs"
	echo "like work spaces on large files"
	echo
	echo "Is there a max size limit?"
	echo
	exit
}


#usage



vpcid=$(aws $profile $region ec2 describe-vpcs --filters "Name=isDefault,Values=true" | jq '.Vpcs[].VpcId' | tr -d '"' )

echo "Using VPC ID: ${vpcid}"

sgid=$(aws $profile $region ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpcid,Name=description,Values=default VPC security group" | jq '.SecurityGroups[].GroupId' | tr -d '"')

echo "Using Security Group ID: ${sgid}"

echo "Authorizing NFS connection to Security Group"

aws ec2 authorize-security-group-ingress --protocol tcp --port 2049 --group-id ${sgid} --cidr 0.0.0.0/0



echo "Creating NOT-YET-UNIQUE EFS"
aws efs create-file-system --creation-token SomeIdempotentString



fsid=$( aws efs describe-file-systems | jq 'select(.FileSystems[].CreationToken == "SomeIdempotentString") | .FileSystems[].FileSystemId' |  tr -d '"' )
echo "FSID : ${fsid}"





#	something still missing

#	https://aws.amazon.com/directconnect/




mkdir ~/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${fsid}.efs.us-east-1.amazonaws.com:/ ~/efs

ls -l ~/efs


#umount ~/efs
#aws ec2 revoke-security-group-ingress --protocol tcp --port 2049 --group-id sg-6cdbb917 --cidr 0.0.0.0/0
#aws efs delete-file-system --file-system-id ${fsid}

