# Display direct reports
# https://thesysadminchannel.com/get-direct-reports-in-active-directory-using-powershell-recursive/
function directReports($manager){
    $UserAccount = Get-ADUser $manager -Properties DirectReports, DisplayName
    $UserAccount | select -ExpandProperty DirectReports | ForEach-Object {
        $User = Get-ADUser $_ -Properties DirectReports, DisplayName, Title, EmployeeNumber
        directReports($User.SamAccountName)
            [PSCustomObject]@{
                SamAccountName     = $User.SamAccountName
                DisplayName        = $User.DisplayName
                Manager            = $UserAccount.DisplayName
                Title              = $User.Title
            }
    } | Sort-Object DisplayName
}


# Check for AD Module availability
function checkADModule{
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
    } 
    else {
        Write-Host "[!] Active directory module not installed" -ForegroundColor Red
        Write-Host "[!] Exiting" -ForegroundColor Red
        Exit(1)
    }
}


# Validate provided active directory ID
function testAD($manager){
    Try{
        get-aduser $manager | Out-Null
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host "[!] $manager is not a valid ID" -ForegroundColor Red
        Exit(1)
    }
}


# Check for proper usage of script
Try{
    $manager=$args[0]
    checkADModule
    testAD($manager)
    directReports($manager)

}
Catch{
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Host "[!] Missing parameter for manager's username" -ForegroundColor Red
    Write-Host "[*] Usage: ./$scriptName <manager username>"
}
