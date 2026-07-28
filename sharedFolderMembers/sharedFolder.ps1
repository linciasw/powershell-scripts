# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for the security group name
$GroupName = Read-Host "Enter the Shared Folder Security Group name"

# Save the CSV in the same folder as the script
# Save the CSV to the user's Desktop
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$OutputFile = Join-Path $DesktopPath "$($GroupName)_Members.csv"

try {
    # Get all members (including nested groups)
    $GroupMembers = Get-ADGroupMember -Identity $GroupName -Recursive -ErrorAction Stop

    # Get user details
    $Export = foreach ($Member in $GroupMembers) {
        if ($Member.objectClass -eq "user") {
            Get-ADUser $Member -Properties mail |
                Select-Object Name, SamAccountName, mail
        }
    }

    # Export to CSV
    $Export | Export-Csv -Path $OutputFile -NoTypeInformation

    # Display results
    Write-Host ""
    Write-Host "Export completed successfully!" -ForegroundColor Green
    Write-Host "Security Group: $GroupName"
    Write-Host "Members exported: $($Export.Count)"
    Write-Host "File saved to: $OutputFile" -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "Error: Security group '$GroupName' was not found or could not be accessed." -ForegroundColor Red
}