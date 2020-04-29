# terraform_ansible_tower_demo #

Uses Ansible playbooks starting with twr.launch.create_vm.yml which launches a Tower job template called Creat VM using the main.create_vm.yml playbook

Create VM job creates terraform directories local in /terraform_demo/ based on templates in the same directory

Applies terraform plan to VMs from templates in vcenter

Creates them in an existing folder named ansible in vcenter

Runs runs twr.inv_src.vc02.yml calling an inventory in tower to bring in machines post create (this currently calls inventory source 10.. yours will be different.)

Finally adds the host to a group named after the base_os var which is nested in the linux or windows main groups

Winrm vars are set on the windows main group in tower

!!! Job template naming is particular

Windows machines configureansible.ps1 post creation

Requires pyVmomi,
         Ansible,
         Tower,
         Tower-cli,
         Pywinrm



         
         
