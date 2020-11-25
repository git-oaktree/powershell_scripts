$baddate = [DateTime] "12/31/1600 7:00:00 PM"
$30dayDate= (Get-date).addDays(-30)
$180dayDate= (Get-date).addDays(-30)
$oneYearDate= (Get-date).AddYears(-1)

$older30days = $users  | ? { ($_.pwdlastSet -lt $30dayDate) -and ($_.pwdlastset -ne $baddate) } | measure-object
$older180days= $users  | ? { ($_.pwdlastSet -lt $180dayDate) -and ($_.pwdlastset -ne $baddate) } | measure-object
$older1year= $users  | ? { ($_.pwdlastSet -lt $oneyearDate) -and ($_.pwdlastset -ne $baddate) } | measure-object



"{0} accounts have passwords last set at least 30 days ago" -f ($older30days.count)
"{0} accounts have passwords last set at least 180 days ago" -f ($older180days.count)
"{0} accounts have passwords last set at least one year ago" -f ($older1year.count) 
