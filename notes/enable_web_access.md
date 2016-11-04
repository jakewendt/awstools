#	Enable Web Access

From the instance, the httpd package needs installed and the service started.

```BASH
sudo yum install httpd
sudo service httpd start
```

The service can be set to autostart with something like ...
```BASH
sudo chkconfig --level 345 httpd on
```

You'll probably want to create a new AMI once these changes are made.



From anywhere, the security group that the instance uses needs to have port 80 openned.

```BASH
aws --profile $profile ec2 authorize-security-group-ingress \
	--protocol tcp --port 80 --cidr 0.0.0.0/0 \
	--group-id $sgid
```

