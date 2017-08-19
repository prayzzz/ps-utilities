function Remove-Registry-Entry ($path) {
    if (Test-Path $path) {
        Write-Host "Removing: $path"
        Remove-Item $path -Recurse
    }
    else {
        Write-Host "Not found: $path"
    }
}

function Remove-Registry-Entry-By-Name ($basePath, $name) {
    $entries = Get-ChildItem -Path $basePath -Recurse | Where-Object -FilterScript {$_.Name -like "*$name"}

    if ($entries.Length -gt 1) {
        Write-Host "Found multiple entries:"
        foreach ($entry in $entries) {
            Write-Host $entry
        }
    }
    elseif ($entries.Length -eq 0) {
        Write-Host "Not found: *$name"        
    }
    else {
        Remove-Registry-Entry "Registry::$($entries[0].Name)"
    }
}

Write-Host "####"
Write-Host "### Removes unwanted context menu entries"
Write-Host "### Execute this script as Administrator"
Write-Host "####"
Write-Host

Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\background\shell\git_shell"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\background\shell\git_gui"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\Background\OpenWithMobaXterm"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode"

Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_shell"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\git_gui"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\OpenWithMobaXterm"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\PlayWithVLC"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\AddToPlaylistVLC"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Directory\shell\AnyCode"

Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Drive\shell\OpenWithMobaXterm"
Remove-Registry-Entry "Registry::HKEY_CLASSES_ROOT\Applications\vlc.exe\shell\Open"

Remove-Registry-Entry-By-Name "Registry::HKEY_CLASSES_ROOT\CLSID\" "shell\Open CCleaner..."
Remove-Registry-Entry-By-Name "Registry::HKEY_CLASSES_ROOT\CLSID\" "shell\Run CCleaner"

Write-Host