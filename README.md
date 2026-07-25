# Active Directory User Creation Script

## Overview

This PowerShell script automates the creation of Active Directory user accounts from a CSV file.

The script was created to simplify bulk user account creation while ensuring that all users are created with consistent attributes and settings.

The script will:

- Validate that the target Organizational Unit (OU) exists
- Import user information from a CSV file
- Check if users already exist before creation
- Create new Active Directory accounts
- Generate temporary passwords automatically
- Set account expiration dates
- Store start and end dates in extension attributes
- Configure user attributes
- Enable accounts
- Force users to change their password during first login
- Export a creation log showing successful, skipped, and failed accounts

---

# Requirements

Before running this script, confirm the following:

- You have permission to create users in Active Directory
- You have access to the target Organizational Unit (OU)
- The Active Directory PowerShell module is installed
- PowerShell scripts are allowed to run on your workstation
- You are running PowerShell as Administrator
- The CSV file has been created correctly

---

# PowerShell Preparation

## Confirm PowerShell Script Execution Is Allowed

Some environments restrict PowerShell script execution by default.

Open PowerShell and check the current execution policy:

```powershell
Get-ExecutionPolicy
```

If the result is:

```text
Restricted
```

PowerShell scripts will not run.

---

## Enable PowerShell Script Execution

Open **PowerShell as Administrator**.

To open PowerShell as Administrator:

1. Click Start
2. Search for **PowerShell**
3. Right-click **Windows PowerShell**
4. Select **Run as Administrator**

Run:

```powershell
Set-ExecutionPolicy RemoteSigned
```

Confirm the change:

```text
Y
```

Verify the execution policy:

```powershell
Get-ExecutionPolicy
```

The result should display:

```text
RemoteSigned
```

---

# Running the Script

The script requires elevated permissions.

Always run PowerShell as Administrator before executing the script.

Navigate to the script directory:

```powershell
cd C:\Scripts
```

Run the script:

```powershell
.\CreateUsers.ps1
```

---

# File Structure

The script expects the following folder structure:

```
C:\Scripts
│
├── CreateUsers.ps1
├── newUsers.csv
└── NewUsers_Log.csv
```

The `NewUsers_Log.csv` file will be created automatically after the script completes.

---

# CSV File Requirements

The script imports user information from:

```
C:\Scripts\newUsers.csv
```

The CSV file name must be exactly:

```
newUsers.csv
```

---

# Creating the CSV File

The CSV file should be created using Microsoft Excel.

## Saving the CSV Correctly

When saving the file:

1. Select **File**
2. Select **Save As**
3. Choose:

```
CSV (Comma delimited) (*.csv)
```

Do **NOT** choose:

```
CSV UTF-8 (Comma delimited) (*.csv)
```

The script requires a standard CSV file format.

Saving the file as UTF-8 may cause import issues when the script attempts to read the file.

---

# Required CSV Headers

The CSV file must contain the following headers exactly:

```text
Username
FirstName
LastName
DisplayName
Email
JobTitle
Department
startDate
endDate
```

Do not change the spelling or capitalization of these headers.

---

# Example CSV

| Username | FirstName | LastName | DisplayName | Email | JobTitle | Department | startDate | endDate |
|---|---|---|---|---|---|---|---|---|
| jsmith | John | Smith | John Smith | jsmith@firstcitizensgroup.net | Vacation Student | Finance | 01-Jun-26 | 31-Aug-26 |

---

# Date Format Requirements

The `endDate` field is used to set the user's Active Directory account expiration date.

The required date format is:

```
dd-MMM-yy
```

Examples:

```
01-Jun-26
31-Aug-26
15-Dec-26
```

Incorrect examples:

```
06/01/2026
2026-06-01
June 1 2026
```

The script will fail if the date format does not match.

---

# Active Directory Organizational Unit (OU)

All users created by this script will be placed into:

```
OU=Trinidad Citrix Users,DC=firstcitizens,DC=local
```

The script validates that this OU exists before creating users.

If the OU cannot be found, the script will stop.

---

# User Attributes Created

The script automatically sets the following attributes:

