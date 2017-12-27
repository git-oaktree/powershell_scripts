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

    write-output "##############################################################################"
    $noPerms | foreach-object { write-output "Permission denied for paths $_"}
       
    write-output "##############################################################################"
    write-output 'Directory listing of C:\'
	gci 'c:\'
    
    write-output "##############################################################################"
	write-output 'Directory listing of C:\'
	gci 'C:\Program Files' 
    
    write-output "##############################################################################"
	write-output 'Directory listing of C:\Program Files (x86)'
	gci 'C:\Program Files (x86)'
    
    write-output "##############################################################################"
    write-output 'Process List'
	get-process | select ProcessName, Path 
    
    write-output "##############################################################################"
	write-output 'Services'
	Get-WmiObject win32_service | select Name, DisplayName, @{Name="Path"; Expression={$_.PathName.split('"')[1]}} | Format-List

	write-output "##############################################################################"
	write-output 'Non-Standard Services'
    Get-wmiobject win32_service | where { $_.Caption -notmatch "Windows" -and $_.PathName -notmatch "Windows" -and $_.PathName -notmatch "policyhost.exe" -and $_.Name -ne "LSM" -and $_.PathName -notmatch "OSE.EXE" -and $_.PathName -notmatch "OSPPSVC.EXE" -and $_.PathName -notmatch "Microsoft Security Client" }

	write-output "##############################################################################"
	write-output 'GPO Results'
    gpresult.exe /Z

	write-output "##############################################################################"
	write-output 'netstat output'
    netstat -anp tcp 
}
