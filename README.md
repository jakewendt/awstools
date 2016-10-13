# aws


##	Requirements

[awscli](https://aws.amazon.com/cli/) and [jq](https://github.com/stedolan/jq) installed


###	AWS CLI Configure

The AWS CLI is capable of working with multiple keys, for example if you work on multiple projects.

Simply configure each with ...

`aws configure --profile syryu`

... specifying a given profile name.
This profile name MUST be used with each aws call.



###	Start EC2 Instance

This script finds the appropriate subnet, security group and AMI.

`create_ec2_instance.bash --key ~/.aws/JakeSYRyu.pem  --profile syryu`

