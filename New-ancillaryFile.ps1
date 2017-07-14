function  New-ancillaryCSVFile {
  <# script is specific to a task that I need to do on a frequently. Sharing for the sake of sharing in hopes someone may find it useful
  Code cobbled together by looking at the following resources: 
  http://sqlmag.com/powershell/update-excel-spreadsheets-powershell
  https://blogs.technet.microsoft.com/heyscriptingguy/2010/09/09/copy-csv-columns-to-an-excel-spreadsheet-by-using-powershell/
  https://www.experts-exchange.com/questions/26674948/how-to-add-sheets-in-excel-though-powershell.html
  #>
  param (
  [Parameter(mandatory=$True,Position=1)]
  [string]$instructionFile,
  [string]$FindingsFile,
  [string]$DestinationPath=($pwd.path)

  )

  #Need to check if file exists. 
    $Instructions=Import-Csv $instructionFile
    $importedCSVFile=Import-Csv $FindingsFile 
    $rowNum=0
    [system.collections.arraylist]$SearchID=@()
    $columnHeaders=$instructions[0].psobject.properties | Select-Object -ExpandProperty name | ? { $_ -like "ID*" }
    [system.collections.arraylist]$tabNames=@()
    [system.collections.arraylist]$createdCSVFiles=@()

    foreach($line in $Instructions) {
        [system.collections.arraylist]$SearchID=@()
        [system.collections.arraylist]$whereObject=@()

        $OutFile = $line.OutFile
        write-verbose $outfile
            if ($rownum=0) {
                $rownum++
                }
            else {
                foreach ($column in $columnHeaders) {
                    if (!$line.$column) {
                        continue
                        }
                    else {
                        $ColumnValue=$line.$column
                        $SearchID.Add($columnValue) | Out-Null
                        }
                }            
            }
        
    foreach ($id in $SearchID) {
        $whereObject.add("`$_.'Plugin ID'` -eq $id") | Out-Null
        
        }
    $whereObjectFilter=[scriptblock]::Create($whereObject -join ' -OR ')
    
    write-verbose "about to parse csv file"
    $destinationFullPath= $DestinationPath + '\' + $OutFile + '.csv'
    Write-Verbose $destinationFullPath
    $importedCSVFile | ? $whereObjectFilter | export-csv $destinationFullPath  # <----- Create the CSV file 
    $tabNames.Add($OutFile) | Out-Null
    $createdCSVFiles.Add($destinationFullPath) | Out-Null
    #Get path of CSV file so can provide full path to new-excelFile function
    
    }    
    New-ExcelFile -inputCsvFileList $createdCSVFiles -tabNameList $tabNames

}
                         
function New-excelFile {
    param (
        [string[]]$inputCsvFileList,
        [string[]]$tabNameList,
        [string[]]$columnHeaders
    )
    
    Begin {
        $path ='C:\Users\user\Desktop\customer.xlsx'
        $row=1
        #$data=Import-Csv 'C:\users\user\Desktop\temp.csv' <--- No longer used
        #$page='ssl10'  <---- No longer used
        $Excel=New-Object -Com Excel.Application
        $Workbook=$Excel.Workbooks.open($path)

        }
       
       Process {
            [int]$counterForParameters=0
            $max=$inputCsvFileList.count
            
            write-output $max
            while ($counterForParameters -lt $max) {
                $tabname=$($tabnameList[$counterForParameters])
                $inputCsvName=$($inputCsvFileList[$counterForParameters])
                Write-output $inputCsvName
                $importedCsvFile=Import-Csv $inputCsvName
                $worksheet=$Workbook.Worksheets.Add()
                $worksheet.name = $tabname
                $worksheet = $Excel.worksheets.item($tabname)
                $worksheet.Activate()
                foreach($line in $importedCsvFile) {
                   $worksheet.Cells.Item($row,1) = $line.CVE
                   $worksheet.Cells.Item($row,2) = $line.CVSS
                   $worksheet.Cells.Item($row,3) = $line.Host
                   $row++
               }
            $counterForParameters++
            write-output "incrementing counter for parameters variable"
            $row=1
            }
        }
    End {
            $Excel.DisplayAlerts = $False
            $workbook.save()
            $Workbook.close($true)
            $excel.quit()
            Remove-Variable Excel
            [gc]::collect()
            [gc]::WaitForPendingFinalizers()
        }
}
