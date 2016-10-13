# aws


##	Requirements

[awscli](https://aws.amazon.com/cli/) and [jq](https://github.com/stedolan/jq) installed







aws --profile default ec2 describe-images --owners self --query Images[].ImageId


aws --profile default ec2 describe-images --owners self | jq '.Images[].ImageId' | tr -d '"'
=> ami-665f9006


can't filter by Linux!


