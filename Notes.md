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

For a service-token workflow:

```sh
export DOPPLER_TOKEN='YOUR_DOPPLER_SERVICE_TOKEN'
task deploywithdoppler
```

## Push the image to GitHub Container Registry

Log in with a GitHub personal access token that has `write:packages` permission:

```sh
cd /Users/nikhil/nik-ws/vetology-devops-exercise/app/webtext-app
echo "$GITHUB_TOKEN" | docker login ghcr.io -u NikhilRaj-DevOps --password-stdin
task build
task publish
```

## Authenticate AWS

AWS CLI login credentials are temporary. Export them in the same shell where Terraform runs:

```sh
aws login
eval "$(aws configure export-credentials --profile default --format env)"
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
cp inventory.example.yml inventory.yml
```

Edit `inventory.yml`:

```yaml
ansible_host: YOUR_EC2_PUBLIC_IP
ansible_user: ubuntu
ansible_ssh_private_key_file: ~/.ssh/webtext-app-ec2
```

Run the configuration:

```sh
ansible-playbook site.yml
```

## Run the published GHCR image on the VM

```sh
ssh -i ~/.ssh/webtext-app-ec2 ubuntu@YOUR_EC2_PUBLIC_IP
echo "$GITHUB_TOKEN" | docker login ghcr.io -u NikhilRaj-DevOps --password-stdin
docker pull ghcr.io/nikhilraj-devops/webtext-app:latest
docker rm -f webtext-app 2>/dev/null || true
docker run -d \
	--name webtext-app \
	--restart unless-stopped \
	-p 8081:80 \
	-e WEBTEXT='Development deploy' \
	ghcr.io/nikhilraj-devops/webtext-app:latest
curl localhost:8081
```

## Destroy AWS resources

```sh
cd /Users/nikhil/nik-ws/vetology-devops-exercise/terraform
eval "$(aws configure export-credentials --profile default --format env)"
terraform destroy
```