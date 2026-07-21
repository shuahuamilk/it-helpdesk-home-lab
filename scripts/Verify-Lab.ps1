#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string]$OutputPath = ".\Lab-Verification-Report.txt"
)

$ErrorActionPreference = "Continue"

$report = [System.Collections.Generic.List[string]]::new()

function Add-Section {
    param([string]$Title)

    $report.Add("")
    $report.Add(("=" * 70))
    $report.Add($Title)
    $report.Add(("=" * 70))
}

function Add-CommandOutput {
    param(
        [string]$Label,
        [scriptblock]$Command
    )

    Add-Section $Label

    try {
        $output = & $Command | Out-String
        $report.Add($output.TrimEnd())
    }
    catch {
        $report.Add("ERROR: $($_.Exception.Message)")
    }
}

$report.Add("IT Help Desk Home Lab Verification Report")
$report.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$report.Add("Computer: $env:COMPUTERNAME")
$report.Add("User: $env:USERDOMAIN\$env:USERNAME")

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory

    Add-CommandOutput "Domain" {
        Get-ADDomain |
            Format-List DNSRoot, NetBIOSName, DomainMode, PDCEmulator
    }

    Add-CommandOutput "Forest" {
        Get-ADForest |
            Format-List Name, ForestMode, RootDomain, GlobalCatalogs
    }

    Add-CommandOutput "Organizational Units" {
        Get-ADOrganizationalUnit -Filter * |
            Sort-Object DistinguishedName |
            Select-Object Name, DistinguishedName |
            Format-Table -AutoSize
    }

    Add-CommandOutput "Lab Users" {
        Get-ADUser `
            -Filter * `
            -SearchBase "OU=Users,OU=Lab,DC=helpdesk,DC=test" `
            -Properties Department, Enabled, LockedOut |
            Select-Object Name, SamAccountName, Department, Enabled, LockedOut |
            Format-Table -AutoSize
    }

    Add-CommandOutput "Computers" {
        Get-ADComputer -Filter * |
            Select-Object Name, DistinguishedName |
            Format-Table -AutoSize
    }

    Add-CommandOutput "Locked Accounts" {
        Search-ADAccount -LockedOut |
            Select-Object Name, SamAccountName |
            Format-Table -AutoSize
    }

    Add-CommandOutput "Default Domain Password Policy" {
        Get-ADDefaultDomainPasswordPolicy |
            Format-List ComplexityEnabled,
                        LockoutDuration,
                        LockoutObservationWindow,
                        LockoutThreshold,
                        MaxPasswordAge,
                        MinPasswordLength
    }
}
else {
    Add-Section "Active Directory module"
    $report.Add("ActiveDirectory PowerShell module is unavailable.")
}

if (Get-Module -ListAvailable -Name GroupPolicy) {
    Import-Module GroupPolicy

    Add-CommandOutput "Group Policy Objects" {
        Get-GPO -All |
            Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime |
            Sort-Object DisplayName |
            Format-Table -AutoSize
    }
}
else {
    Add-Section "Group Policy module"
    $report.Add("GroupPolicy PowerShell module is unavailable.")
}

Add-CommandOutput "Domain Controller Diagnostics Summary" {
    dcdiag /q
    if ($LASTEXITCODE -eq 0) {
        "dcdiag /q returned no errors."
    }
}

$report | Set-Content -Path $OutputPath -Encoding UTF8
$report | ForEach-Object { Write-Host $_ }

Write-Host ""
Write-Host "Report saved to: $((Resolve-Path $OutputPath).Path)"
