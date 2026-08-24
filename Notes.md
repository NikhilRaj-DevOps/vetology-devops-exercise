# webtext-app command runbook

Run commands from the directory shown in each section.

## Install local tools

```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform awscli go-task/tap/go-task
brew install --cask docker
brew install dopplerhq/doppler/doppler
```

Start Docker Desktop, then verify:

```sh
docker --version
terraform version
aws --version
task --version
doppler --version
```

## Build and test locally

```sh
cd /Users/nikhil/nik-ws/vetology-devops-exercise/app/webtext-app
task build
task lint
task deploy
task test
curl localhost:8081
task clean
```

## Configure Doppler

```sh
doppler login
cd /Users/nikhil/nik-ws/vetology-devops-exercise/app/webtext-app
doppler setup --project webtext-app --config dev
doppler secrets set WEBTEXT='Hello World from Doppler!'
task deploywithdoppler
curl localhost:8081
task clean
```

For a service-token workflow, create a Doppler service token for the `webtext-app` / `dev` configuration and export it only in the current shell:

```sh
export DOPPLER_TOKEN='YOUR_DOPPLER_SERVICE_TOKEN'
task deploywithdoppler
```

## Authenticate AWS

Configure AWS CLI credentials before running Terraform:

```sh
aws configure
aws sts get-caller-identity
```

## Provision EC2 with Terraform

Edit `terraform.tfvars` with your AWS key-pair name and public IP:

```hcl
aws_region    = "us-east-1"
instance_type = "t3.micro"
key_name      = "webtext-app-ec2"
ssh_cidr      = "YOUR_PUBLIC_IP/32"
```

Create the EC2 key pair in AWS once:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/webtext-app-ec2 -N '' -C webtext-app-ec2
aws ec2 import-key-pair \
	--key-name webtext-app-ec2 \
	--public-key-material fileb://$HOME/.ssh/webtext-app-ec2.pub \
	--region us-east-1
```

Apply Terraform:

```sh
cd /Users/nikhil/nik-ws/vetology-devops-exercise/terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output public_ip
```

## Configure the VM with Ansible

```sh
brew install ansible
cd /Users/nikhil/nik-ws/vetology-devops-exercise/ansible
```

Create or edit `inventory.yml` with the Terraform public IP:

```yaml
ansible_host: YOUR_EC2_PUBLIC_IP
ansible_user: ubuntu
ansible_ssh_private_key_file: ~/.ssh/webtext-app-ec2
```

Run the configuration:

```sh
ansible-playbook site.yml
```

## Build, deploy, and test on the VM

```sh
ssh -i ~/.ssh/webtext-app-ec2 ubuntu@YOUR_EC2_PUBLIC_IP
export DOPPLER_TOKEN='YOUR_DOPPLER_SERVICE_TOKEN'
cd /opt/vetology-devops-exercise/app/webtext-app
task cicd
curl localhost:8081
```

The service token must be scoped to the `webtext-app` project and `dev` configuration. The task passes those values explicitly, so no local Doppler project file is required on the VM.

## Destroy AWS resources

```sh
cd /Users/nikhil/nik-ws/vetology-devops-exercise/terraform
terraform destroy
```