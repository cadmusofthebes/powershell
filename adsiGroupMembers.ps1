[CmdletBinding()]
Param(
  [switch] $help,
  $groupName
)

function adsiSearch{
    $filter = "(cn=$groupName)"
    $searcher = [adsisearcher]$filter
    $LDAPPath = $searcher.FindAll().Path
    
    If ($LDAPPath -eq $null){
        Write-Host "[!] Invalid group name"
    }

    Else{
        $domainUser = [ADSI]"$LDAPPath"
        $domainUser.member -replace "(CN=)(.*?),.*", '$2'
    }
}

function help(){
    $scriptName = split-path $MyInvocation.PSCommandPath -Leaf
    write-host "[+] This program will display all members of a group"
    write-host "[+] Usage: .\$scriptName GROUPNAME"
}

if ($help){
    help
}

elseif ($groupName -eq $null){
    help
}

else{    
    adsiSearch
}
