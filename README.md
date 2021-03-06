# From Mysql to Couchbase with Talend

Talend is a well known ETL tools used by a large number of company. As it is a comprehensive enterprise software suite, we will focus only on how migrate data from a relational model to Couchbase with Talend Community Edition through Talend Open Studio Data Integration.

Talend Open Studio wrap Eclipse IDE and offers a tool to graphically design java jobs. You can also control the generated java code. Talend Open Studio needs a strong Desktop environment and must be configured to take benefits of the resources where it is installed.

## Use case

From a MySQL Server prepopulated with a sample dataset available on [github](https://github.com/datacharmer/test_db), we will migrate all data to a Couchbase cluster "as is" :

- The database will be migrated in a couchbase bucket,
- Schema in a couchbase scope
- Each table in couchbase collections

The environment is deployed in aws.  
![Labs](https://github.com/raphael-chir/couchbase-talend-migration/blob/main/usecase-schema.png?raw=true)

Source database model can be seen as an aggregate domain of employees. We will integrate it into a scope.
![Labs](https://dev.mysql.com/doc/employee/en/images/employees-schema.png)

## Quick start

Use the link https://codesandbox.io/s/github/raphael-chir/couchbase-talend-migration to setup a vscode integrated development runtime environment, it contains aws-cli, terraform commands and everything you need to operate the demo, for more details go to section "Keep control on your cloud resources". However you can clone the repository and manage your own installations.  
The purpose is to automatically deploy infrastructure and install these components :

- Mysql server v8
- A desktop environment with Talend Open Studio installed
- Couchbase 7 cluster containing 3 data nodes

### Infrastructure setup

Use aws configure command to provide your credentials.
Create an S3 bucket that holds the terraform state file.
Go to tf-playground folder. Firstly in main.tf, give your S3 bucket name and choose a key name for tfstate file which will be created and used by terraform

```bash
# Example of shared tfstate
terraform {
  backend "s3" {
    region = "eu-north-1"
    key    = "couchbase-talend-migration-tfstate"
    bucket = "a-tfstate-rch"
  }
}
```

In tf-playground/terraform.tfvars define the aws region where infrastructure will be deployed and configure resource tags.
Note : the amis used in this demo must be adapted for your region. See "How to choose your OS AMI" section below.

### MySQL 8 Setup

In tf-playground/terraform.tfvars replace values with yours :

```bash
mysql_configuration = {
  new_root_pass               = "Route66!"
  client_username             = "mcfly"
  client_password             = "Zak3306!"
  client_cidr                 = "91.175.201.225"
  private_net_client_username = "talend"
  private_net_client_password = "Talend2022!"
  private_net_client_cidr     = "10.0.0.0/28"
}
```

1. A new root pass is mandatory to operate database.
2. Create remote administrator credentials : give a username and a password.
3. Define remote administrator cidr, it can be IPV4 or IPV6 addresses, or a network range IPs, but the best practice is to restrict to your IP.
4. Define application credentials, here we give a range of private ips authorized to connect to mysql.

Take a look at tf-playground/scripts/mysql-init.sh to see how it works.

### Talend Studio

Talend Open Studio for Data Integration (CE) will be installed on a t32xlarge (8vCPU - 32G RAM), this can be adjust for your needs, but Talend is built on top of Eclipse and need resource to work in comfortable conditions. The OS used is Ubuntu 18-04 with lxde graphical.
The installation is automatic so when finished you can use your favorite rdp client to connect to the workstation. Use ubuntu/ubuntu default credentials and modify your password to securize if needed (we are still in a demo).
Take a look at tf-playground/scripts/talend-studio-init.sh to see how it works.

Couchbase connectors are installed but for more possibilities in the logic data loading, it is better to use couchbase java sdk. Here are the libraries needed :

[INFO] +- com.couchbase.client:java-client:jar:3.3.0:compile
[INFO] | \- com.couchbase.client:core-io:jar:2.3.0:compile
[INFO] | +- io.projectreactor:reactor-core:jar:3.4.17:compile
[INFO] | \- org.reactivestreams:reactive-streams:jar:1.0.3:compile
[INFO] \- com.couchbase.client:couchbase-transactions:jar:1.2.4:compile

### Couchbase 7

In tf-playground/terraform.tfvars replace values with yours :

```bash
couchbase_configuration = {
  cluster_name    = "terracluster-playgound"
  cluster_username  = "admin"
  cluster_password  = "111111"
}
```

### Deploy the stack

Once everything is done, check aws configure and cd into tf-playground, lauch these commands :

```bash
tf init
tf validate
tf plan
tf apply -auto-approve
```

## Keep control on your cloud resources

| ![Labs](https://learn.hashicorp.com/_next/static/images/color-c0fe8380afabc1c58f5601c1662a2e2d.svg) | This demo shows you how to automate your architecture implementation in a **Cloud DevOps** approach with [Terraform](https://www.terraform.io/). |
| :-------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| **terraform**                                                                                       | Terraform >= 1.1.9 (an alias tf is create for terraform cli)                                                                                     |
| **aws**                                                                                             | aws cli v2 (WARNING : you are responsible of your access key, don't forget to deactivate or suppress it in your aws account !)                   |

## First check

Please check that everything is alright. Open a terminal in your sandbox and test environment

### Open a terminal and check terraform cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ terraform version
Terraform v1.1.9
on linux_amd64
```

### Check aws cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws --version
aws-cli/2.6.1 Python/3.9.11 Linux/5.13.0-40-generic exe/x86_64.debian.10 prompt/off
```

You need to configure your AWS access key. **Don't forget to delete or deactivate your access key in IAM, once you have finished this demo !**

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXxxxxxxxxxxxxxxxxxXXXxxxxxxxxxXXxxxxxxx
Default region name [None]: eu-north-1
Default output format [None]:
```

### Doc as code

Generate html page from Readme.md to show in integrated browser (CodeSandbox)

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ node md2html.js
```

## Terraform backend

All terraform state files are stored and shared in a dedicated S3 bucket. Create if needed your own bucket.

```bash
aws s3api create-bucket --bucket a-tfstate-rch --create-bucket-configuration LocationConstraint=eu-north-1 --region eu-north-1
aws s3api put-bucket-tagging --bucket a-tfstate-rch --tagging 'TagSet=[{Key=Owner,Value=raphael.chir@couchbase.com},{Key=Name,Value=terraform state set}]'
```

Refer your bucket in your terraform backend configuration.
**Specify a key for your project !**

```bash
terraform {
  backend "s3" {
    region  = "eu-north-1"
    key     = "myproject-tfstate"
    bucket  = "a-tfstate-rch"
  }
}
```

## Tag tag tag, ..

More than a best practice, it is essential for inventory resources, cost explorer, etc .. Open terraform.tfvars and update these values

```bash
resource_tags = {
  project     = "myproject"
  environment = "staging-rch"
  owner       = "raphael.chir@couchbase.com"
}
```

## SSH Keys

### Generate

We need to generate key pair in order to ssh into instances. Create a .ssh folder in tf-playground.
[SSH Academy](https://www.ssh.com/academy/ssh/keygen#creating-an-ssh-key-pair-for-user-authentication)

Open a terminal and paste this default command

```bash
ssh-keygen -q -t rsa -b 4096 -f /sandbox/tf-playground/.ssh/zkey -N ''
```

Change if needed ssh_keys_path variable in terraform.tvars  
Run this command, if necessary, to ensure your key is not publicly viewable.

```bash
chmod 400 zkey
```

### Choosing an Algorithm and Key Size

SSH supports several public key algorithms for authentication keys. These include:

**rsa** - an old algorithm based on the difficulty of factoring large numbers. A key size of at least 2048 bits is recommended for RSA; 4096 bits is better. RSA is getting old and significant advances are being made in factoring. Choosing a different algorithm may be advisable. It is quite possible the RSA algorithm will become practically breakable in the foreseeable future. All SSH clients support this algorithm.

**dsa** - an old US government Digital Signature Algorithm. It is based on the difficulty of computing discrete logarithms. A key size of 1024 would normally be used with it. DSA in its original form is no longer recommended.

**ecdsa** - a new Digital Signature Algorithm standarized by the US government, using elliptic curves. This is probably a good algorithm for current applications. Only three key sizes are supported: 256, 384, and 521 (sic!) bits. We would recommend always using it with 521 bits, since the keys are still small and probably more secure than the smaller keys (even though they should be safe as well). Most SSH clients now support this algorithm.

**ed25519** - this is a new algorithm added in OpenSSH. Support for it in clients is not yet universal. Thus its use in general purpose applications may not yet be advisable.

The algorithm is selected using the -t option and key size using the -b option. The following commands illustrate:

```bash
ssh-keygen -t rsa -b 4096
ssh-keygen -t dsa
ssh-keygen -t ecdsa -b 521
ssh-keygen -t ed25519
```

## How to choose your OS AMI

### From AWS console

You can just copy from aws console the **ami-id** needed.  
e.g : '_Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20_' is **ami-01ded35841bc93d7f**

### Advanced search

For specific search based on filters you can also use this command.
Based on this metadata structure below or see
[aws ec2 describe-images details](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-images.html)  
[Another link](https://docs.aws.amazon.com/sdkfornet1/latest/apidocs/html/P_Amazon_EC2_Model_DescribeImagesRequest_Filter.htm)

```bash
[
    {
        "Architecture": "x86_64",
        "CreationDate": "2022-04-21T14:55:48.000Z",
        "ImageId": "ami-01ded35841bc93d7f",
        "ImageLocation": "099720109477/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420",
        "ImageType": "machine",
        "Public": true,
        "OwnerId": "099720109477",
        "PlatformDetails": "Linux/UNIX",
        "UsageOperation": "RunInstances",
        "State": "available",
        "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/sda1",
                "Ebs": {
                    "DeleteOnTermination": true,
                    "SnapshotId": "snap-0bc2203755d33f5f6",
                    "VolumeSize": 8,
                    "VolumeType": "gp2",
                    "Encrypted": false
                }
            },
            {
                "DeviceName": "/dev/sdc",
                "VirtualName": "ephemeral1"
            },
            {
                "DeviceName": "/dev/sdb",
                "VirtualName": "ephemeral0"
            }
        ],
        "Description": "Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20",
        "EnaSupport": true,
        "Hypervisor": "xen",
        "Name": "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420",
        "RootDeviceName": "/dev/sda1",
        "RootDeviceType": "ebs",
        "SriovNetSupport": "simple",
        "VirtualizationType": "hvm",
        "DeprecationTime": "2024-04-21T14:55:48.000Z"
    }
]
```

You can find specific ami with this command

```bash
aws ec2 describe-images --region eu-north-1 --query "Images[*].[Description,ImageId]" --filters"Name=name,Values=ubuntu*" "Name=creation-date,Values=2022*" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=block-device-mapping.volume-type,Values=gp2" "Name=image-type,Values=machine" "Name=state,Values=available" "Name=description,Values=*Ubuntu*22.04*"
```

Or write it into a file

```bash
echo $(aws ec2 describe-images --region eu-north-1 --query "Images[*].[Description,ImageId]" --filters "Name=name,Values=ubuntu*" "Name=creation-date,Values=2022*" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=block-device-mapping.volume-type,Values=gp2" "Name=image-type,Values=machine" "Name=state,Values=available" "Name=description,Values=*Ubuntu*22.04*")>ami.json
```

Use list to see all namespaces

```bash
aws ssm get-parameters-by-path \
--path /aws/service/ami-amazon-linux-latest \
--query 'Parameters[].Name' --region eu-north-1
```
