# Validate Parameters
[CmdletBinding()]
Param(
  [switch] $help,
  $username
)

# Run check against the Domain
function accountCheck(){
    # Display account information
    $border = "=" * 30
    Write-Host "`n$border`nAccount Information: $user`n$border"
    get-aduser $user -properties * | select name, samaccountname, Lockedout, Enabled, PasswordLastSet, PasswordNeverExpires, PasswordExpired | fl

    # Run various status checks against the account
    if ((Get-ADUser $user -Properties LockedOut | Select-Object LockedOut) -match "True"){
        $lockout = get-aduser $user -properties AccountLockoutTime | select-object AccountLockoutTime
        Write-Host "[!] The account is locked" -ForegroundColor Red
        Write-Host "[!] It was locked on $lockout" -ForegroundColor Red
    }
    else{
        Write-Host "[+] The account is not locked"
    }

    if ((Get-ADUser $user -Properties Enabled | Select-Object Enabled) -match "False" ){
        Write-Host "[!] The account is disabled" -ForegroundColor Red
    }
    else{
        Write-Host "[+] The account is enabled"
    }

    if ((Get-ADUser $user -Properties PasswordExpired | Select-Object PasswordExpired) -match "True" ){
        Write-Host "[!] The password is expired" -ForegroundColor Red
    }
    else{
        Write-Host "[+] The password is not expired"
    }
}


# Validate the samaccountname then run query
function validateUser(){
    foreach ($user in $username){
        $aduser = Get-ADUser -filter "samAccountName -eq '$user'"
        if ($aduser -ne $null){
            accountCheck($user)
        }
        else{
            $border = "`n" + "=" * 30 + "`n"
            Write-Host "$border[!] Username $user does not exist in Active Directory$border" -ForegroundColor Red
        }
    }
}


# Validate RSAT tools are installed
function validateRSAT(){
    if(get-module -list activedirectory){
        Import-Module ActiveDirectory
        validateUser($username)
    }
    else{
        Write-Host "[!] RSAT tools not installed" -ForegroundColor Red
        exit(1)
    }
}


# Display help menu
function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    write-host "[+] This program will display useful AD attributes for an account as well as check for common issues"
    write-host "[+] Basic Usage: .\$scriptName USERNAME"
    write-host "[+] Query Multiple Accounts: .\$scriptName USERNAME1,USERNAME2,USERNAME3"
}


# Run program
if ($help){
    help
}
elseif ($username -eq $null){
    help
}
else{    
    validateRSAT
}