| Active Directory Attribute | Source |
|---|---|
| Name | DisplayName from CSV |
| Display Name | DisplayName from CSV |
| First Name | FirstName from CSV |
| Last Name | LastName from CSV |
| Username | Username from CSV |
| User Principal Name | Username@firstcitizensgroup.net |
| Email Address | Email from CSV |
| Job Title | JobTitle from CSV |
| Department | Department from CSV |
| Description | Department from CSV |
| Company | First Citizens |
| OU Location | Trinidad Citrix Users OU |

---

# Password Creation

The script automatically generates a temporary password for each new user.

Password format:

```
Fc@XXXXX
```

Example:

```
Fc@48291
```

The generated password is recorded in:

```
NewUsers_Log.csv
```

Users will be required to change their password during their first login.

---

# Account Expiration

The script automatically sets the Active Directory account expiration date using:

```
endDate
```

from the CSV file.

Example:

CSV:

```
endDate = 31-Aug-26
```

Active Directory:

```
Account expires = 31-Aug-26
```

---

# Start and End Date Storage

The script stores the following values in Active Directory extension attributes:

```
extensionAttribute1 = startDate
extensionAttribute2 = endDate
```

---

# Company Attribute

The Company attribute is automatically set by the script.

All created users will have:

```
Company = First Citizens
```

This value does not need to be included in the CSV file.

---

# Organizational Unit Assignment

The OU is automatically assigned by the script.

Users will be created in:

```
OU=Trinidad Citrix Users,DC=firstcitizens,DC=local
```

The OU does not need to be included in the CSV file.

---

# User Address Information

The script does not automatically populate user address information.

After user creation:

1. Open **Active Directory Users and Computers**
2. Locate the newly created user
3. Right-click the user
4. Select **Properties**
5. Select the **Address** tab
6. Manually enter the user's address information

---

# Duplicate User Checking

Before creating a user, the script checks if the username already exists.

If the account already exists:

- The account will not be created
- The user will be skipped
- The result will be recorded in the log file

---

# Log File

After completion, the script creates:

```
C:\Scripts\NewUsers_Log.csv
```

The log contains:

- Username
- Name
- Email Address
- Temporary Password
- OU Location
- Status
- Date Created

---

# Log Status Values

## Created

The user account was successfully created.

Example:

```
Status = Created
```

---

## Skipped - Already Exists

The username already exists in Active Directory.

Example:

```
Status = Skipped - Already Exists
```

---

## Failed

The account could not be created.

Example:

```
Status = Failed - Error Message
```

Review the error message in the log file.

---

# Troubleshooting

## Script Does Not Run

Confirm:

- PowerShell is running as Administrator
- Execution Policy allows scripts:

```powershell
Get-ExecutionPolicy
```

- The script path is correct

---

## CSV Import Errors

Confirm:

- The file name is:

```
newUsers.csv
```

- The file location is:

```
C:\Scripts
```

- The file was saved as:

```
CSV (Comma delimited)
```

and NOT:

```
CSV UTF-8
```

- The headers match exactly
- Dates use:

```
dd-MMM-yy
```

---

## OU Validation Failed

Confirm the OU exists:

```
OU=Trinidad Citrix Users,DC=firstcitizens,DC=local
```

Also confirm you have permission to create users in that OU.

---

## User Creation Failed

Check:

- Username format
- Required CSV fields
- Duplicate accounts
- Active Directory permissions
- Date formatting

Review:

```
C:\Scripts\NewUsers_Log.csv
```

for detailed error messages.

---

# Recommended Testing Process

Before creating multiple accounts:

1. Create a test CSV containing one user
2. Run the script
3. Confirm the account appears in Active Directory
4. Verify:
   - Username
   - Email address
   - Department
   - Company
   - Account expiration date
   - OU placement
   - Password creation
5. Confirm the user can log in successfully
6. Proceed with the full CSV import

---

# Script Configuration

The script currently uses:

## CSV Location

```
C:\Scripts\newUsers.csv
```

## Organizational Unit

```
OU=Trinidad Citrix Users,DC=firstcitizens,DC=local
```

## Log Location

```
C:\Scripts\NewUsers_Log.csv
```

If these locations change, update the configuration section at the beginning of the PowerShell script.

---

# Notes

- Always review the CSV file before running the script.
- Test with a single user before creating multiple accounts.
- Verify created users in Active Directory Users and Computers.
- Update user addresses manually after account creation.
- Keep the generated log file secure because it contains temporary passwords.
