# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt user for the group name
$GroupName = Read-Host "Enter the email group name"

# Get group members
$GroupMembers = Get-ADGroupMember -Identity $GroupName -Recursive

# Get useful properties from each member
$Export = $GroupMembers | ForEach-Object {
    Get-ADUser $_.DistinguishedName -Properties mail |
    Select-Object Name, SamAccountName, mail
}

# Create output file
$OutputFile = "$env:USERPROFILE\Desktop\$($GroupName)_Members.csv"

# Export to CSV
$Export | Export-Csv -Path $OutputFile -NoTypeInformation

# Display result
Write-Host ""
Write-Host "Export completed successfully!" -ForegroundColor Green
Write-Host "Group: $GroupName"
Write-Host "Members exported: $($Export.Count)"
Write-Host "File saved to: $OutputFile" -ForegroundColor Yellow

# Pause so user can read the message
Pause