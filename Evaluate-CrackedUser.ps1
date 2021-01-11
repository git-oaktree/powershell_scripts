function Evaluate-CrackedUser {
<#

    .Synopsis
    
    Compares a user provided list of accounts that we have cracked the passwords for against the list of disabled users in the domain

#>

    param(
    [parameter(Mandatory=$true)]
    [string]$filePath
    )

    try
    {
    test-path $filePath -ErrorAction Stop
    }
    catch
    {
    Write-Output "File $filePath does not exist"
    break
    }
    
    [string[]]$cracked_accounts = Get-Content -Path $filePath
    $disabled_users= Get-DomainUser -UACFilter AccountDisable

    $cracked_accounts | foreach { if (($disabled_users).samaccountname -contains $_ ) 
        {write-host "Username $_ is disabled and cracked"  -ForegroundColor Yellow } 
        elseif ($cracked_Accounts -notcontains $_ ) 
            {write-host "username $_ is disabled"} 
        else 
        {Write-host "Username $_ is cracked and enabled" -ForegroundColor RED -BackgroundColor WHITE}}
}
