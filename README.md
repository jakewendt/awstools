# aws_scripts


##	Requirements

awscli and jq installed






aws --profile default ec2 describe-images --owners self --query Images[].ImageId


aws --profile default ec2 describe-images --owners self | jq '.Images[].ImageId' | tr -d '"'
=> ami-665f9006


can't filter by Linux!


