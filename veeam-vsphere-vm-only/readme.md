# Automated Veeam Software Deployment

Pre
- Install ansible (macos - `brew install ansible`)
- Install Terraform 
- Install Veeam Collection `ansible-galaxy collection install veeamhub.veeam`



This takes a lot of credit from the previous project I created [VeeamLAB](https://github.com/MichaelCade/VeeamLAB) but instead of using Ansible here for the Veeam Deployment it was using PowerShell, this project has also not been updated in years. 

This folder consists of ways to deploy your Veeam environment VMs as per 12.1 to vSphere, AWS EC2 and Azure VM using Terraform. 

It then also includes ansible playbooks used to deploy and install Veeam components (VBR & ONE) to either the above created VMs or to any Windows Machines you require. 

At the time of writing this they can be used seperatly but the endeavor is to run one command and then we have a bunch of machines deployed for demo purposes. 

The final cherry on top will also be to have a way to automate the configuration of Veeam software, this could be the adding of source environments to protect (vSphere vCenter), target repositories to send backups to and also the creation of backup jobs and additional plugins and components. The path for this final endevour has not been defined but likley will have to be PowerShell or API focused. 

In order to use this you will need Terraform and Ansible installed on the system you wish to run and you will have to create a terraform.tfvars file following the example.tfvars file as guidance. 

- Create terraform.tfvars file and complete 
- edit /ansible/inventory.ini 
- edit /ansible/veeam_vbr.yaml
- edit /ansible/veeam_one.yaml

## To Do list 

userdata.ps1 that is pulled currently from an older public repo, this enables openssh, rdp and some other things. We have a copy in this repo so would just need to update that when things are public. 

Terraform additions
- Windows Proxy 
- Linux Proxy 
- XFS Repo 
- Enterprise Manager 

The above Linux boxes we need to confirm that we have a Linux template to use 

- VBM365 
- VRO 
- SFDC 

Once the above is done with at least VBR, EM and ONE we have Ansible playbooks that can then install these components 

The final step is the configuration, which will either be via PowerShell, API and thinking if this could be done with Terraform after the Ansible deployment has taken place? 

- Add Source Backup resources (vSphere Cluster, EndPoints, NAS, Object Storage)
- Add Target Repositories (XFS, Local NAS, Object Storage)
- Create Backup Jobs 
- Create SureBackup Jobs 
- Configuration Backup 
- Platform Services Deployment (AWS, Azure, Kasten)