# Configure a Vault Server on AWS

# Pre-request
  Domain

# Create a private S3 bucket for storage data

# Create an IAM role, and attach necessary policy to access the S3 created last step

# Launch an EC2 instance with Ubuntu 20.04 image，create new security group open port 22, 80,443, 8200

# SSH into the EC2 instance

# Update package 
sudo apt-get update && sudo apt-get upgrade -y

# Download vault
wget https://releases.hashicorp.com/vault/1.6.1/vault_1.6.1_linux_amd64.zip

# Install unzip package
sudo apt install unzip

# Unzip files
unzip vault_1.6.1_linux_amd64.zip

# Move Vault directory
sudo mv vault /usr/bin

# Verify Vault is usable
vault --version

# Make Vault directory
sudo mkdir /etc/vault
sudo mkdir -p /var/lib/vault/data

# Create the config file for Vault, copy the content of config.hcl, save and exit
sudo vim /etc/vault/config.hcl

# Create vault service, copy the content of vault.service, save and exit
sudo vim /etc/systemd/system/vault.service

# Enable vault autocomplete （optional)

vault -autocomplete-install

complete -C /usr/bin/vault vault

# Reload the daemon
sudo systemctl daemon-reload

# Start Vault
sudo systemctl start vault

# Enable Vault upon restart
sudo systemctl enable vault

# Verify status of Vault
sudo systemctl status vault

# You should be ale to access Vault UI via <ec2 public ip>:8200

# Launch a new terminal session, and set VAULT_ADDR environment variable
export VAULT_ADDR='http://<ec2 public ip>:8200'

# Initialize Vault, and you should have five unseal keys and on root token, keep them safe
vault operator init

# Unseal the Vault by use the command three times, and use three of the five keys generated last step
vault operator unseal

# Login to vault with root token
vault login

# Check to see the vaults sealed status sealed = false means that the vault is unsealed

vault status

# Use the Vault CLI to create a secret
vault kv put secret/aws-keys access_key=<YOUR_AWS_ACCESS_KEY> secret_key=<YOUR_AWS_SECRET_KEY>

# To configure Vault in Jenkins, you can follow these steps:
1. Install the Jenkins HashiCorp Vault Plugin. This plugin provides integration between Jenkins and Vault and enables you to manage secrets stored in Vault.

2. Create a Vault credential in Jenkins. Go to "Credentials" -> "System" -> "Global credentials" and click "Add Credentials". Select "Vault Token Credential" or "Vault AppRole Credential" as the kind, depending on the authentication method that you selected. Enter the credential ID, Vault token or AppRole ID and secret, and any other optional configuration details.

3. Configure the Vault server URL and authentication method in the Jenkins global configuration. Go to "Manage Jenkins" -> "Configure System" and scroll down to the "HashiCorp Vault" section. Enter the Vault server URL in the "Vault URL" field and select the authentication method that you want to use, such as token or AppRole.

4. Use the Vault credential in your Jenkins job. In your Jenkinsfile, you can use the withVault step to access secrets stored in Vault using the credential that you created in step 2. 