# Script to install terraform and other utilities.
# dan@dsblue.net  2022
#
# jq = JSON parser / wget = web file getter 
function install_prerequisites() {
    sudo yum install -y jq
    sudo yum install -y wget
}

# Check if Terraform installed, if not download and install. 
function install_terraform() {
    # Hardcoding version tested with
    #TERRAFORM_VERSION="1.3.2"
    TERRAFORM_VERSION="1.3.6"

    # Check if terraform is already installed and display the version of terraform as installed
    [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0

    TERRAFORM_DOWNLOAD_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep 'linux.*amd64' | egrep "${TERRAFORM_VERSION}" | egrep -v 'rc|beta|alpha')
    TERRAFORM_DOWNLOAD_FILE=$(basename $TERRAFORM_DOWNLOAD_URL)

    echo "Downloading Terraform v$TERRAFORM_VERSION from '$TERRAFORM_DOWNLOAD_URL'"

    # Download and install Terraform 
    mkdir -p ${HOME}/bin/ && cd ${HOME}/bin/ && wget $TERRAFORM_DOWNLOAD_URL && unzip $TERRAFORM_DOWNLOAD_FILE && rm $TERRAFORM_DOWNLOAD_FILE

    # Display confirmation of successful installation of Terraform.
    echo "Installed: `${HOME}/bin/terraform version`"
}

# Set up git account, will prompt for pwd
#git config --global user.email "****"
#git config --global user.name "****"



install_prerequisites
install_terraform
