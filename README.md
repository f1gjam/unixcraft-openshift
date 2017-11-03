Openshift Install on vSphere
=======================

This README will guide you to installing Openshift 3.x on vSphere using Terraform. **Centos 7** is the only OS supported by the install documented here.

**Note**: There is no hard requirement to use Terraform, or to Install on vSphere. All that is required are the correct number of virtual machines and the required DNS records are in place.


## Infrastructure Pre-Reqs

### DNS Setup

Configure External DNS with the following records
```
*.app.lab.unixcraft.lcl A Record <IP address of Infra Node>
osmaster.lab.unixcraft.lcl A Record <IP address of Master Node>
osinfra.lab.unixcraft.lcl A Record <IP address of Master Node>
osnode01.lab.unixcraft.lcl A Record <IP address of Master Node>
osnode02.lab.unixcraft.lcl A Record <IP address of Master Node>
osnode03.lab.unixcraft.lcl A Record <IP address of Master Node>
```
**Note**: The domain here is used as an example


### VM Creation

Terraform can be used to create the required virtual machines (Please note - the terraform files will need to be edited with the correct IP addresses and domain names). if you do not want to use Terraform or vSphere, here are the details for the machines.

**Note**: Terraform, does not seem to add disks in ordered fashion, so to get around this issue, comment out the GFS drives in the osnode section and run the terraform apply. Once completed, uncomment the GFS drives and re-apply. This will ensure the drives come as sdb for Docker and sdc for GFS

Once the Terraform file has been edited, execute the following command

```
terraform apply --var-file=/<path to terraform variable file>/openshift_lab.tfvars
```

### Manual VM creation
If you wish to create the VM's in some other way, here are the requirenents.

1 * Master Node - (2vCPU, 8GB memory, 30GB HDD (OS), 30GB (Docker))
1 * Infra Node - (2vCPU, 16GB memory, 30GB HDD (OS), 30GB (Docker))
3 * Virtual Machines - (2vCPU, 8GB memory, 30GB HDD (OS), 30GB (Docker), 50GB (GFS))

**Note**: All of the VM's should be on a single flat network.

### VM Configuration

All of the virtual machines need to be configured with the following

1) Ansible SSH user and key
2) Disable firewall and SE-linux

These steps will not be detailed here


## Ansible


### pre-requisties
Assuming you have Ansible installed and configured on the machine which will executes the plays. There is one pre-requisties that needs to be installed for the installation to be successful.

Install the python-passlib module.

```
pip install passlib
```

**Note**: If you are on a Mac running Sierra and you have used Homebrew to install Python and Ansible, please ensure you have created a symlink for python2 to python in

```
/usr/local/bin
```

Also make sure that ```/usr/local/bin``` is in your PATH. This is important as when Ansible executes it may use the system Python and will not find the passlib module and fail.

### Clone Repositories

Clone the following repositories into /tmp

```
cd /tmp
```

Openshift vSphere installation repositories
```
git clone https://github.com/f1gjam/unixcraft-openshift.git
```

Official openshift-ansible Repo
```
git clone https://github.com/openshift/openshift-ansible
```

## Inventory file

Edit the Ansible inventory file inside the unixcraft-openshift repositories

```
cd /tmp/unixcraft-openshift/inventories/
```

Edit the following:
```
ansible_ssh_private_key_file=<path to ssh key file to be used by ansible>
```
Ensure the path to the private key used by ansible for accessing the virtual machines is correct

Edit the GlusterFS section and update the IP addresses of the OSNODE's

```
[glusterfs]
osnode01.lab.unixcraft.lcl glusterfs_ip=192.168.10.62 glusterfs_devices='[ "/dev/sdc" ]'
osnode02.lab.unixcraft.lcl glusterfs_ip=192.168.10.63 glusterfs_devices='[ "/dev/sdc" ]'
osnode03.lab.unixcraft.lcl glusterfs_ip=192.168.10.64 glusterfs_devices='[ "/dev/sdc" ]'
```

### Start the installation

Once the inventory file has been updated you can execute the Ansible plays

Go into the unixcraft-openshift repository directory
```
cd /tmp/unixcraft-openshift
```

Execute the following command
```
ansible-playbook -i inventories/openshift openshift.yml -b
```

## Post install

Once the installation has finished, SSH into the master node and execute the following commands

```
htpasswd -c /etc/origin/htpasswd admin
```
You will be prompted to enter a password for the admin user

Then execute the following command
```
oadm policy add-cluster-role-to-user cluster-admin admin
```

Now the installation is complete and you are ready to logon to the Web Interface

Which should be found at:

https://osmaster01.lab.unixcraft.lcl:8443

**Note**: If the hostname of the master or the domain was changed, be sure to put in the correct hostname and domain.

You should be able now login as **admin** with the password provided to the htpasswd command

## Persistent Storage

By default the installation does not mark the GlusterFS storage as default dynamic storage. To enable this we need to the following on the master node.

You need to create a default storage class which points to the existing GlusterFS storage. Lets get the details we will need to create a default storage class. Run the following commnd on the master node

```
oc get storageclass -o yaml
```

This will provide you with the existing storage class information. There are details in here we may need when creating our new default storage class.

Create a file with the following (name the file - default-storageclass.yml)

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: generic
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: http://heketi-storage-glusterfs.app.lab.unixcraft.lcl
  restuser: admin
  secretName: heketi-storage-admin-secret
  secretNamespace: glusterfs
```
The details above should be correct, however to ensure we have the correct restuser, secretName, secretNamespace, compare the values with the ones given in the output of the command

```
oc get storageclass -o yaml
```

If all is good execute the following command:

```
oc create -f default-storageclass.yml
```

Now you have enabled the GlusterFS to be the default storage and be used for dynamic provisioning.
