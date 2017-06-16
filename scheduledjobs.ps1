function Get-TaskTrigger {
    [cmdletbinding()]
    param (
        $Task
    )
    $Triggers = ([xml]$Task.xml).task.Triggers
    if ($Triggers) {
        $Triggers | Get-Member -MemberType Property | ForEach-Object {
            $Triggers.($_.Name)
        }
    }
}

function Get-scheduledjobz {
    [cmdletbinding()]
    param (
        [string]
        $Filter,
        [string]
        $UserName,
        [switch]
        $Enabled,
        [string]
        $TaskName,
        [string]
        $Trigger,
        [string]
        $Path,
        [string]
        $Name
    )

    begin {
        $finalFilter=@()
        if ($UserName) { 
            $userNameString= '$_.userID -eq "$username"'
            $finalFilter+=($userNameString)
        }
        if ($Enabled) {         
            $finalFilter+='$_.Enabled -eq $True'
        }
        if ($TaskName) {
            $TaskNameString = '$_.Name -eq "$TaskName"'
            $finalFilter+=$TaskNameString
        }


#Parse through array to create filter for parsing below.             
        if ($finalFilter.length -gt 1) {
            $finalFilter = "{ $($finalFilter -join ' -AND ') }"
            Write-Verbose -message "$finalFilter"
        }
        elseif ( $finalFilter.length -eq 1) {
            $finalFilter = $finalFilter[0].ToString()
            $finalFilter = $finalFilter -replace "\(",""
            $finalFilter = $finalFilter -replace "\)",""
            $scriptBlock = [Scriptblock]::Create($finalFilter)
            Write-Verbose -Message "ending mutation $finalFilter"
        }
        else { Remove-Variable finalFilter }
        

    }

process {
    $TaskScheduler = New-Object -ComObject "Schedule.Service"
    $TaskScheduler.Connect($Null)
    $RootFolder = $TaskScheduler.GetFolder('\')
    $tasks = $rootFolder.GetTasks(1)
    $testarray=@()
    $tasksxml=@()
    $ArrayForWriteScheduledjobz=@()
    $Tasks | Foreach-Object {
        $currentTask = New-Object -TypeName PSCustomObject -Property @{
	        'Name' = $_.name
            'Path' = $_.path
            'State' = switch ($_.State) {
                0 {'Unknown'}
                1 {'Disabled'}
                2 {'Queued'}
                3 {'Ready'}
                4 {'Running'}
                Default {'Unknown'}
            }

            'Enabled' = $_.enabled
            'LastRunTime' = $_.lastruntime
            'LastTaskResult' = $_.lasttaskresult
            'NumberOfMissedRuns' = $_.numberofmissedruns
            'NextRunTime' = $_.nextruntime
            'Author' =  ([xml]$_.xml).Task.RegistrationInfo.Author
            'UserId' = ([xml]$_.xml).Task.Principals.Principal.UserID
            'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
            'Trigger' = Get-tasktrigger -Task $_
            'ComputerName' = $Schedule.TargetServer
            }   
    
        

        
        if ($finalFilter) {
            $ruleMatch=$currentTask | Where-Object $scriptblock 
            if ($rulematch) {
                #([xml]$_.xml).Task
                #$rulematch
                Remove-Variable ruleMatch
               $ArrayForWriteScheduledjobz=([xml]$_.xml).Task 
            }
        }
        else {$currentTask}
        }   

   return ,$ArrayForWriteScheduledjobz
  

    

    }
}


function write-scheduledjobz {
    param (
        [string]
        $Filter,
        [string]
        $UserName,
        [switch]
        $Enabled,
        [string]
        $TaskName,
        [string]
        $Trigger,
        [string]
        $Name
    )

$GetTaskResults=Get-ScheduledJobz -enabled
$GetTaskResults

}

