# aws


##	Requirements

[awscli](https://aws.amazon.com/cli/) and [jq](https://github.com/stedolan/jq) installed


###	AWS CLI Configure

The AWS CLI is capable of working with multiple keys, for example if you work on multiple projects.

Simply configure each with ...

`aws configure --profile herv`

... specifying a given profile name.
This profile name MUST be used with each aws call.








aws --profile default ec2 describe-images --owners self --query Images[].ImageId


aws --profile default ec2 describe-images --owners self | jq '.Images[].ImageId' | tr -d '"'
=> ami-665f9006


can't filter by Linux!


aws --profile default ec2 describe-images --owners self | jq '.Images | select("Platform" != "windows")[].ImageId'


perhaps add (depending on sorting order) to get the latest.
| sort_by(.CreationDate)[].ImageId | tail -1 | tr -d '"'




This is sorted ASCENDING so tail -1 would get the last
aws --profile default ec2 describe-images --owners amazon | jq '.Images | sort_by(.CreationDate) | select("Platform" != "windows")[].CreationDate' 


So MY MOST RECENT NON-WINDOWS AMI ImageId is ...

aws --profile default ec2 describe-images --owners self | jq '.Images | sort_by(.CreationDate) | select("Platform" != "windows")[].ImageId' | tail -1 | tr -d '"'



