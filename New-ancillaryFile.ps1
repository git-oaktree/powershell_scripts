#Requires -Version 3.0

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
  [string]$ExcelFindingsFile,
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
    $excelDestinationFullpath=$DestinationPath + '\' + $ExcelFindingsFile + '.xlsx'
    Write-Verbose $destinationFullPath
    $importedCSVFile | ? $whereObjectFilter | export-csv $destinationFullPath  # <----- Create the CSV file 
    Write-output "File $destinationFullPath Created"
    $tabNames.Add($OutFile) | Out-Null
    $createdCSVFiles.Add($destinationFullPath) | Out-Null
    #Get path of CSV file so can provide full path to new-excelFile function
    
    }    
    New-ExcelFile -inputCsvFileList $createdCSVFiles -tabNameList $tabNames -excelFile $excelDestinationFullpath

}
                         
function New-excelFile {
    param (
        [string[]]$inputCsvFileList,
        [string[]]$tabNameList,
        [string]$excelFile
        
    )
    
    Begin {
        Write-output "Starting process to create Excel file"
        $row=1
        $columNum=1
        #$data=Import-Csv 'C:\users\user\Desktop\temp.csv' <--- No longer used
        #$page='ssl10'  <---- No longer used
        $Excel=New-Object -Com Excel.Application
        $workbook=$excel.workbooks.add()
        ######$Workbook=$Excel.Workbooks.open($path)

        }
       
       Process {
            [int]$counterForParameters=0
            $max=$inputCsvFileList.count
            while ($counterForParameters -lt $max) {
                $tabname=$($tabnameList[$counterForParameters])
                $inputCsvName=$($inputCsvFileList[$counterForParameters])
                
                $importedCsvFile=Import-Csv $inputCsvName
                $columnHeaders=$importedCsvFile[0].psobject.Properties | Select-Object -ExpandProperty Name
                $worksheet=$Workbook.Worksheets.Add()
                $worksheet.name = $tabname
                $worksheet = $Excel.worksheets.item($tabname)
                $worksheet.Activate()
                foreach($line in $importedCsvFile) {
                    foreach ($column in $columnHeaders) {
                        $worksheet.Cells.Item($row,$columNum) = $line.$column
                        $columNum++
                        }
                    $columNum=1
                    $row++
               }
            write-output "Tab $tabname has been added to the Excel file $excelFile"
            $counterForParameters++
            $row=1
            }
        }
    End {
            $Excel.DisplayAlerts = $False
            ######$workbook.save()
            $workbook.saveas($excelFile)
            $Workbook.close($true)
            $excel.quit()
            Remove-Variable Excel
            [gc]::collect()
            [gc]::WaitForPendingFinalizers()
            write-output "Process Completed"
        }
}
