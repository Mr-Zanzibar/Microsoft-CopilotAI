# Get the current script's path
$currentScriptPath = $PSScriptRoot
$logFilePath = Join-Path -Path $env:TEMP -ChildPath "CopilotConfigLog.txt"

# Function to log messages to a file
function Log-Message {
    param(
        [string]$Message,
        [string]$LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
}

# Check if the log file already exists, and delete it if it does
if (Test-Path $logFilePath) {
    Remove-Item $logFilePath -Force
    Write-Host "Previous LOG file found and deleted: $logFilePath" -ForegroundColor Yellow
}

Log-Message "Starting Copilot unlocking script..." -LogFilePath $logFilePath

# Set the execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "Remote Signed Policy Changed." -ForegroundColor Blue
Log-Message "REMOTE SIGNED CHANGED" -LogFilePath $logFilePath

# Get Windows version
$windowsVersion = [System.Environment]::OSVersion.Version
Log-Message "OS version: $windowsVersion" -LogFilePath $logFilePath

# Check if Windows version is at least 22H2 (build 22000)
if ($windowsVersion -ge [System.Version]::new("10.0.22000")) {
    Write-Host "OS: $windowsVersion" -ForegroundColor Blue

    # Check for SSD or HDD
    $diskType = ""
    if (Get-PhysicalDisk | Where-Object MediaType -eq "SSD") {
        $diskType = "SSD"
        if ($diskType -eq "SSD") {
            Write-Host "Detected SSD. Performing SSD operations..." -ForegroundColor Green
            Log-Message "SSD Detected." -LogFilePath $logFilePath
            Start-Sleep -Seconds 10
        }
    } elseif (Get-PhysicalDisk | Where-Object MediaType -eq "HDD") {
        $diskType = "HDD"
        if ($diskType -eq "HDD") {
            Write-Host "Detected HDD. Performing HDD operations..." -ForegroundColor Green
            Log-Message "HDD Detected." -LogFilePath $logFilePath
            Start-Sleep -Seconds 20
        }
    }

    Start-Sleep -Seconds 1.5

    # Registry keys
    $regPathBingChat = "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat"
    $regPathCopilot = "HKCU:\Software\Microsoft\Windows\Shell\Copilot"
    $regPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    # Check if IsUserEligible is already set to 1, otherwise set it to 1
    if ((Get-ItemProperty -Path $regPathBingChat -Name "IsUserEligible").IsUserEligible -ne 1) {
        Set-ItemProperty -Path $regPathBingChat -Name "IsUserEligible" -Value 1
        Write-Host "IsUserEligible value changed to 1." -ForegroundColor Green
        Log-Message "IsUserEligible value changed to 1." -LogFilePath $logFilePath
    } else {
        Write-Host "IsUserEligible is ALREADY set to 1, moving on to the next operation." -ForegroundColor Green
        Log-Message "IsUserEligible is DONE." -LogFilePath $logFilePath
        Log-Message "PATH: HKEY_CURRENT_USER:\Software\Microsoft\Windows\Shell\Copilot\BingChat" -LogFilePath $logFilePath
    }

    # Wait for 1.5 seconds
    Start-Sleep -Seconds 1.5

    # Check if IsCopilotAvailable is already set to 1, otherwise set it to 1
    if ((Get-ItemProperty -Path $regPathCopilot -Name "IsCopilotAvailable").IsCopilotAvailable -ne 1) {
        Set-ItemProperty -Path $regPathCopilot -Name "IsCopilotAvailable" -Value 1
        Write-Host "IsCopilotAvailable value changed to 1." -ForegroundColor Green
        Log-Message "IsCopilotAvailable value changed to 1." -LogFilePath $logFilePath
    } else {
        Write-Host "IsCopilotAvailable is ALREADY set to 1, moving on to the next operation." -ForegroundColor Green
        Log-Message "IsCopilotAvailable is DONE." -LogFilePath $logFilePath
        Log-Message "PATH: HKEY_CURRENT_USER:\Software\Microsoft\Windows\Shell\Copilot" -LogFilePath $logFilePath
    }

    # Wait for 1.5 seconds
    Start-Sleep -Seconds 1.5

    # Check if ShowCopilotButton is already set to 1, otherwise set it to 1
    if ((Get-ItemProperty -Path $regPathExplorer -Name "ShowCopilotButton").ShowCopilotButton -ne 1) {
        Set-ItemProperty -Path $regPathExplorer -Name "ShowCopilotButton" -Value 1
        Write-Host "ShowCopilotButton value changed to 1." -ForegroundColor Green
        Log-Message "ShowCopilotButton value changed to 1." -LogFilePath $logFilePath
    } else {
        Write-Host "ShowCopilotButton is ALREADY set to 1, Copilot should be enabled now." -ForegroundColor Green
        Log-Message "ShowCopilotButton is DONE." -LogFilePath $logFilePath
        Log-Message "PATH: HKEY_CURRENT_USER:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -LogFilePath $logFilePath
    }

    Start-Sleep -Seconds 1.5

    Write-Host "CONFIGURATION COMPLETED!, Enjoy." -ForegroundColor Green
    Log-Message "COPILOT SHOULD BE ENABLED!" -LogFilePath $logFilePath
} else {
    # Windows version is not compatible
    Write-Host "Windows version not compatible. Copilot is not available for your version of Windows." -ForegroundColor Red
    Write-Host "Your Windows version: $windowsVersion" -ForegroundColor Red
    Write-Host "Minimum required version: 10.0.22000 (22H2)" -ForegroundColor Red

    Log-Message "Your Windows version: $windowsVersion" -LogFilePath $logFilePath
    Log-Message "NOT USABLE, ABORTING..." -LogFilePath $logFilePath
}
