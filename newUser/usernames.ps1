Import-Module ActiveDirectory

# Path to your CSV
$CSVPath = "\\pkshares\Helpdesk\Scripts\newUser\newUsers.csv"

# Import CSV
$Users = Import-Csv $CSVPath

function Get-NewUsername {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FirstName,

        [Parameter(Mandatory = $true)]
        [string]$LastName
    )

    # Clean names
    $FirstName = ($FirstName -replace '[^a-zA-Z]', '').ToLower()
    $LastName  = ($LastName -replace '[^a-zA-Z]', '').ToLower()

    # Store possible usernames in order
    $UsernameOptions = @()

    # Option 1: First initial + Last name
    $UsernameOptions += $FirstName.Substring(0,1) + $LastName

    # Option 2: Full first name
    $UsernameOptions += $FirstName

    # Option 3: Full first name + first letter of last name
    $UsernameOptions += $FirstName + $LastName.Substring(0,1)

    # Option 4: Full first name + first two letters of last name
    if ($LastName.Length -ge 2) {
        $UsernameOptions += $FirstName + $LastName.Substring(0,2)
    }
    else {
        $UsernameOptions += $FirstName + $LastName
    }


    # Check each option
    foreach ($Username in $UsernameOptions) {

        Write-Host "Checking username: $Username"

        if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
            return $Username
        }
    }


    # If all options exist, add numbers
    $BaseUsername = $UsernameOptions[-1]
    $Counter = 1

    while ($true) {

        $Username = "$BaseUsername$Counter"

        Write-Host "Checking username: $Username"

        if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
            return $Username
        }

        $Counter++
    }
}


# Generate usernames
foreach ($User in $Users) {

    # Skip existing usernames
    if (![string]::IsNullOrWhiteSpace($User.Username)) {

        Write-Host "Skipping $($User.FirstName) $($User.LastName) - Existing username: $($User.Username)"
        continue
    }


    $NewUsername = Get-NewUsername `
        -FirstName $User.FirstName `
        -LastName $User.LastName


    $User.Username = $NewUsername

    Write-Host "Generated username for $($User.FirstName) $($User.LastName): $NewUsername"
}


# Export updated CSV
$Users | Export-Csv $CSVPath -NoTypeInformation -Encoding UTF8


Write-Host ""
Write-Host "====================================="
Write-Host "Username generation complete."
Write-Host "CSV updated:"
Write-Host $CSVPath
Write-Host "====================================="