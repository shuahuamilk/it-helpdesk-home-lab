# Step-by-step lab build guide

## 1. Plan the lab

Use an isolated VirtualBox host-only network:

| Device | Hostname | IPv4 address | Mask | Gateway | DNS |
|---|---|---:|---:|---|---:|
| Domain controller | DC01 | 192.168.56.10 | 255.255.255.0 | Blank | 192.168.56.10 |
| Windows client | CL01 | 192.168.56.101 | 255.255.255.0 | Blank | 192.168.56.10 |

The blank gateway intentionally keeps the lab isolated. Download all installers and ISOs on the host computer before beginning.

Suggested host resources:

- 16 GB RAM or more
- Four logical CPU cores or more
- Approximately 120 GB of free disk space
- Hardware virtualization enabled in BIOS/UEFI

Suggested VM resources:

| VM | vCPU | RAM | Disk |
|---|---:|---:|---:|
| DC01 | 2 | 4–6 GB | 60 GB dynamically allocated |
| CL01 | 2 | 4–6 GB | 64 GB dynamically allocated |

## 2. Create the VirtualBox network

1. Open VirtualBox Manager.
2. Open **File > Tools > Network Manager**.
3. Create a host-only network.
4. Configure:
   - IPv4 address: `192.168.56.1`
   - Mask: `255.255.255.0`
5. Disable the VirtualBox DHCP server for this network.
6. Record a screenshot.

Use the same host-only network for both VMs.

## 3. Create DC01

1. Select **New** in VirtualBox.
2. Name the VM `DC01`.
3. Select the Windows Server ISO.
4. Allocate two vCPUs, 4–6 GB RAM, and a 60 GB virtual disk.
5. Open the VM settings.
6. Under **Network**, attach Adapter 1 to the host-only network.
7. Start the VM.
8. Install **Windows Server Standard Evaluation (Desktop Experience)**.
9. Set a strong local Administrator password.
10. Install VirtualBox Guest Additions if desired.
11. Take a snapshot named `DC01-Clean-Install`.

## 4. Configure DC01 before promotion

### Rename the server

In Server Manager:

1. Select **Local Server**.
2. Select the current computer name.
3. Select **Change**.
4. Enter `DC01`.
5. Restart.

PowerShell alternative:

```powershell
Rename-Computer -NewName "DC01" -Restart
```

### Configure static IPv4

1. Open **Network Connections**.
2. Open the Ethernet adapter properties.
3. Open **Internet Protocol Version 4 (TCP/IPv4)**.
4. Set:
   - IP address: `192.168.56.10`
   - Subnet mask: `255.255.255.0`
   - Default gateway: blank
   - Preferred DNS: `192.168.56.10`
5. Save the settings.

PowerShell alternative:

```powershell
Get-NetAdapter
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress 192.168.56.10 `
    -PrefixLength 24

Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet" `
    -ServerAddresses 192.168.56.10
```

Verify:

```powershell
ipconfig /all
hostname
```

## 5. Install AD DS and create the forest

### GUI method

1. Open **Server Manager**.
2. Select **Manage > Add Roles and Features**.
3. Select **Role-based or feature-based installation**.
4. Select DC01.
5. Select **Active Directory Domain Services**.
6. Add the management tools when prompted.
7. Complete the installation.
8. Select the notification flag.
9. Select **Promote this server to a domain controller**.
10. Select **Add a new forest**.
11. Root domain name: `helpdesk.test`.
12. Keep DNS Server and Global Catalog selected.
13. Enter a Directory Services Restore Mode password.
14. Accept the default paths.
15. Complete the prerequisite check.
16. Select **Install**.
17. Allow the VM to restart.

### PowerShell method

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
    -DomainName "helpdesk.test" `
    -DomainNetbiosName "HELPDESK" `
    -InstallDNS
```

You will be prompted for the Directory Services Restore Mode password.

### Validate the domain controller

Sign in as `HELPDESK\Administrator`, then run:

