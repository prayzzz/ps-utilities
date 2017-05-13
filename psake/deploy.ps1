properties {
    Import-Module psake-contrib/teamcity.psm1
    $ProgressPreference = "SilentlyContinue"

    # Parameter
    $artifact = Get-Value-Or-Default $artifact $null
    Assert ($artifact -ne $null) '$artifact should not be null'

    # Config    
    $configFile = Get-Value-Or-Default $configFile "./ops/deploy.json"
    
    if (Test-path $configFile) {
        $config = (Get-Content $configFile) | ConvertFrom-Json  
        
        $appName = $config.appName
        $appProcess = $config.appProcess
        $deployParentDirectoryPath = $config.deployParentDirectoryPath 
        $startupFile = $config.startupFile      
    }
    else {
        $appName = Get-Value-Or-Default $appName $null
        $appProcess = Get-Value-Or-Default $appProcess $null
        $deployParentDirectoryPath = Get-Value-Or-Default $deployParentDirectoryPath $null
        $startupFile = Get-Value-Or-Default $startupFile $null
    }

    Assert ($appName -ne $null) '$appName should not be null'
    Assert ($appProcess -ne $null) '$appProcess should not be null'
    Assert ($deployParentDirectoryPath -ne $null) '$deployParentDirectoryPath should not be null'
    Assert ($startupFile -ne $null) '$startupFile should not be null'

    # Directories           
    $appDirectoryPath = Join-Path $deployParentDirectoryPath $appName
    $deployDirectory = $appName + "_new"
    $deployDirectoryPath = Join-Path $deployParentDirectoryPath $deployDirectory

    $startupFilePath = Join-Path $appDirectoryPath $startupFile
    $pidFile = $appName + ".pid"
    $pidFilePath = Join-Path $appDirectoryPath $pidFile

    $isWindows = $Env:os -eq "Windows_NT"
}

FormatTaskName {
    ""
    ""
    Write-Host "Executing task: $taskName" -foregroundcolor Cyan
    Write-Host "Working Directory: $(Get-Location)" -foregroundcolor Cyan
    ""
}

# Alias

task Deploy -depends Unzip-App, Stop, Update-App, Start {
}

# Task

task Unzip-App {
    # Create or clean deploy directory    
    if (!(Test-path $deployDirectoryPath)) {
        Write-Host "Creating directory: $deployDirectoryPath"
 
        if ($isWindows) {
            exec { New-Item $deployDirectoryPath -type directory }
        }
        else {
            exec { New-Item $deployDirectoryPath -type directory }
            # exec {  mkdir -m 774 $deployDirectoryPath }            
        }
    }
    else {
        $removePath = Join-Path $deployDirectoryPath "*"
        Write-Host "Clearing path: $removePath"
        Remove-Item $removePath -Recurse         
    }

    # Unzip artifact
    Write-Host "Unzip artifact: $artifact"    
    $ProgressPreference = "SilentlyContinue"
    Expand-Archive $artifact $deployDirectoryPath | Out-Null
}

task Stop {
    Write-Host "Checking for pidfile: $pidFilePath"

    # check for pid file
    if(!(Test-path $pidFilePath)) {
        Write-Host "Pidfile not found"
        return
    }

    # get process id
    $appId = Get-Content $pidFilePath

    # check for process
    Write-Host "Stopping process: $appId"
    Get-Process -Id $appId -ErrorAction SilentlyContinue | Stop-Process -PassThru | Out-Null

    # remove pid file
    Write-Host "Removing pidfile: $pidFilePath"
    Remove-Item $pidFilePath
}

task Update-App -depends Stop {
    if (Test-path $appDirectoryPath) {
        Write-Host "Removing old deployment: $appDirectoryPath"
        Remove-Item $appDirectoryPath -Recurse
    }

    Write-Host "Renaming folder: $deployDirectoryPath to $appDirectoryPath"
    Move-Item $deployDirectoryPath $appDirectoryPath
}

task Start {
    $cwd = Get-Location
    Set-Location $appDirectoryPath
    Write-Host "Changed directory: $(Get-Location)" 

    # start app
    Write-Host "Starting Process: $appProcess $startupFile"
    $app = Start-Process $appProcess $startupFile -passthru
    Write-Host "Started Process: $($app.Id)"

    # write pid file
    $app.Id | Out-File $pidFile
            
    Set-Location $cwd
}

# task Patch-AppSettings -depends Unzip-App {
#     $appSettings = Join-Path $deployPath "appsettings.Production.json"

#     Write-Host "Patching appsettings: $appSettings"

#     $settings = Get-Content $appSettings
#     $settings = $settings -replace "##dbuser##", $dbuser -replace "##dbpassword##", $dbpassword
#     $settings | Out-File $appSettings
# }


# task Update-Database -depends Patch-AppSettings, Stop {
#     Write-Host "Type:     $dbtype"
#     Write-Host "Server:   $dbhost"
#     Write-Host "Database: $dbname"
#     Write-Host "User:     $dbuser"
#     Write-Host ""

#     $cwd = Get-Location
#     Set-Location $mainProjectDir
#     Write-Host "Changed directory: $(Get-Location)"
        
#     # exec { dotnet restore }
   
#     # create backup
#     exec { dotnet dbupdate backup --type $dbtype --host $dbhost --database $dbname --user $dbuser --password $dbpassword --scripts $sqlScriptDir --backup $sqlBackupDir }
    
#     # executing scripts
#     exec { dotnet dbupdate execute --type $dbtype --host $dbhost --database $dbname --user $dbuser --password $dbpassword --scripts $sqlScriptDir }

#     Set-Location $cwd
# }


function Get-Value-Or-Default($value, $default) {
    if (!$value -or $value -eq "") {
        return $default
    }

    return $value;
}