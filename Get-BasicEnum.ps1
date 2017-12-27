function Get-BasicEnum{ 
    $error.clear()
    $noPerms = New-Object System.Collections.Generic.List[System.Object]
    gci c:\users 
    gci c:\users | ForEach-Object {
        gci $_.FullName -ErrorAction SilentlyContinue | Out-Null
        if ($error) {
          $noPerms.add("$($_.fullname)")
          $error.clear()
       }
     else {
         $desktop="$($_.FullName)\Desktop"
            $documents="$($_.FullName)\Documents"
         #gci $_.FullName -ErrorAction SilentlyContinue
            gci $documents -Force
         gci $($_.fullname).Destktop -Force
        }
    }

    $noPerms | foreach-object { write-output "Permission denied for paths $_"}

    gci 'c:\'

    gci 'C:\Program Files' 

    gci 'C:\Program Files (x86)'

    get-process | select ProcessName, Path 
    
    Get-WmiObject win32_service | select Name, DisplayName, @{Name="Path"; Expression={$_.PathName.split('"')[1]}} | Format-List

    Get-wmiobject win32_service | where { $_.Caption -notmatch "Windows" -and $_.PathName -notmatch "Windows" -and $_.PathName -notmatch "policyhost.exe" -and $_.Name -ne "LSM" -and $_.PathName -notmatch "OSE.EXE" -and $_.PathName -notmatch "OSPPSVC.EXE" -and $_.PathName -notmatch "Microsoft Security Client" }
}
