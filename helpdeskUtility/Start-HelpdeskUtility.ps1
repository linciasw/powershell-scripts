<#
.SYNOPSIS
    Menu-driven utilities for common Windows helpdesk tasks.
.NOTES
    Use only on systems and resources you are authorised to administer.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Pause-ForMenu {
    [void](Read-Host 'Press Enter to return to the menu')
}

function Read-PathOrDefault {
    param([string]$Prompt, [string]$DefaultPath)
    $value = Read-Host "$Prompt [Default: $DefaultPath]"
    if ([string]::IsNullOrWhiteSpace($value)) { return $DefaultPath }
    return $value.Trim('"')
}

function Show-FolderPermissions {
    $path = Read-PathOrDefault 'Enter a folder or file path' '\\sscfs\LSU'
    try {
        $acl = Get-Acl -LiteralPath $path -ErrorAction Stop
        Write-Host ''
        Write-Host "Permissions for: $path" -ForegroundColor Cyan
        $acl.Access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited | Format-Table -AutoSize -Wrap
    } catch {
        Write-Host "Could not retrieve permissions: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-FolderSizeReport {
    $rootPath = Read-PathOrDefault 'Enter the drive or parent directory to scan' 'C:\'
    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        Write-Host "Folder not found: $rootPath" -ForegroundColor Red
        return
    }
    Write-Host "Scanning folders under $rootPath. This may take several minutes." -ForegroundColor Yellow
    try { $folders = Get-ChildItem -LiteralPath $rootPath -Directory -Force -ErrorAction Stop }
    catch { Write-Host "Could not list folders: $($_.Exception.Message)" -ForegroundColor Red; return }

    $results = foreach ($folder in $folders) {
        Write-Host "Scanning $($folder.FullName) ..."
        $measure = Get-ChildItem -LiteralPath $folder.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        $bytes = if ($null -eq $measure.Sum) { 0 } else { [double]$measure.Sum }
        [PSCustomObject]@{ Folder = $folder.FullName; SizeGB = [math]::Round(($bytes / 1GB), 2) }
    }
    $results | Sort-Object SizeGB -Descending | Format-Table -AutoSize -Wrap
}

function Get-UserProfileSizeReport {
    $rootPath = Read-PathOrDefault 'Enter the user profiles directory' 'C:\Users'
    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        Write-Host "Folder not found: $rootPath" -ForegroundColor Red
        return
    }
    Write-Host "Scanning user profiles under $rootPath. This may take several minutes." -ForegroundColor Yellow
    try { $profiles = Get-ChildItem -LiteralPath $rootPath -Directory -Force -ErrorAction Stop }
    catch { Write-Host "Could not list profiles: $($_.Exception.Message)" -ForegroundColor Red; return }

    $results = foreach ($profile in $profiles) {
        Write-Host "Scanning $($profile.FullName) ..."
        $measure = Get-ChildItem -LiteralPath $profile.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        $bytes = if ($null -eq $measure.Sum) { 0 } else { [double]$measure.Sum }
        [PSCustomObject]@{ Profile = $profile.Name; Path = $profile.FullName; SizeGB = [math]::Round(($bytes / 1GB), 2) }
    }
    $results | Sort-Object SizeGB -Descending | Format-Table -AutoSize -Wrap
}

function Search-FilesByName {
    $rootPath = Read-PathOrDefault 'Enter the directory to search' 'C:\'
    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        Write-Host "Folder not found: $rootPath" -ForegroundColor Red
        return
    }
    $term = Read-Host 'Enter a file-name term (example: carlene)'
    if ([string]::IsNullOrWhiteSpace($term)) { Write-Host 'A search term is required.' -ForegroundColor Red; return }
    if ($term.Contains('*') -or $term.Contains('?')) { $filter = $term } else { $filter = "*$term*" }

    Write-Host "Searching for '$filter' under $rootPath ..." -ForegroundColor Yellow
    $matches = @(Get-ChildItem -LiteralPath $rootPath -Filter $filter -File -Recurse -Force -ErrorAction SilentlyContinue)
    if ($matches.Count -eq 0) { Write-Host 'No matching files were found.'; return }
    $matches | Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize -Wrap
    Write-Host "Files found: $($matches.Count)"
}

