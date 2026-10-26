# Helpdesk Toolkit

A categorized Windows command-line menu for common helpdesk tasks. The batch file provides the main menu and submenus; PowerShell performs the reporting and computer-support tasks and launches the existing shared workflows.

## Start the toolkit

From the repository root, double-click generalMenu.bat or run it from Command Prompt. You can also launch helpdeskUtility\Start-HelpdeskToolkit.bat directly.

### Important: network-share deployment

Deploy BOTH files below into the same folder, for example \\pkshares\Helpdesk\Scripts\helpdeskUtility\:

- Start-HelpdeskToolkit.bat
- Start-HelpdeskUtility.ps1

The launcher uses pushd to handle a UNC path as a working directory. However, it cannot run if the PowerShell script is missing from the deployed folder. Updating GitHub does not automatically copy the updated files to the network share. If the missing-script error appears, copy Start-HelpdeskUtility.ps1 from the GitHub helpdeskUtility folder to the network folder beside the batch file.

## Menu structure

### 1. User and Access Management
- Create New User — launches the existing \\pkshares\Helpdesk\Scripts\newUser\newUser.bat workflow.
- Export Email Group Members — launches \\pkshares\Helpdesk\Scripts\emailGroupMembers\emailGroups.ps1.
- Export Shared Folder Members — launches \\pkshares\Helpdesk\Scripts\sharedFolderMembers\sharedFolder.ps1.

### 2. Computer Support
- Get Remote Computer BIOS Serial Number.
- Copy a file to the logged-on user's Desktop on selected remote computers.

### 3. Troubleshooting and Reports
- View file/folder NTFS permissions.
- Report sizes of immediate subfolders under a selected path.
- Report user profile sizes.
- Search for files by name.

The batch menu invokes PowerShell with a specific task, so users go straight to the selected task rather than seeing a second menu. You can still run Start-HelpdeskUtility.ps1 directly to use its standalone PowerShell menu.

## Requirements and permissions

- Windows with Windows PowerShell 5.1 or later.
- Appropriate access to the folders and computers being checked.
- Remote CIM access and administrative-share access for remote tasks.
- Network access and permissions to use the existing scripts on \\pkshares\Helpdesk\Scripts.
- Use only on systems and resources you are authorised to administer.

The launcher uses -ExecutionPolicy Bypass for the child PowerShell process only. Follow your organisation's approved execution policy and security procedures.

## Safety and limitations

- The New User and export options check that their shared scripts are accessible and ask for confirmation before launching.
- File copying lists the targets and requires typing COPY; a same-named destination file may be overwritten.
- The remote file-copy task assumes the destination is C:\Users\<username>\Desktop\. Redirected profiles, no logged-on user, blocked ping, missing permissions, or unavailable administrative shares can affect results.
- A failed ping does not conclusively mean a computer is offline; ICMP may be blocked.
- Recursive folder scans can take a long time, and access-denied files may be skipped.
- The actual network-dependent workflows have not been tested on your organisation's systems. Test from an authorised workstation before operational use.

## Suggested test plan

1. Confirm both launcher files are present in the same deployed helpdeskUtility folder.
2. Launch generalMenu.bat and confirm the three categories appear.
3. Open each category and return to the main menu using 0.
4. Run file search against a small test directory.
5. Check permissions on a folder you can access.
6. Run the folder-size reports against a small test path.
7. Test BIOS lookup on an authorised test computer.
8. Test file copy against one approved test computer and a harmless test file.
9. Test each existing shared workflow and confirm where it writes its output.
