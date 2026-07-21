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
- [ ] Create `CL01`
- [ ] Take clean-install snapshots

## Domain controller

- [x] Install Windows Server Desktop Experience
- [x] Rename server to `DC01`
- [x] Assign `192.168.56.10/24`
- [x] Set preferred DNS to `192.168.56.10` or loopback after promotion
- [x] Install AD DS and DNS roles
- [ ] Create forest `helpdesk.test`
- [ ] Run `dcdiag`
- [ ] Confirm DNS zone exists

## Active Directory

- [ ] Create top-level `Lab` OU
- [ ] Create Users, Computers, and Groups child OUs
- [ ] Create HR, Sales, IT, and Workstations child OUs
- [ ] Create three test users
- [ ] Create department security groups
- [ ] Add users to the correct groups
- [ ] Record screenshots

## Client

- [ ] Install Windows 11 Enterprise
- [ ] Rename PC to `CL01`
- [ ] Assign `192.168.56.101/24`
- [ ] Set DNS to `192.168.56.10`
- [ ] Verify `ping DC01`
- [ ] Verify `nslookup helpdesk.test`
- [ ] Join `helpdesk.test`
- [ ] Restart and sign in as a domain user
- [ ] Move CL01 into the Workstations OU

## Help desk exercises

- [ ] Reset a user password
- [ ] Require password change at next sign-in
- [ ] Verify successful sign-in
- [ ] Configure a lab account-lockout policy
- [ ] Trigger an account lockout
- [ ] Confirm the account is locked
- [ ] Unlock the account
- [ ] Verify successful sign-in

## Group Policy

- [ ] Create workstation logon-banner GPO
- [ ] Link it to the Workstations OU
- [ ] Create user restriction GPO
- [ ] Link it to one department OU
- [ ] Run `gpupdate /force`
- [ ] Run `gpresult /r`
- [ ] Confirm visible policy behavior
- [ ] Save evidence

## Documentation and GitHub

- [ ] Add screenshots with descriptive filenames
- [ ] Remove passwords and sensitive data from screenshots
- [ ] Complete troubleshooting table
- [ ] Complete project reflection
- [ ] Run verification script
- [ ] Review `.gitignore`
- [ ] Commit files to Git
- [ ] Create public GitHub repository
- [ ] Add repository description and topics