function Get-RemoteBiosSerialNumber {
    $computer = Read-Host 'Enter the computer name'
    if ([string]::IsNullOrWhiteSpace($computer)) { Write-Host 'A computer name is required.' -ForegroundColor Red; return }
    try {
        $bios = Get-CimInstance -ClassName Win32_BIOS -ComputerName $computer.Trim() -ErrorAction Stop
        [PSCustomObject]@{ ComputerName = $computer.Trim(); SerialNumber = $bios.SerialNumber } | Format-List
    } catch {
        Write-Host "Could not retrieve the serial number: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host 'Check the computer name, permissions, firewall, and remote-management configuration.'
    }
}

function Copy-FileToRemoteComputers {
    Write-Host 'REMOTE FILE COPY' -ForegroundColor Cyan
    $sourcePath = Read-Host 'Enter the full path of the local source file'
    $listPath = Read-Host 'Enter the path to the text file containing computer names'
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { Write-Host "Source file not found: $sourcePath" -ForegroundColor Red; return }
    if (-not (Test-Path -LiteralPath $listPath -PathType Leaf)) { Write-Host "Computer list not found: $listPath" -ForegroundColor Red; return }

    try {
        $computers = @(Get-Content -LiteralPath $listPath -ErrorAction Stop | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') } | Select-Object -Unique)
    } catch { Write-Host "Could not read computer list: $($_.Exception.Message)" -ForegroundColor Red; return }
    if ($computers.Count -eq 0) { Write-Host 'The computer list is empty.' -ForegroundColor Red; return }

    $fileName = Split-Path -Path $sourcePath -Leaf
    Write-Host "Source file: $sourcePath"
    Write-Host "Destination: logged-on user's Desktop on each target"
    Write-Host 'Targets:'
    $computers | ForEach-Object { Write-Host "  - $_" }
    $confirmation = Read-Host "Type COPY to copy '$fileName' to these computers"
    if ($confirmation -cne 'COPY') { Write-Host 'Copy cancelled.'; return }

    $results = foreach ($computer in $computers) {
        Write-Host "Processing $computer ..." -ForegroundColor Cyan
        try {
            $online = Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue
            if (-not $online) {
                [PSCustomObject]@{ Computer = $computer; Status = 'Unreachable by ping'; Details = 'No copy attempted' }
                continue
            }
            $system = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer -ErrorAction Stop
            if ([string]::IsNullOrWhiteSpace($system.UserName)) {
                [PSCustomObject]@{ Computer = $computer; Status = 'No logged-on user'; Details = 'No copy attempted' }
                continue
            }
            $userName = ($system.UserName -split '\\')[-1]
            $destinationFolder = "\\$computer\C$\Users\$userName\Desktop"
            $destinationPath = Join-Path -Path $destinationFolder -ChildPath $fileName
            if (-not (Test-Path -LiteralPath $destinationFolder -PathType Container)) { throw "Desktop folder not accessible: $destinationFolder" }
            Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force -ErrorAction Stop
            [PSCustomObject]@{ Computer = $computer; Status = 'Success'; Details = $destinationPath }
        } catch {
            [PSCustomObject]@{ Computer = $computer; Status = 'Failed'; Details = $_.Exception.Message }
        }
    }
    Write-Host 'COPY RESULTS' -ForegroundColor Cyan
    $results | Format-Table -AutoSize -Wrap
}

function Start-NewUserWorkflow {
    [CmdletBinding()]
    param()

    # Reuse the existing, centrally maintained new-user workflow.
    $batchPath = '\\pkshares\Helpdesk\Scripts\newUser\newUser.bat'

    if (-not (Test-Path -LiteralPath $batchPath -PathType Leaf)) {
        Write-Host "The existing New User script is not accessible: $batchPath" -ForegroundColor Red
        Write-Host 'Check network connectivity and your access to the Helpdesk scripts share.'
        return
    }

    Write-Host ''
    Write-Host 'This will launch the existing New User workflow.' -ForegroundColor Yellow
    Write-Host "Script: $batchPath"
    $confirmation = Read-Host 'Type RUN to launch the New User workflow'

    if ($confirmation -cne 'RUN') {
        Write-Host 'New User workflow cancelled.'
        return
    }

    try {
        # Run the existing batch file in this console so its prompts remain visible.
        & $batchPath
        Write-Host 'The New User workflow has returned control to the utility.'
    }
    catch {
        Write-Host "Could not launch the New User workflow: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-ExistingExportWorkflow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkflowName,

        [Parameter(Mandatory)]
        [string]$ScriptPath
    )

    if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
        Write-Host "The $WorkflowName script is not accessible: $ScriptPath" -ForegroundColor Red
        Write-Host 'Check network connectivity and your access to the Helpdesk scripts share.'
        return
    }

    Write-Host ''
    Write-Host "This will launch the existing $WorkflowName workflow." -ForegroundColor Yellow
    Write-Host "Script: $ScriptPath"
    $confirmation = Read-Host 'Type RUN to launch this workflow'

    if ($confirmation -cne 'RUN') {
        Write-Host "$WorkflowName workflow cancelled."
        return
    }

    try {
        # Use a separate Windows PowerShell process, matching the original launcher.
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "$WorkflowName workflow exited with code $LASTEXITCODE." -ForegroundColor Yellow
        }
        else {
            Write-Host "$WorkflowName workflow has finished."
        }
    }
    catch {
        Write-Host "Could not launch the $WorkflowName workflow: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-EmailGroupExport {
    Start-ExistingExportWorkflow -WorkflowName 'Export Email Group Members' -ScriptPath '\\pkshares\Helpdesk\Scripts\emailGroupMembers\emailGroups.ps1'
}

