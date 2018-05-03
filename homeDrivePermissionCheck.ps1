$ErrorActionPreference='Stop'
function Check-Command($cmdname)
{
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

$destinationFile = 'survey.txt'
remote-item $destinationFile -force 
$padding='############################################'
$fileName='PermissionsTest.txt'
$entries = @()
gci | select -first 5 | % { 
  $username = 'username placeholder'
  $object = New-Object PSObject -property @{
    username = $userName
    HomeDirectory = $_.Name
  }
  $entries += $object
}

$entries | Foreach-Object {
  [string]$homeDirectory=$_.HomeDirectory
  [string]$name=$_.username
  
  write-output "Testing Path $homeDirectory" | out-file -Append $destinationFIle 
  Get-Acl $homeDirectory | select -ExpandProperty Access | ? { $_.IdentityReference -eq "Place username here" } | Out-FIle -Append $destinationFile
  Try {
    new-item -path $HomeDirectory -Name $filename -type "file" -value "this is a test file" -force
    Invoke-Item $homeDirectory
    Start-Sleep 5
    $shell = new-object -ComObject shell.application
    $window = $shell.Windows() | ? $_.Name -eq 'Windows Explorer'
    $window.quit()
    
    Write-Output "Write file $filename to $homeDirectory" | out-file -append $destinationFile
    write-output "$padding" | out-file -append $destinationFile
  }
  catch {
    write-output "Unable to write to directory $homeDirectory" | out-file -append $destinationFile
    write-output "$padding" | out-file -append $destinationFile
  }
}
