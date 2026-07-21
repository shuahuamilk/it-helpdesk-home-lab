# Project reflection

Complete this after finishing the lab.

## Project summary

I built an isolated IT help desk home lab in Oracle VirtualBox using one Windows Server domain controller and one Windows client. I configured Active Directory Domain Services, DNS, Organizational Units, test users, security groups, password resets, account lockouts, and Group Policies. The lab simulates common help desk tasks in a small business environment and gave me hands-on practice with identity management, workstation join processes, and policy-based administration.

## Skills demonstrated

- Creating and organizing Active Directory users, groups, and OUs
- Resetting passwords and forcing password changes at next logon
- Joining a Windows PC to a domain
- Troubleshooting DNS and domain join issues
- Locking and unlocking user accounts
- Creating and linking Group Policy Objects
- Verifying policy application with gpupdate and gpresult

## Architecture decisions

I used a host-only VirtualBox network so the lab would stay isolated from my home network while still allowing the host, server, and client to communicate. I set DC01 as the DNS server because Active Directory depends on DNS for domain discovery and authentication. I separated users, computers, and groups into different OUs so the environment would be easier to manage and so Group Policies could be targeted cleanly. The account lockout policy was linked at the domain level because it is a domain-wide security setting, while the workstation banner and user restriction policies were linked to specific OUs so they only affected the intended systems or users.

## Most difficult issue

Problem: The domain join initially failed on CL01.
Symptoms: The client could not find the domain, and the join screen reported that the domain was unavailable or could not be found.
Diagnostic process: I checked the client’s IP configuration, tested DNS resolution with nslookup, and confirmed that both VMs were attached to the same host-only network.
Root cause: The client was not correctly using DC01 as its DNS server at first, and I also had a few credential entry mistakes during the join process.
Resolution: I corrected the DNS settings, verified that helpdesk.test resolved to 192.168.56.10, and retried the join using the correct domain credentials.
What I learned: In Active Directory environments, DNS issues can look like domain or credential problems even when the real issue is name resolution.

## Security considerations

This lab was kept isolated from the production network to reduce risk. I used evaluation software only, avoided storing any real passwords or sensitive data, and did not upload ISO files, VM disks, or recovery information to GitHub. I also used aggressive account lockout settings only for training purposes, not as a real-world recommendation. The lab reinforced the importance of secure credential handling, careful documentation, and separating test systems from personal or production environments.
## Improvements for version 2

For a future version of the lab, I would add a second domain controller for redundancy, a file server for permissions practice, and a second client for more realistic support scenarios. I would also add delegated help desk permissions, Windows LAPS, DHCP, printer deployment through Group Policy, and event log auditing for lockout troubleshooting. PowerShell automation could be expanded to create users, groups, and reports more efficiently.

## Interview explanation

I built an Active Directory home lab in Oracle VirtualBox to practice core IT help desk and Windows administration tasks. I configured a domain controller and client, set up DNS and domain join functionality, created users and OUs, reset passwords, handled account lockouts, and applied Group Policies. I also documented the project with screenshots and troubleshooting notes, which made the lab useful both as a learning exercise and as a portfolio piece.
