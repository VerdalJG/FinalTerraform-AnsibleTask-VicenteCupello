# Terraform + Ansible WordPress Deployment

This project demonstrates a **two-step workflow** for deploying WordPress on AWS using Terraform and Ansible.

- **Terraform** provisions the infrastructure (VPC, subnets, EC2 instances, networking).  
- **Ansible** configures the infrastructure (installs WordPress, sets permissions, validates deployment).  

---

## 1. Prerequisites

Before running this project, ensure you have the following installed:

- **Terraform** ≥ 1.5.0  
- **Ansible** ≥ 7.0  
- **AWS CLI** (optional, for testing credentials)  
- **Python** ≥ 3.8 (required for Ansible)  
- **SSH access** to your target machines  

Also, ensure you have:

- AWS credentials file (`aws/credentials`) with proper permissions  
- SSH private key (`key-name.pem`) for connecting to EC2 instances  

---

## 2. Setup Instructions

### 2.1 AWS Key Pair
1. Create a key pair in the **AWS Management Console**.  
2. Download the `.pem` file (private key) for SSH access.  

---

### 2.2 Configure Ansible
Edit `ansible.cfg` to point to your SSH private key:

```ini
private_key_file = /path/to/key-name.pem
```

---

### 2.3 Configure AWS Credentials
Navigate to `root/Terraform/resources.tf` and update:

```hcl
shared_credentials_files = ["/path/to/aws/credentials"]
```

Ensure Terraform and Ansible can access your AWS credentials.  

---

### 2.4 Update Resource Names
- In the Terraform folder (`resources.tf`), update resource names as needed.  
- Update the filter in `/root/Ansible/aws_ec2.yml` so Ansible can correctly identify your EC2 instances by name, role, and public IP.  

---

## 3. Deployment

Navigate to the project root folder and run:

```bash
make
```

This will automatically execute the workflow:

1. **Terraform** provisions the infrastructure.  
2. **Ansible** configures the instances and deploys WordPress.  

---

## 4. Verification

After deployment, verify WordPress is running:

```bash
curl -I http://<EC2_PUBLIC_IP>/wordpress/
```

Expected response:

```
HTTP/1.1 200 OK
```

Ansible also includes a **post-deploy check task** to automatically ensure the service is up.  

---

## 5. Integration between Ansible and Terraform

This project uses a **two-step deployment workflow**:

### 5.1 Terraform
- Provisions the infrastructure:
  - VPC, subnets, route tables, internet gateway, and associations  
  - EC2 instances  
  - Networking and security groups  

### 5.2 Ansible
- Configures the infrastructure:
  - Installs required packages (Apache, PHP, etc.)  
  - Deploys WordPress  
  - Sets permissions and configurations  
  - Validates deployment  

Ansible uses a **dynamic inventory** by filtering your EC2 instances by name, role, and public IP, then executes the respective roles on their corresponding EC2 instances.
