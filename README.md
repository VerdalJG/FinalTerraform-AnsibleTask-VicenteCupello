Terraform + Ansible WordPress deployment

1. Prerequisites
Before running this project, make sure you have the following installed:

Terraform ≥ 1.5.0
Ansible ≥ 7.0
AWS CLI (optional, for testing and credentials verification)
Python ≥ 3.8 (for Ansible)
SSH access to your target machines

Also, ensure you have:
AWS credentials file (aws/credentials) with proper permissions
SSH private key (key-name.pem) for connecting to EC2 instances

2. Execution Steps

You must create a key pair in the AWS Management console webpage and download the .pem that is generated.

You must navigate to ansible.cfg to configure where it should find the SSH private key as such:
private_key_file = /route/key-name.pem

You must also configure where your credentials file is for AWS to pick it up to use with Terraform and Ansible

I recommend using an environment variable for it as such (run this before running the Makefile):
export AWS_SHARED_CREDENTIALS_FILE=/route/aws/credentials

You should change the names of the resources in the Terraform folder (in resources.tf)
Keep in mind you will need to also change the filter in /root/Ansible/aws_ec2.yml so that it can find
your EC2 instances

Now you are ready to simply go into the project root folder and run the Makefile by just running 'make'.

Afterwards you can verify that WordPress is running:
curl -I http://<EC2_PUBLIC_IP>/wordpress/

Expected response:
HTTP/1.1 200 OK

Ansible also includes a post-deploy check task to automatically ensure the service is up.

3. Integration between Ansible and Terraform

This project uses a two-step deployment workflow:

Terraform provisions the infrastructure:
Sets up VPC, subnets, route table, internet gateway and route table associations
Creates EC2 instances
Sets up networking and security groups

Ansible configures the infrastructure:
Installs required packages (Apache, PHP, etc.)
Deploys WordPress
Sets permissions and configurations
Validates deployment

Ansible also uses a dynamic inventory by filtering through your EC2 instances by name and role and
public ip address

Afterwards it executes the respective roles on their respective EC2 instances. 
