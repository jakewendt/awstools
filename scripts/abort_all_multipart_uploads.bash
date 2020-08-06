#!/usr/bin/env bash

script_name=$(basename $0)

function usage(){
	echo
	echo "Delete all partial multipart uploads from bucket"
	echo
	echo "AWS is nice enough to keep any partial uploads in your S3 bucket."
	echo "Of course, they don't show in your bucket."
	echo "You need to dig with the s3api (not the normal s3)."
	echo "These 'files' take up space and you pay for them."
	echo "So, not cool."
	echo
	echo "This script REQUIRES the installation of 'jq', a json parser."
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "$script_name [--profile STRING] BUCKETNAME(s)"
	echo
	echo "Example:"
	echo
	echo "$script_name --profile myprofilename mybucket1 mybucket2"
	echo
	exit
}



profile=""

while [ $# -ne 0 ] ; do
	#	Options MUST start with - or --.
	case $1 in
		-p*|--p*)
			shift; profile="--profile $1"; shift ;;
		-*)
			echo ; echo "Unexpected args from: ${*}"; usage ;;
		*)
			break ;;
	esac
done


while [ $# -ne 0 ] ; do
	bucket=$1
	echo "Clearing ${bucket}"

	uploads=$( aws ${profile} s3api list-multipart-uploads --bucket ${bucket} )

	for id in $( echo ${uploads} | jq -r '.Uploads[].UploadId' ) ; do
		echo $id
		key=$( echo ${uploads} | jq -r '.Uploads | map(select( .UploadId == "'${id}'" ).Key)[]' )
		echo $key
		aws ${profile} s3api abort-multipart-upload --bucket ${bucket} --key "${key}" --upload-id "${id}"
	done

	shift
done



