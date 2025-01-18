
The terraform will deploy the 1 Domain Controller and one Member Server which will be joined the DC after the DC is up. Both servers are Windoes Server 2019/2022

Requirments:  Add the needed subscription ID, Username & Password in terraform.tfvars:

    
    azure-subscription-id = ""
    ad_admin_username                   = ""
    ad_admin_password                   = ""
    ad_safe_mode_administrator_password = ""

example here for each of the above 3:

"tomcruise"
"ToM110110110"
"F3c0p3ryBcc3ssN0d3"

Important note:

    Clone the repo
    Execute:
            terraform init -upgrade
            terraform apply -auto-approve

    Wait until the execution complete and DC is running. The DC should be up. 

    Move the files (vm-dj1-main.tf & vm-dj1-output.tf) from dj-Temp folder to the main folder:

    Execute again:
            terraform apply -auto-approve


    Now the domain member should be also up and should be a member of the DC. 




The Public IP address of both Domian Controller and Member server (Domain Joined) will be printed for the observation.


************   SSH Config ***************

First step: Create SSH connection. 


Connect through RDP to the server:

    xfreerdp /v:20.52.246.152 /u:hrouhan /dynamic-resolution

    
    and open Powershell and execute following commands:

    
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Get-NetFirewallRule -Name *ssh*
  

Only for windows server 2016, we need to upload the OpenSSH-Win64-v9.8.1.0.msi (https://github.com/PowerShell/Win32-OpenSSH/releases) for installing ssh. Afterwards doing following:

    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22


************ CIS Toolkit GPO import *****************

First step:  Transfer the CIS toolkit to the server, drive C::

    scp Azure_Server_2022_v1.0.0.zip hrouhan@20.52.246.152:/
    ssh hrouhan@20.52.246.152 
    cd c:\
    mkdir CIS
    tar -xf Azure_Server_2022_v1.0.0.zip -C c:\CIS



Second step:   Load the CIS GPO kit for the respected server (here the Domain Controller):

    We do not recommend to use the command line for this task. 

    follow these steps:

        a.  Server Manager Dashboard --> Tools --> Group Policy Management

        b.  Group Policy Management --> Forest: hrouhan.local --> Domains --> hrouhan.local --> Group Policy Objects --> Default Domain Controllers Policy (Right Click) --> Import Settings...  -->  Backup folder --> C:\CIS\DC L1

            We choose "DC L1" from our CIS Toolkit 

            -->  continue until the end as default settings

        c. cmd Terminal  -->   gpupdate /force



Third step:   Scan the server


    cnspec scan ssh hrouhan@20.52.246.152 -f policies/cis-microsoft-azure-windows-server-2022.mql.yaml --ask-pass