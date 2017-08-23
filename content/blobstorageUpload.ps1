Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$data=@()

$datasetup=Get-Content ($PSScriptRoot+"\datasetup.txt")
forEach($line in $datasetup) {
    $datatosave=($line -split " ")[1]
    $data+=$datatosave
}

$uid=$data[0]
$key=$data[1]
$cont=$data[2]

$file=Get-FileName("C:\")
$name=Read-Host "Enter the name of the blobfile"

$cred=New-AzureStorageContext -StorageAccountName $uid -StorageAccountKey $key

$blobcontent=Get-AzureStorageBlob -Context $cred -Container $cont | select -expandproperty Name

if ($blobcontent.contains($name)) {
    $action=read-host ("The container "+$cont+" already contains a blobfile named "+$name+". Do you want to overwrite the file, rename the new file, or stop the program? [O]: Overwrite, [R]: Rename, [S]: Stop")
    while ($action -ne "O" -and $action -ne "R" -and $action -ne "S") {
        $action=read-host ("Please enter a valid action to perform. [O]: Overwrite, [R]: Rename, [S]: Stop")
    }
    switch ($action) {
        "O" { Set-AzureStorageBlobContent -Container $cont -File $file -Blob $name -Context $cred
              Write-Output "Upload complete. The program will now exit."
        }
        "R" { $newname=read-host "Enter the name of the blobfile"
              while ($newname -eq $name) {
                $newname=read-host "Please enter a different name for the blobfile"
              }
              Set-AzureStorageBlobContent -Container $cont -File $file -Blob $newname -Context $cred
              Write-Output "Upload complete. The program will now exit."
        }
        "S" { Write-Output "Upload terminated. The program will now exit." }
    }
} else {
    Set-AzureStorageBlobContent -Container $cont -File $file -Blob $name -Context $cred
    Write-Output "Upload complete. The program will now exit."
}