```powershell
dcdiag
Get-ADDomain
Get-ADForest
Get-DnsServerZone
```

Take a snapshot named `DC01-ADDS-Configured`.

## 6. Create the OU structure

Open **Server Manager > Tools > Active Directory Users and Computers**.

1. Right-click `helpdesk.test`.
2. Select **New > Organizational Unit**.
3. Create `Lab`.
4. Under `Lab`, create:
   - `Users`
   - `Computers`
   - `Groups`
5. Under `Users`, create:
   - `HR`
   - `Sales`
   - `IT`
6. Under `Computers`, create:
   - `Workstations`

Keep **Protect container from accidental deletion** enabled.

Result:

```text
helpdesk.test
└── Lab
    ├── Users
    │   ├── HR
    │   ├── Sales
    │   └── IT
    ├── Computers
    │   └── Workstations
    └── Groups
```

## 7. Create groups and users

### Create department groups

In the `Groups` OU, create:

| Group | Scope | Type |
|---|---|---|
| GG_HR_Users | Global | Security |
| GG_Sales_Users | Global | Security |
| GG_IT_Users | Global | Security |

### Create users

Create the following users in their department OUs:

| Full name | Username | OU |
|---|---|---|
| Alice Johnson | ajohnson | HR |
| Bob Smith | bsmith | Sales |
| Carol Lee | clee | IT |

For each user:

1. Right-click the correct department OU.
2. Select **New > User**.
3. Enter the name and username.
4. Assign a temporary password.
5. Select **User must change password at next logon**.
6. Finish.
7. Add the user to the correct department group.

Optional automation:

```powershell
.\scripts\Create-LabObjects.ps1
```

Run the script from an elevated PowerShell window on DC01 after copying it into the VM.

## 8. Create CL01

1. Create a new VM named `CL01`.
2. Select the Windows 11 Enterprise evaluation ISO.
3. Allocate two vCPUs, 4–6 GB RAM, and a 64 GB virtual disk.
4. Enable EFI, virtual TPM 2.0, and Secure Boot when required by the guest.
5. Attach Adapter 1 to the same host-only network used by DC01.
6. Install Windows 11 Enterprise.
7. Complete the out-of-box setup using the sign-in method offered by the current evaluation media.
   - If internet access is required, temporarily add a second VirtualBox adapter set to **NAT**.
   - Use a lab-only account rather than a work, school, or sensitive personal account.
   - After setup, create a local administrator named `LabAdmin`.
   - Remove or disable the temporary NAT adapter before configuring domain DNS and joining the domain.
8. Install Guest Additions if desired.
9. Take a snapshot named `CL01-Clean-Install`.

## 9. Configure CL01 networking

### Rename the PC

Open an elevated PowerShell window:

```powershell
Rename-Computer -NewName "CL01" -Restart
```

### Assign IPv4 and DNS

After restart:

```powershell
Get-NetAdapter

New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress 192.168.56.101 `
    -PrefixLength 24

Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet" `
    -ServerAddresses 192.168.56.10
```

Verify:

```powershell
ipconfig /all
ping 192.168.56.10
ping DC01
nslookup helpdesk.test
nslookup DC01.helpdesk.test
```

Do not use a public DNS server on the domain client. The client must query the AD DNS server to locate the domain controller.

## 10. Join CL01 to the domain

### GUI method

1. Open **Settings > System > About**.
2. Select **Domain or workgroup** or open **Advanced system settings**.
3. Select **Computer Name > Change**.
4. Select **Domain**.
5. Enter `helpdesk.test`.
6. Enter `HELPDESK\Administrator` credentials.
7. Confirm the welcome message.
8. Restart.

### PowerShell method

```powershell
Add-Computer `
    -DomainName "helpdesk.test" `
    -Credential "HELPDESK\Administrator" `
    -Restart
```

After restart, select **Other user** and sign in with:

```text
HELPDESK\ajohnson
```

or:

```text
ajohnson@helpdesk.test
```

On DC01, move the `CL01` computer object from the default Computers container into:

