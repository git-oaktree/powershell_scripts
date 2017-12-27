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
}
