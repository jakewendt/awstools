
Slowly ...

```BASH
aws ec2 describe-images --owners amazon > amazon.images

cat amazon.images | jq '.Images |
	sort_by(.CreationDate) |
	map(select(.Platform != "windows")) |
	map(select(.ImageType == "machine")) |
	map(select(.VirtualizationType == "hvm")) |
	map(select(.RootDeviceType == "ebs")) |
	map(select(.Description)) |
	map(select( .Description | test("^Amazon Linux AMI"))) |
	map(select((.BlockDeviceMappings | length) == 1)) |
	map(select(.BlockDeviceMappings[0].Ebs.VolumeType == "gp2")) | length'

#	28

```

