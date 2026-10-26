# Helpdesk Script Utility

A PowerShell command-line menu for common Windows helpdesk tasks.

## Features

1. View NTFS permissions for a file or folder.
2. Calculate sizes of immediate subfolders under a selected path.
3. Report sizes of user profiles.
4. Search for files by name.
5. Retrieve a remote computer's BIOS serial number.
6. Copy a file to the logged-on user's Desktop on selected remote computers.

## Requirements

- Windows with Windows PowerShell 5.1 or later.
- Appropriate access to the folders and computers being checked.
- Remote CIM access and administrative-share access for remote tasks.
- Network connectivity to target computers.

## Running the utility

1. Open PowerShell in the repository's \`helpdeskUtility\` directory.
2. Run:

   \`\`\`powershell
   .\Start-HelpdeskUtility.ps1
   \`\`\`

3. Choose a menu option and follow the prompts. Enter \`0\` to exit.

Use your organisation's approved PowerShell execution policy. Do not change machine-wide policy just to run this script.

## Remote file copy

The computer list should contain one computer name per line. Blank lines and lines beginning with \`#\` are ignored.

Example \`pcs.txt\`:

   \`\`\`text
   PC001
   PC002
   PC003
   \`\`\`

The utility lists targets and requires you to type \`COPY\` before copying. It uses your current Windows credentials and does not collect or store passwords.

The destination is assumed to be \`C:\Users\<username>\Desktop\` on each remote computer. Copying can fail if the profile is redirected, no user is logged on, the administrative share is unavailable, or permissions are insufficient. A same-named destination file may be overwritten.

## Limitations

- Recursive folder scans can take a long time.
- Access-denied files may be skipped, making size reports incomplete.
- A failed ping does not conclusively mean a computer is offline; ICMP may be blocked.
- Remote CIM calls require remote management to be configured.
- Use only on systems and resources you are authorised to administer.
- Test the utility in a safe environment before operational use.

## Suggested tests

- View permissions on a folder you can access.
- Calculate sizes for a small test directory.
- Search a test directory for a known filename.
- Query the BIOS serial number of an authorised test computer.
- Test copying on one approved test computer before using a larger list.
