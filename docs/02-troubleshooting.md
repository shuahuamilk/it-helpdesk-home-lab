# Troubleshooting notes

This lab included a few normal setup issues. The fixes below were part of the learning process and helped confirm the environment was working correctly.

## Troubleshooting log

| Stage | Problem | Cause | Fix | Result |
|---|---|---|---|---|
| VirtualBox network | Host-only adapter settings looked correct, but the status bar still showed NAT | The adapter settings had not been saved yet | Clicked **OK**, returned to VirtualBox Manager, and confirmed the VM network setting was truly set to **Host-only Adapter** | DC01 and CL01 could communicate on the lab network |
| Domain join | `helpdesk.test` could not be found during the domain join | CL01 was not resolving the domain correctly at first | Verified CL01 DNS was set to `192.168.56.10`, confirmed `nslookup helpdesk.test` returned the DC address, and retried the join | Domain join succeeded |
| Domain join credentials | `HELPDESK\Administrator` was rejected | I used the wrong credential format or wrong password on the first attempt | Tried the domain UPN format `Administrator@helpdesk.test` and then corrected the password | Domain join succeeded |
| Domain join | `HELPDESK` alone did not work as a domain name | `HELPDESK` is the NetBIOS name, not the DNS domain name | Used `helpdesk.test` for the domain join and `HELPDESK\Administrator` or `Administrator@helpdesk.test` for credentials | Join worked correctly |
| User sign-in | `ajohnson` could not sign in at first | The wrong password was entered | Retried with the correct temporary password set in Active Directory | User sign-in succeeded |
| Group membership | Right-clicking the group and choosing **Add to group** caused confusion | That option is for nesting one group inside another, not adding a user | Added the user from the user object instead: right-click user → **Add to group** | User was added to the correct security group |
| Group Policy | I could not find a **Link** option in Active Directory Users and Computers | GPOs are linked in **Group Policy Management**, not ADUC | Opened **Server Manager → Tools → Group Policy Management** and used **Link an Existing GPO** on the OU | GPOs linked successfully |
| Group Policy | Banner or restriction policy did not seem to apply immediately | Policy had not refreshed yet | Ran `gpupdate /force`, then used `gpresult /r`, and restarted the client | Policies applied correctly |
| Account lockout | The lockout behavior took a moment to appear | Account lockout settings needed time to refresh | Confirmed the policy, repeated failed logons, and checked the account state in ADUC and PowerShell | Account lockout worked |
| Password reset | The user could not sign in after reset | Password mismatch | Reset the password again in ADUC and checked **User must change password at next logon** | User regained access |

## Useful commands

```powershell
ipconfig /all
nslookup helpdesk.test
ping DC01
Get-ADDomain
Get-ADForest
Get-ADUser ajohnson
Search-ADAccount -LockedOut
Unlock-ADAccount -Identity bsmith
gpupdate /force
gpresult /r
dcdiag