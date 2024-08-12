# Instructions 

We will be using the veeamhub ansible galaxy collection which can be found here with instructions on how to install to your Ansible host [Official Ansible Galaxy Collection for Veeam](https://galaxy.ansible.com/ui/repo/published/veeamhub/veeam/)


This guide is assuming that you have the Windows Servers already up and running without any veeam components installed, although we will deal with that aspect later probably by introducing terraform to get to that stage beforehand. 


You will require a machine with Ansible installed and the Ansible-Galaxy collection installed as per the veeam instructions. 


<type command here for that and links> 

it will also assume that you have WinRM or OpenSSH client installed on the Windows Server. I am using Windows Server 2022 but the above package should work with respectively mentioned versions for the collection. 


Good SSH link - https://www.server-world.info/en/note?os=Windows_Server_2022&p=ssh&f=1
Actually seems that the above link was just taken from - https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershellhttps://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell



Ansible Windows Setup Page - https://docs.ansible.com/ansible/latest/os_guide/windows_setup.html

On the ansible host system i did install - sudo apt-get install sshpass

I then made a change to the inventory file from this walkthrough again familiar with the instructions above on getting SSH up and running 

https://gist.github.com/letajmal/0ac50ead52a4e80d96b52ef22c391666


I have also tested this on macos and I required `brew install hudochenkov/sshpass/sshpass` 

quick note that before anything will work you will need `ansible-galaxy collection install veeamhub.veeam` 

Be sure to check the playbook and source license file 