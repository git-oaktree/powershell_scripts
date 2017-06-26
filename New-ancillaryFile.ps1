function  New-ancillaryFile {
  <# script is specific to a task that I need to do on a frequently. Sharing for the sake of sharing in hopes someone may find it useful
  Code cobbled together by looking at the following resources: 
  http://sqlmag.com/powershell/update-excel-spreadsheets-powershell
  https://blogs.technet.microsoft.com/heyscriptingguy/2010/09/09/copy-csv-columns-to-an-excel-spreadsheet-by-using-powershell/
  https://www.experts-exchange.com/questions/26674948/how-to-add-sheets-in-excel-though-powershell.html
  #>
  $path = 'C:\Users\user\Desktop\temp.xlsx'
  $row=1
  $data=Import-Csv 'C:\users\user\Desktop\temp.csv'
  $page='ssl10'
  $Excel=New-Object -Com Excel.Application
  $Workbook=$Excel.Workbooks.open($path)
  $worksheet=$Workbook.Worksheets.Add()
  $worksheet.name = $page
  $worksheet = $Excel.worksheets.item($page)
  $worksheet.Activate()
  foreach($line in $data) {
    $worksheet.Cells.Item($row,1) = $line.field1
    $worksheet.Cells.Item($row,2) = $line.field2
    $worksheet.Cells.Item($row,3) = $line.field3
    $row++
  }
  $Excel.DisplayAlerts = $False
  $workbook.save()
  $Workbook.close($true)
  $excel.quit()
  Remove-Variable Excel
  [gc]::collect()
  [gc]::WaitForPendingFinalizers()
}
