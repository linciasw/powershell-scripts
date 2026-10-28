
# ============================================================
# Active Directory OU Account Review
# Read-only account review and cleanup report
# ============================================================

Import-Module ActiveDirectory -ErrorAction Stop

# Ask for the OU to review
$SearchOU = Read-Host "Enter OU distinguished name (DN)"

# Validate that the OU exists
try {
    $null = Get-ADOrganizationalUnit -Identity $SearchOU -ErrorAction Stop
}
catch {
    Write-Host "ERROR: OU not found or inaccessible: $SearchOU" -ForegroundColor Red
    return
}

$Today = Get-Date

Write-Host "`nRetrieving Active Directory users..." -ForegroundColor Cyan

try {
    $Users = Get-ADUser `
        -Filter * `
        -SearchBase $SearchOU `
        -SearchScope Subtree `
        -Properties Department, Description, Company, Manager,
                    AccountExpirationDate, WhenChanged, Mail, Enabled `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Unable to retrieve users. $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Build the review report
$Report = foreach ($User in $Users) {

    # Extract the OU path from the distinguished name
    $OUPath = ($User.DistinguishedName -split ',', 2)[1]

    # Resolve manager name
    $ManagerName = if ($User.Manager) {
        try {
            (Get-ADUser -Identity $User.Manager `
                -Properties DisplayName `
                -ErrorAction Stop).DisplayName
        }
        catch {
            "Manager lookup failed"
        }
    }
    else {
        "Not recorded"
    }

    # Determine account expiration status
    $ExpiryStatus = if (-not $User.AccountExpirationDate) {
        "No expiry recorded - verify"
    }
    elseif ($User.AccountExpirationDate -lt $Today) {
        "Expired"
    }
    else {
        "Not expired"
    }

    # Collect review issues
    $Issues = [System.Collections.Generic.List[string]]::new()

    if (-not $User.Department) {
        $Issues.Add("Missing department")
    }

    if (-not $User.Description) {
        $Issues.Add("Missing description")
    }

    if (-not $User.Company) {
        $Issues.Add("Missing company")
    }

    if (-not $User.Manager) {
        $Issues.Add("Manager not recorded")
    }

    if (-not $User.AccountExpirationDate) {
        $Issues.Add("Verify end date")
    }

    if (-not $User.Enabled) {
        $Issues.Add("DISABLED - verify staff status")
    }

    if ($User.AccountExpirationDate -and
        $User.AccountExpirationDate -lt $Today) {
        $Issues.Add("Account expired")
    }

    # Create one report row per user
    [PSCustomObject]@{
        Name           = $User.DisplayName
        Username       = $User.SamAccountName
        AccountStatus  = if ($User.Enabled) { "Enabled" } else { "DISABLED" }
        Department     = $User.Department
        Description    = $User.Description
        Company        = $User.Company
        OU             = $OUPath
        EndDate        = $User.AccountExpirationDate
        ExpiryStatus   = $ExpiryStatus
        Manager        = $ManagerName
        Email          = $User.Mail
        LastADChange   = $User.WhenChanged
        ReviewRequired = if ($Issues.Count -gt 0) {
            $Issues -join "; "
        }
        else {
            "No basic attribute issues detected"
        }
    }
}

# Display the complete report
Write-Host "`n========== ACTIVE DIRECTORY OU REVIEW ==========" -ForegroundColor Cyan
Write-Host "OU searched: $SearchOU"
Write-Host "Report date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host ""

$Report |
    Sort-Object OU, Name |
    Format-Table Name, Username, AccountStatus, Department,
                 Company, EndDate, Manager, ReviewRequired `
                 -Wrap -AutoSize

# Summary
$DisabledCount = @($Report | Where-Object {
    $_.AccountStatus -eq "DISABLED"
}).Count

$ReviewCount = @($Report | Where-Object {
    $_.ReviewRequired -ne "No basic attribute issues detected"
}).Count

Write-Host "`n================ REVIEW SUMMARY ================" -ForegroundColor Cyan
Write-Host "Total users: $($Report.Count)"
Write-Host "Enabled users: $(($Report | Where-Object { $_.AccountStatus -eq 'Enabled' }).Count)"
Write-Host "Disabled users: $DisabledCount" -ForegroundColor Yellow
Write-Host "Users requiring review: $ReviewCount"
Write-Host "================================================"

# Open a sortable, filterable report window if available
if (Get-Command Out-GridView -ErrorAction SilentlyContinue) {
    $Report |
        Sort-Object OU, Name |
        Out-GridView -Title "Active Directory OU Account Review"
}
else {
    Write-Host "`nOut-GridView is unavailable. The table above contains the report."
}

# Keep the full report available in the current PowerShell session.
Write-Host "`nThe full report is available in the `$Report variable." -ForegroundColor Green
