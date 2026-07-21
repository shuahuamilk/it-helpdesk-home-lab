# Project completion checklist

## Planning

- [x] Confirm host has virtualization enabled in BIOS/UEFI
- [x] Reserve sufficient disk space
- [x] Download evaluation ISOs
- [x] Create a folder for lab files and evidence
- [x] Record the planned IP address table

## VirtualBox

- [x] Create a host-only network
- [x] Use subnet `192.168.56.0/24`
- [x] Disable VirtualBox DHCP for the lab network
- [x] Create `DC01`
- [x] Create `CL01`
- [x] Take clean-install snapshots

## Domain controller

- [x] Install Windows Server Desktop Experience
- [x] Rename server to `DC01`
- [x] Assign `192.168.56.10/24`
- [x] Set preferred DNS to `192.168.56.10` or loopback after promotion
- [x] Install AD DS and DNS roles
- [x] Create forest `helpdesk.test`
- [x] Run `dcdiag`
- [x] Confirm DNS zone exists

## Active Directory

- [x] Create top-level `Lab` OU
- [x] Create Users, Computers, and Groups child OUs
- [x] Create HR, Sales, IT, and Workstations child OUs
- [x] Create three test users
- [x] Create department security groups
- [x] Add users to the correct groups
- [x] Record screenshots

## Client

- [x] Install Windows 11 Enterprise
- [x] Rename PC to `CL01`
- [x] Assign `192.168.56.101/24`
- [x] Set DNS to `192.168.56.10`
- [x] Verify `ping DC01`
- [x] Verify `nslookup helpdesk.test`
- [x] Join `helpdesk.test`
- [x] Restart and sign in as a domain user
- [X] Move CL01 into the Workstations OU

## Help desk exercises

- [x] Reset a user password
- [x] Require password change at next sign-in
- [x] Verify successful sign-in
- [x] Configure a lab account-lockout policy
- [x] Trigger an account lockout
- [x] Confirm the account is locked
- [x] Unlock the account
- [x] Verify successful sign-in

## Group Policy

- [x] Create workstation logon-banner GPO
- [x] Link it to the Workstations OU
- [x] Create user restriction GPO
- [x] Link it to one department OU
- [x] Run `gpupdate /force`
- [x] Run `gpresult /r`
- [x] Confirm visible policy behavior
- [x] Save evidence

## Documentation and GitHub

- [x] Add screenshots with descriptive filenames
- [x] Remove passwords and sensitive data from screenshots
- [x] Complete troubleshooting table
- [x] Complete project reflection
- [x] Run verification script
- [x] Review `.gitignore`
- [x] Commit files to Git
- [ ] Create public GitHub repository
- [ ] Add repository description and topics
