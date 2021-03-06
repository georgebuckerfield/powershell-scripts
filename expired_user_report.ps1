import-module ActiveDirectory

# Searches a defined AD path for accounts that meet the following criteria:
# - The account expiration date has passed
# - The account is still enabled
# These are then saved to CSV and emailed to a defined account.


# These variables must be set before running the script!
$smtp = "smtp_server"
$to = ""
$from = ""
$ADPath = "OU=, DC=, DC="


$now = (get-date)

$filedate = (get-date -f yyyy_MM_dd)
$path = "C:\Powershell\"
$filename = "ExpiredAccounts_" + $filedate + ".csv"
$exportpath = $path + $filename

get-aduser -searchbase $ADPath -filter {accountexpirationdate -lt $now -AND enabled -eq $true} -properties displayname, samaccountname, emailaddress, accountexpirationdate | `
select-object AccountExpirationDate, DisplayName, SamAccountName, EmailAddress | `
export-csv $exportpath -NoTypeInformation

$subject = "Active Directory Expired Accounts Report"

$body = "The weekly expired users report is attached."

$pass = ConvertTo-SecureString "whatever" -asplaintext -force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $pass

send-mailmessage -smtpserver $smtp -to $to -from $from -subject $subject -Attachments $exportpath -Body $body -Credential $creds