function Start-SharedFolderExport {
    Start-ExistingExportWorkflow -WorkflowName 'Export Shared Folder Members' -ScriptPath '\\pkshares\Helpdesk\Scripts\sharedFolderMembers\sharedFolder.ps1'
}

function Show-HelpdeskMenu {
    while ($true) {
        Clear-Host
        Write-Host '============================================' -ForegroundColor Cyan
        Write-Host '          HELPDESK SCRIPT UTILITY' -ForegroundColor Cyan
        Write-Host '============================================' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '  1. View folder/file permissions (ACL)'
        Write-Host '  2. Report largest folders under a path'
        Write-Host '  3. Report user profile sizes'
        Write-Host '  4. Search for files by name'
        Write-Host '  5. Get remote computer BIOS serial number'
        Write-Host '  6. Copy a file to remote computers'
        Write-Host '  7. Create New User (existing workflow)'
        Write-Host '  8. Export Email Group Members (existing workflow)'
        Write-Host '  9. Export Shared Folder Members (existing workflow)'
        Write-Host ''
        Write-Host '  0. Exit'
        $choice = Read-Host 'Select an option'
        switch ($choice) {
            '1' { Show-FolderPermissions; Pause-ForMenu }
            '2' { Get-FolderSizeReport; Pause-ForMenu }
            '3' { Get-UserProfileSizeReport; Pause-ForMenu }
            '4' { Search-FilesByName; Pause-ForMenu }
            '5' { Get-RemoteBiosSerialNumber; Pause-ForMenu }
            '6' { Copy-FileToRemoteComputers; Pause-ForMenu }
            '7' { Start-NewUserWorkflow; Pause-ForMenu }
            '8' { Start-EmailGroupExport; Pause-ForMenu }
            '9' { Start-SharedFolderExport; Pause-ForMenu }
            '0' { return }
            default { Write-Host 'Invalid selection. Choose 0 through 9.' -ForegroundColor Red; Pause-ForMenu }
        }
    }
}

Show-HelpdeskMenu
