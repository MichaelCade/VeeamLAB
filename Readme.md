<p align="center">
  <img src=https://miro.medium.com/max/523/1*ldnkejIA-3qpubTzRu9K5A.png>
</p>

## The Challenge
Here you will find the automation build out of my lab Veeam environment. Currently I have only looked at the deployment of the virtual machines within my lab environment, the code used is specific to our lab environment. Everyone is more than welcome to use and ask questions on the code. 

Probably more important please also give me feedback where we can improve the code. The next steps will be to then begin the installation and automation of the Veeam Software within the deployed machines. 

## Steps Required for complete lab build out 
This is a list I am working on based on our lab environment and what I generally need to have access to, obviously there are other components available and we may add them here later on if we need to automate those aspects. 

- [ ]  1 > [Create Terraform script to leverage existing Windows and Linux vSphere templates and deploy new virtual machines as Veeam Components]

- [ ]  2 > [The initial script will create the following machines]
  - [ ]  Windows 2019 Server - Veeam Backup & Replication Management
  - [ ]  Windows 2019 Server - Veeam Backup Proxy 
  - [ ]  CentOS 7 Server - Veeam Backup Repository (with XFS and 500GB additional disk)
  - [ ]  Ubuntu 18.04 Server - Veeam Backup Proxy 

- [ ]  3 > [Unattended Installation of Veeam Backup & Replication on management server]
- [ ]  4 > [Add and deploy all other Veeam Components to management server]
- [ ]  5 > [Add vSphere environment, Cloud workloads, NAS Shares, Storage Systems and Physical Agents (out of scope from automation as these are static and used by others)]
- [ ]  6 > [Add in additional Veeam Backup components such as static repository options (ExaGrid) and Cloud Based Object Storage and External Repositories]
  - Azure Blob Storage 
  - AWS S3 Storage 
  - Google Cloud Storage 
  - Possible on prem S3 Storage]  
- [ ]  7 > [SureBackup Configuration & Deployment automated]

This list is not complete yet but will be worked on over the holidays to ensure when new versions of VBR arrive it is super simple to take this repository and deploy the same cut out Veeam Lab environment each time. 


