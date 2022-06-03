[CmdletBinding()]
Param(
  [switch] $help,
  $samAccountName
)

function adsiSearch{
    $filter = "(samAccountName=$samAccountName)"
    $searcher = [adsisearcher]$filter
    $LDAPPath = $searcher.FindAll().Path

    If ($LDAPPath -eq $null){
        Write-Host "[!] Invalid username"
    }
    Else{
        $domainUser = [ADSI]"$LDAPPath"
        $domainUser.properties | ft
    }
}

function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    write-host "[+] This program will display all AD attributes for an account"
    write-host "[+] Usage: .\$scriptName USERNAME"
}

if ($help){
    help
}
elseif ($samAccountName -eq $null){
    help
}
else{    
    adsiSearch
}
