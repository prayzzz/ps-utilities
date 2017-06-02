function Remove-Registry-Entry ($path) {
    if (Test-Path $path) {
        Write-Host "Removing: $path"
        Remove-Item $path -Recurse
    }
    else {
        Write-Host "Not found: $path"
    }
}

Write-Host "####"
Write-Host "### Remove Context Entries Script"
Write-Host "####"
Write-Host

$drives = Get-PSDrive -PSProvider Registry
$hkcrfound = False
foreach ($drive in $drives) {
    if ($drive.Name -eq "HKCR") {
        $hkcrfound = True
    }
}

if (!$hkcrfound) {
    Write-Host "HKCR not found. Adding..."
    Write-Host ""

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}

Remove-Registry-Entry "HKCR:\Directory\background\shell\git_shell"
Remove-Registry-Entry "HKCR:\Directory\background\shell\git_gui"
Remove-Registry-Entry "HKCR:\Directory\shell\git_shell"
Remove-Registry-Entry "HKCR:\Directory\shell\git_gui"

Write-Host