function Create-SupportFile { 
    $createFile = @'
    $domain = "contoso.local"
    $password = "password" | ConvertTo-SecureString -asPlainText -Force
    $username = "$domain\da_contoso1" 
    $credential = New-Object System.Management.Automation.PSCredential($username,$password)
    Add-Computer -DomainName $domain -Credential $credential
    echo "hello"| Out-File C:\Users\oaktree\Desktop\test.txt 
    remove-item  $env:USERPROFILE\Desktop\joinToDomain.ps1 
    Unregister-ScheduledJob AddComputerToDomain
    Restart-Computer AddComputerToDomain 
'@

$createFile | out-file "$env:USERPROFILE\Desktop\joinToDomain.ps1"
}

function Convert-JoinDomain {
    <#

    .Description
        Script to change the computer name of a host and add to a domain

    .PARAMETER NewComputername
        The new computername for the host. 

    .EXAMPLE
    Convert-JoinDomain -NewComputerName WKSTN-2810

    #>
    
    Param (
    [Parameter(Position = 0, Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [String]
    $NewComputerName
    )
    $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
    $AtStartup = New-JobTrigger -Atstartup
    Create-SupportFile
    Register-ScheduledJob -Trigger $AtStartup $env:USERPROFILE\Desktop\joinToDomain.ps1 -name AddComputerToDomain -ScheduledJobOption $options
    Rename-Computer -newname $NewComputerName
    Restart-Computer -Force
        
}
