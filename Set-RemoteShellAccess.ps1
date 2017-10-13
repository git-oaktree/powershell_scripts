function Set-RemoteShellAccess {
    <#
    Code is was copied from: https://github.com/ssOleg/Useful_code/blob/master/Set-RemoteShellAccess.ps1
    All credit for this script and research go to ssOleg. I just wanted a local copy. 
        .SYNOPSIS
            Sets the DACL for Powershell and WinRM remote shell access
 
        .DESCRIPTION
            By default, BUILTIN\Administrators have remote shell access.
            This function appends or over-writes the DACL on the local computer to modify permissions.
             
        .PARAMETER SID
            A SID string representing the user or group to grant access
         
        .PARAMETER APPEND
            A switch controlling whether to append to or overwrite the existing DACL
             
        .PARAMETER RESET
            A stand-alone switch used to control a reset to the default DACL
 
        .EXAMPLE
            PS C:\> Set-RemoteShellAccess -Append -SID "S-1-5-21-824518204-1975331169-839522115-6179" | fl *
 
                Confirm
                Are you sure you want to perform this action?
                Performing operation "Append to existing DACL to grant DOMAIN\GROUP access" on Target "Powershell Remoting".
                [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
 
                Confirm
                Are you sure you want to perform this action?
                Performing operation "Append to existing DACL to grant DOMAIN\GROUP access" on Target "WinRM Remote Shell".
                [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
 
                WinRMUpdate     : Success
                PSUpdate        : Success
                WinRMPermission : O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;S-1-5-21-824518204-1975331169-839522115-6179)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
                PSPermission    : O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;S-1-5-21-824518204-1975331169-839522115-6179)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
                 
                This example adds a new group to the existing DACL for both Powershell and WinRS.
         
        .EXAMPLE    
            PS C:\> Set-RemoteShellAccess -Append:$False -SID "S-1-5-21-824518204-1975331169-839522115-6179" | fl *
             
            This example over-writes the existing DACL for both Powershell and WinRS, granting a new group as the only permission.
             
        .EXAMPLE
            PS C:\> Set-RemoteShellAccess -Reset
             
            This example over-writes the existing DACL for both Powershell and WinRS, to reset the DACL to the Windows 7 default.
            Default correct for Win7 RTM and SP1 at time of writing.
        .NOTES
            Version 1.0
            Date 2011-08-04
             
    #>
    [CmdletBinding(
        SupportsShouldProcess=$True,
        SupportsTransactions=$False,
        ConfirmImpact="High",
        DefaultParameterSetName="UPDATE")]
         
    param(
    [Parameter(Position=0,Mandatory=$true,ParameterSetName="UPDATE")]
    [string]$SID
    ,
    [Parameter(Position=1,Mandatory=$false,ParameterSetName="UPDATE")]
    [switch]$Append=$True
    ,
    [Parameter(Position=0,Mandatory=$true,ParameterSetName="RESET")]
    [switch]$Reset
    )
     
    BEGIN{
     
        # Even Get-PSSessionConfiguration requires administrative rights
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
         
        # Powershell and WinRM default SDDL
        New-Variable -Option Constant -Name DefaultSDDL -Value "O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)" -Force -Verbose:$false -Confirm:$false
         
        # Path to WinRM RootSDDL settting
        New-Variable -Option Constant -Name WinRMRootSDDL -Value "WSMan:\localhost\Service\RootSDDL" -Force -Verbose:$false -Confirm:$false
     
        # Used for visual confirmation when running interactively
        Function Get-PricipalFromSid([string]$SID)
        {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
            $objPrincipal = $objSID.Translate( [System.Security.Principal.NTAccount])
            return $objPrincipal.Value
        }
    }
    PROCESS{
     
        if(-not $IsAdmin){
            Throw "ERROR: Please re-run this script as an Administrator."
             
        }
     
        switch($PSCmdlet.ParameterSetName) {
             "UPDATE" {
                Write-Verbose "Processing update"
                # check SID is valid
                $Principal = Get-PricipalFromSid -SID $SID
                If(-not $Principal){
                    # Fatal Error
                    Write-Error "`nERROR: Failed to resolve SID ($SID) to a name on this computer `n`n"
                    Return        
                }
                Write-Verbose "--$SID resolved to $Principal"
                 
                switch($Append) {
                    $true {
                        Write-Verbose "--Append mode"
                         
                        # Build an SD based on existing DACL
                        $existingSDDL = (Get-PSSessionConfiguration -Name "Microsoft.PowerShell" -Verbose:$false).SecurityDescriptorSDDL
                        $isContainer = $false
                        $isDS = $false
                        $SecurityDescriptor = New-Object -TypeName Security.AccessControl.CommonSecurityDescriptor -ArgumentList $isContainer,$isDS, $existingSDDL
                          
                        # Add the new SID
                        $accessType = "Allow"
                        $accessMask = 268435456
                        $inheritanceFlags = "none"
                        $propagationFlags = "none"
                        $SecurityDescriptor.DiscretionaryAcl.AddAccess($accessType,$SID,$accessMask,$inheritanceFlags,$propagationFlags) | Out-Null
                          
                        # Combined SDDL
                        $newSDDL = $SecurityDescriptor.GetSddlForm("All")
                        $Message = "Append to existing DACL to grant $Principal access"
                         
                    }
                     
                    $false {
                        Write-Verbose "--Overwrite mode"
                        $newSDDL = "O:NSG:BAD:P(A;;GA;;;$SID)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)"
                        $Message = "Overwrite existing DACL to grant $Principal access"
                    }                
                }#switch
                 
            }#update
             
            "RESET" {
                Write-Verbose "Processing reset"
                $newSDDL = $DefaultSDDL
                $Message = "Reset to default DACL"
             
            }#reset
        }#switch
  
         Write-Verbose "--`NewSDDL = $NewSDDL"
  
         # Powershell update
         If ($psCmdlet.shouldProcess("Powershell Remoting" ,$Message)){
            Get-PSSessionConfiguration -Verbose:$false | 
            ForEach-Object {
                $Name  = $_.Name
                 try{
                    # Turn off confirm as already wrapped in confirm block 
                    Set-PSSessionConfiguration -name $Name -SecurityDescriptorSddl $newSDDL -force -Confirm:$false -Verbose:$false | Out-Null
                    $PoshResult = "Success"
                }catch{
                    Write-Error "`nERROR: failed to update DACL on $Name `n`n$($_)"
                    $PoshResult = "Failed"
                }
            }#foreach
        }else{
            $PoshResult = "Cancelled"
        }#endif
         
        # WimRM update
        If ($psCmdlet.shouldProcess("WinRM Remote Shell" ,$Message)){
                  
                try{
                    Set-Item -Path $WinRMRootSDDL -Value $newSDDL -Confirm:$false -Verbose:$false -Force | Out-Null
                    $WinRMResult = "Success"
                }catch{
                    Write-Error "`nERROR: failed to update $WinRMRootSDDL `n`n$($_)"
                    $WinRMResult = "Failed"
                }
        }else{
            $WinRMResult = "Cancelled"
        }#endif
         
        # Get updated SDDL string
        $PSSDDL= (Get-PSSessionConfiguration -Name "Microsoft.PowerShell" -Verbose:$false).SecurityDescriptorSDDL
        $WinRMSDDL = Get-Item -Path $WinRMRootSDDL | %{"$($_.Value)"}
         
        # Output results to pipeline
        New-Object -TypeName PSObject -Property @{
            PSUpdate = $PoshResult
            WinRMUpdate = $WinRMResult
            PSPermission = $PSSDDL
            WinRMPermission = $WinRMSDDL
        }
 
    }#PROCESS            
             
}

function get_sid($username) {
$objUser = New-Object System.Security.Principal.NTAccount($username)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
}

function set_permision(){
    $user = Read-Host "Please enter username"
    $sid = get_sid $user
    Write-Host $sid
    Set-RemoteShellAccess -Append -SID $($sid) | fl *
}