```text
Lab > Computers > Workstations
```

## 11. Practice resetting a password

On DC01:

1. Open **Active Directory Users and Computers**.
2. Find `Alice Johnson`.
3. Right-click the account.
4. Select **Reset Password**.
5. Enter a temporary password.
6. Select **User must change password at next logon**.
7. Save a screenshot without revealing the password.
8. On CL01, verify that Alice can sign in and is required to choose a new password.

PowerShell alternative:

```powershell
$Password = Read-Host "Enter temporary password" -AsSecureString
Set-ADAccountPassword -Identity "ajohnson" -Reset -NewPassword $Password
Set-ADUser -Identity "ajohnson" -ChangePasswordAtLogon $true
```

## 12. Practice account lockout and unlock

### Configure a lab-only lockout policy

Create a GPO named:

```text
GPO-Domain-Account-Lockout-Lab
```

Link it to the domain root, then configure:

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Account Policies
                └── Account Lockout Policy
```

Suggested lab values:

| Setting | Lab value |
|---|---:|
| Account lockout threshold | 5 invalid attempts |
| Account lockout duration | 15 minutes |
| Reset account lockout counter after | 15 minutes |

These intentionally aggressive values are for an isolated training lab, not a production recommendation.

On CL01:

1. Attempt to sign in as `bsmith` with the wrong password five times.
2. Confirm that the account becomes locked.

On DC01:

1. Open Bob Smith's account properties.
2. Open the **Account** tab.
3. Confirm the lockout state.
4. Select **Unlock account**.
5. Apply the change.
6. Verify successful sign-in on CL01.

PowerShell checks:

```powershell
Search-ADAccount -LockedOut
Unlock-ADAccount -Identity "bsmith"
```

## 13. Create and apply Group Policies

### GPO 1: Workstation sign-in banner

Create:

```text
GPO-Workstations-Logon-Banner
```

Link it to:

```text
Lab > Computers > Workstations
```

Edit:

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Local Policies
                └── Security Options
```

Configure:

- **Interactive logon: Message title for users attempting to log on**
  - `Authorized IT Help Desk Lab`
- **Interactive logon: Message text for users attempting to log on**
  - `Training system - activity may be monitored.`

### GPO 2: User restriction

Create:

```text
GPO-HR-Disable-Control-Panel
```

Link it to the HR OU.

Edit:

```text
User Configuration
└── Policies
    └── Administrative Templates
        └── Control Panel
            └── Prohibit access to Control Panel and PC settings
```

Set it to **Enabled**.

### Apply and validate

On CL01:

```powershell
gpupdate /force
gpresult /r
gpresult /h C:\Temp\gpresult.html
```

Restart CL01 to test the computer policy. Sign in as `ajohnson` to test the HR user policy.

Verify:

- The sign-in banner appears.
- Alice cannot open Control Panel or Settings.
- `gpresult` lists the expected GPOs.

## 14. Final validation commands

On DC01:

```powershell
dcdiag
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName

Get-ADUser -Filter * -SearchBase "OU=Users,OU=Lab,DC=helpdesk,DC=test" |
    Select-Object Name, SamAccountName, Enabled

Get-ADComputer -Filter * |
    Select-Object Name, DistinguishedName

Get-GPO -All |
    Select-Object DisplayName, GpoStatus
```

On CL01:

```powershell
whoami
hostname
ipconfig /all
nltest /dsgetdc:helpdesk.test
gpresult /r
```

Run the included verification script on DC01:

```powershell
.\scripts\Verify-Lab.ps1
```

Save the generated report in `evidence/reports/`.

## 15. Snapshot plan

Recommended snapshots:

1. `DC01-Clean-Install`
2. `DC01-ADDS-Configured`
3. `DC01-OUs-Users-GPOs`
4. `CL01-Clean-Install`
5. `CL01-Domain-Joined`
6. `Lab-Completed`

Do not treat snapshots as backups for a production domain. They are useful here only because this is a disposable training environment.
