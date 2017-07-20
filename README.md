# EzProxy IEEE-Flagging-Script

Ezproxy IEEE-SciHub-Flag is a Windows Powershell script written using PS version 5. The script does the following:

- Identify log entry with IEEE unique flag
- Add the IP making attempt to IEEE to EzProxy IP blacklist
- Add the user account making attempt to IEEE to EzProxy users blacklist
- Send email notification for both breaching IP list and user list

## Requirements

- Windows Powershell 4 or higher
- EzProxy Installed

## **How it works**

Templates are stored for each database family or groups. Various scripts can be run to keep these templates updated. These templates plus a master config file will generate ezproxy configuration files in a conf.d directory in the ezproxy directory. Ezproxy, via an IncludeFile, will add these stanzas.

## **Setup**

The process includes copying the PS script and ini file to you Windows server. Adding the PS to you scheduled task manager.

### **Verify directories**

The script uses the following paths in the psconfig.ini file.
Make sure the _ezproxypath_ is pointing to your ezproxy home directory. The others two paths can be changed or left as default. The script will check for them and create them if needed.

> ### **[Paths]**
> - ezproxypath =C:\ezproxy\   ***Default EzProxy Path*** 
> - ezproxylogfilespath =C:\EzProxyLogFiles\ 
> - ezproxyIEEEflagpath =C:\EzProxyLogFiles\ieeeflag\

### **Modify the psconfig.ini**

> ### **[General]** 
> - IEEEflag=xxxx ***Default IEEE flag, do not change unless IEEE has updated their flag***
> - ezproxyservicename =EZproxy ***Default EzProxy Service name. Make sure the windows service***                                      
> ***for ezproxy is not different***
> 
> ### **[Filenames]**
> - shibuserfile=shibuser.txt ***This is the blocked user include file for***
> ***ezproxy. The file includes*** ***&#39;If auth:userid eq &quot;wzhu12&quot;; Deny deny.htm&#39; entries.***
> - rejectedipfile=rejectip.txt ***This is the blocked ip include file for ezproxy. The file includes &#39;_If auth:userid eq &quot;wzhu12&quot;; Deny deny.htm&#39;_ entries.*** 
> - ezproxylogfile=ezproxy.log ***Default ezproxy log file, do not change. tempoutfile =out.txt Temp file for storing compromised entries.***
> 
> ### **[MailSettings]** 
> - smtp =smtp.gmail.com ***Outgoing SMTP mail server***
> - port =587 ***Outgoing SMTP mail server port***
> - account =xxx@mail.edu ***Mail account for sending outgoing mail***
> - password =xxxxx ***Mail account password***
> - fromemail =***admin@mail.edu Mail account that receiver will see in email***
> 
> ### **[MailMSGS]** 
> - IPsubject =Rejected IP for - IEEE Flag ***Subject line for Rejected IP outgoing mail***
> - USERSsubject =Deny Users for IEEE Hack ***Subject line for Denied User outgoing mail***
> - IPToEmails = admin@mail.edu, admin@mail.org ***Email addresses to send Rejected IP email***                             
> ***multiple accounts can be added using a coma***
> - USERSToEmails=admin@mail.eduEmail ***addresses to send Denied User email multiple***                                                       
> ***accounts can be added using a coma***

## **Installation**

Copy the _IEEEFlag.ps1_ and _psconfig.ini_ to a directory on the Windows server. The server&#39;s ezproxy directory is best.

## **Create New Scheduled Task in Task Manager**
**Open Task Scheduler**
 - Create a new task in Task Scheduler 
 - Name it, set security options

**Set Triggers**
 - Set schedule or event that will trigger Powershell script

**Set Action** 
 - Click on the Actions tab and click on New 
 - Action: Start a program
 - Program/script: Powershell.exe

**Set Argument**  
 - c:\ezproxy\ IEEEFlag.ps1 "c:\ezproxy\psconfig.ini"

***Note:***
You need to set the ExecutionPolicy to run Powershell script in Powershell once
PS> ***Set-ExecutionPolicy -Scope LocalMachine Unrestricted*** 

