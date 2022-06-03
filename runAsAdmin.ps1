# Get Admin Account
$adminAccount = Read-Host "Enter Admin Account"

# Get current directory for later
$cwd = Get-Location

# Change to powershell directory and launch new powershell admin window
cd C:\windows\System32\WindowsPowerShell\v1.0\
Start-Process -Credential $adminAccount -FilePath powershell -ArgumentList "Start-Process powershell -verb RunAs"

# Change back to original location
cd $cwd
