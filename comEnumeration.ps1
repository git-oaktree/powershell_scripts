cd C:
$Dlls= [System.Collections.ArrayList]::new()
$inproc = '\InprocServer32'
$test = gci HKLM:\SOFTWARE\Classes\CLSID | select -expandproperty name | % { $_ -replace 'HKEY_LOCAL_MACHINE\\', 'HKLM:\' ; }

$paths = $test | % { [string]::Concat($_,$inproc) }

$paths | foreach { 
    #write-output $_.name 
    #write-output $_
     if (test-path $_) {
        
       $dll=get-itemproperty -path $_ | select -expandproperty '(default)'
        #write-host $dll
        #write-output $dll
        if ($dll -match 'C:') {
        write-host $dll
            if (-not(test-path $dll)) { 
                "{0} {1}" -f $_, $dll
                }
        }
    }
    
}
