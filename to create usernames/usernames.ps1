Import-Module ActiveDirectory

# Path to your CSV
$CSVPath = ".\newUsers.csv"

# Import the CSV
$Users = Import-Csv $CSVPath

function Get-NewUsername {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FirstName,

        [Parameter(Mandatory = $true)]
        [string]$LastName
    )

    # Remove spaces and special characters, then convert to lowercase
    $FirstName = ($FirstName -replace '[^a-zA-Z]', '').ToLower()
    $LastName  = ($LastName -replace '[^a-zA-Z]', '').ToLower()

    # Option 1: First initial + Last name (jsmith)
    $Username = $FirstName.Substring(0,1) + $LastName

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
        return $Username
    }

    # Option 2: Full first name + First initial of last name (johns)
    $Username = $FirstName + $LastName.Substring(0,1)

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
        return $Username
    }

    # Option 3: Full first name + First two letters of last name (johnsm)
    if ($LastName.Length -ge 2) {
        $Username = $FirstName + $LastName.Substring(0,2)
    }
    else {
        $Username = $FirstName + $LastName
    }

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
        return $Username
    }

    # Option 4: Append numbers (johnsm1, johnsm2, ...)
    $BaseUsername = $Username
    $Counter = 1

    while ($true) {

        $Username = "$BaseUsername$Counter"

        if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
            return $Username
        }

        $Counter++
    }
}

# Generate usernames and update the CSV
foreach ($User in $Users) {

    # Skip users that already have a username
    if (![string]::IsNullOrWhiteSpace($User.Username)) {
        Write-Host "Skipping $($User.FirstName) $($User.LastName) - Username already exists in CSV: $($User.Username)"
        continue
    }

    $User.Username = Get-NewUsername `
        -FirstName $User.FirstName `
        -LastName $User.LastName

    Write-Host "Generated username for $($User.FirstName) $($User.LastName): $($User.Username)"
}

# Save the updated CSV
$Users | Export-Csv $CSVPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Username generation complete."
Write-Host "Updated CSV saved to: $CSVPath"