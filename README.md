# Terraform ec2 instance with CodeBuild
Simple example of how to provision an EC2 instance with Terraform in AWS CodeBuild

Create a settings file `terraform.auto.tfvars` with the following:
```
echo <<< EOL
aws_access_key = "XXXXXXXXXXXXXXXXXXXX"
aws_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
aws_region = "us-east-1"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU
GPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3
Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA
t3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En
mZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx
NrRFi9wrf+M7Q== my@laptop.local"
vpc_id = "vpc-00000000x00x0xxx0"
terraform_version = "0.9.9"
s3_bucket = "your-s3-bucket-terraform-state"
debug = "true"
EOL >> terraform.auto.tfvars;
```

After you're done creating the above file and adding your `aws access key`, `secret` and your `ssh public key`, run the following:
```
terraform init
terraform plan
echo yes | terraform apply
```
To remove the instance you run:
```
echo yes | terraform destroy
```

After creating your infrastructure in AWS you should find your CodeBase project here:
https://console.aws.amazon.com/codesuite/codebuild/projects?region=us-east-1 
(Change your region in this URL to what you set your `aws_region` variable in your `tfvars` file to.)

You're done and have fun!
