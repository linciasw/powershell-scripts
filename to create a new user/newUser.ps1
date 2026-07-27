Import-Module ActiveDirectory

# ==========================
# Configuration
# ==========================

$CSVPath = "C:\Scripts\newUsers.csv"

$OU = "OU=Trinidad Citrix Users,DC=firstcitizens,DC=local"

$LogPath = "C:\Scripts\NewUsers_Log.csv"


# ==========================
# Validate OU
# ==========================

try {
    Get-ADOrganizationalUnit -Identity $OU -ErrorAction Stop
    Write-Host "OU validated successfully" -ForegroundColor Green
}
catch {
    Write-Host "OU does not exist: $OU" -ForegroundColor Red
    exit
}


# ==========================
# Import CSV
# ==========================

$Users = Import-Csv $CSVPath

$Results = @()


# ==========================
# Password Generator
# ==========================

function New-TemporaryPassword {

    $Password = "Fc@" + (Get-Random -Minimum 10000 -Maximum 99999)

    return $Password
}


# ==========================
# Create Users
# ==========================

foreach ($User in $Users) {

    Write-Host ""
    Write-Host "Processing $($User.DisplayName)..." -ForegroundColor Cyan


    try {

        # Check if user exists

        $ExistingUser = Get-ADUser `
            -Filter "SamAccountName -eq '$($User.Username)'" `
            -ErrorAction SilentlyContinue


        if ($ExistingUser) {

            Write-Host "SKIPPED: $($User.Username) already exists" -ForegroundColor Yellow


            $Results += [PSCustomObject]@{
                Username = $User.Username
                Name = $User.DisplayName
                Status = "Skipped - Already Exists"
                Date = Get-Date
            }

            continue
        }


        # Generate Password

        $PlainPassword = New-TemporaryPassword

        $SecurePassword = ConvertTo-SecureString `
            $PlainPassword `
            -AsPlainText `
            -Force



        # Create AD User
        New-ADUser `
            -Name $User.DisplayName `
            -DisplayName $User.DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $User.Username `
            -UserPrincipalName "$($User.Username)@firstcitizensgroup.net" `
            -Title $User.JobTitle `
            -Department $User.Department `
            -Description $User.Department `
            -Company "First Citizens" `
            -Path $OU `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -AccountExpirationDate ([datetime]::ParseExact($User.endDate,'dd-MMM-yy',$null)) `
            -ChangePasswordAtLogon $true



        # Add user to Staff_Internet group

        Add-ADGroupMember `
                -Identity "Staff_Internet" `
                -Members $User.Username

        Write-Host "Added $($User.Username) to Staff_Internet group" -ForegroundColor Green




        # Add Start/End Dates

        Set-ADUser $User.Username `
            -Add @{
                extensionAttribute1 = $User.startDate
                extensionAttribute2 = $User.endDate
            }



        # Verify creation

        Start-Sleep -Seconds 2

        $CreatedUser = Get-ADUser `
            -Identity $User.Username `
            -Properties DistinguishedName



        if ($CreatedUser) {

            Write-Host "CREATED: $($User.Username)" -ForegroundColor Green


            $Results += [PSCustomObject]@{

                Username = $User.Username
                Name = $User.DisplayName
                Email = $User.Email
                TemporaryPassword = $PlainPassword
                OU = $CreatedUser.DistinguishedName
                Status = "Created"
                Date = Get-Date

            }

        }

    }


    catch {

        Write-Host "FAILED: $($User.Username)" -ForegroundColor Red

        Write-Host $_.Exception.Message


        $Results += [PSCustomObject]@{

            Username = $User.Username
            Name = $User.DisplayName
            Status = "Failed - $($_.Exception.Message)"
            Date = Get-Date

        }

    }

}


# ==========================
# Export Log
# ==========================

$Results | Export-Csv `
    -Path $LogPath `
    -NoTypeInformation


Write-Host ""
Write-Host "=================================" -ForegroundColor Green
Write-Host "Completed"
Write-Host "Log saved to: $LogPath"
Write-Host "=================================" -ForegroundColor Green