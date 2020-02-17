# Getting started
For the hackathon, your environment to build your prototype on is brought to you by IBM LinuxONE Community Cloud - anyone can sign up and have an access to the Linux on Z virtual server. You can find more details here: https://developer.ibm.com/linuxone/

To get setup for the weekend, complete the following steps:



1. Follow the steps in the link to request for LinuxONE server. You can request either RHEL or SLES for your operating system -- your pick!

https://github.com/linuxone-community-cloud/technical-resources/blob/master/deploy-virtual-server.md



2. Once your Linux guest is running and you can ssh into the guest, copy the installation script onto your guest.

```
curl https://raw.githubusercontent.com/SweetJenn23/MaristBlockchainHackathon/master/ZFabricBuild-1.4.sh -o ZFabricBuild-1.4.sh
```

3. Issue the following command to make the script executable. `chmod u+x ZFabricBuild-1.4.sh`
4. Run the script to build your blockchain environment. `./ZFabricBuild-1.4.sh`



Once the proceeding steps have been successfully completed, please continue on to Lab1.
