#Requires -RunAsAdministrator
#Requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$DomainDn = "DC=helpdesk,DC=test"
)

$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$initialPassword = Read-Host `
    "Enter the temporary password for all demonstration users" `
    -AsSecureString

$ouDefinitions = @(
    @{ Name = "Lab";          Path = $DomainDn },
    @{ Name = "Users";        Path = "OU=Lab,$DomainDn" },
    @{ Name = "Computers";    Path = "OU=Lab,$DomainDn" },
    @{ Name = "Groups";       Path = "OU=Lab,$DomainDn" },
    @{ Name = "HR";           Path = "OU=Users,OU=Lab,$DomainDn" },
    @{ Name = "Sales";        Path = "OU=Users,OU=Lab,$DomainDn" },
    @{ Name = "IT";           Path = "OU=Users,OU=Lab,$DomainDn" },
    @{ Name = "Workstations"; Path = "OU=Computers,OU=Lab,$DomainDn" }
)

foreach ($ou in $ouDefinitions) {
    $distinguishedName = "OU=$($ou.Name),$($ou.Path)"
    if (-not (Get-ADOrganizationalUnit `
        -Identity $distinguishedName `
        -ErrorAction SilentlyContinue)) {

        New-ADOrganizationalUnit `
            -Name $ou.Name `
            -Path $ou.Path `
            -ProtectedFromAccidentalDeletion $true

        Write-Host "Created OU: $distinguishedName"
    }
    else {
        Write-Host "OU already exists: $distinguishedName"
    }
}

$groupsOu = "OU=Groups,OU=Lab,$DomainDn"

$groups = @(
    "GG_HR_Users",
    "GG_Sales_Users",
    "GG_IT_Users"
)

foreach ($groupName in $groups) {
    if (-not (Get-ADGroup -Filter "SamAccountName -eq '$groupName'")) {
        New-ADGroup `
            -Name $groupName `
            -SamAccountName $groupName `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $groupsOu

        Write-Host "Created group: $groupName"
    }
    else {
        Write-Host "Group already exists: $groupName"
    }
}

$users = @(
    @{
        GivenName = "Alice"
        Surname = "Johnson"
        SamAccountName = "ajohnson"
        Department = "HR"
        Group = "GG_HR_Users"
    },
    @{
        GivenName = "Bob"
        Surname = "Smith"
        SamAccountName = "bsmith"
        Department = "Sales"
        Group = "GG_Sales_Users"
    },
    @{
        GivenName = "Carol"
        Surname = "Lee"
        SamAccountName = "clee"
        Department = "IT"
        Group = "GG_IT_Users"
    }
)

foreach ($user in $users) {
    $userPath = "OU=$($user.Department),OU=Users,OU=Lab,$DomainDn"
    $displayName = "$($user.GivenName) $($user.Surname)"

    if (-not (Get-ADUser `
        -Filter "SamAccountName -eq '$($user.SamAccountName)'")) {

        New-ADUser `
            -Name $displayName `
            -GivenName $user.GivenName `
            -Surname $user.Surname `
            -DisplayName $displayName `
            -SamAccountName $user.SamAccountName `
            -UserPrincipalName "$($user.SamAccountName)@helpdesk.test" `
            -Department $user.Department `
            -Path $userPath `
            -AccountPassword $initialPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Created user: $displayName"
    }
    else {
        Write-Host "User already exists: $displayName"
    }

    Add-ADGroupMember `
        -Identity $user.Group `
        -Members $user.SamAccountName `
        -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Lab OUs, groups, and users are ready."
Write-Host "Review them in Active Directory Users and Computers."
