function Invoke-PingSweep {
param ( 
    [string]$fileWithIP
    )


$iplist = New-Object System.collections.arraylist 

Get-Content $fileWithIP | ForEach-Object { $iplist.add($_) | Out-Null }


foreach($ip in $iplist) {
    if(Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip) {
        write-output "host $ip is up"
        }
      else {
       write-output "host $ip is down"
       }
   }
}

