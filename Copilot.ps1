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

# Function to log error messages to a file
function Log-Error {
    param(
        [string]$ErrorMessage,
        [string]$LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] ERROR: $ErrorMessage"
    Write-Host "ERROR: $ErrorMessage" -ForegroundColor Red
}

function Confirm-Operation {
    param(
        [string]$Message
    )
    $choice = Read-Host -Prompt "$Message (Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        return $true
    } else {
        return $false
    }
}

# Check if the log file already exists, and delete it if it does
if (Test-Path $logFilePath) {
    Remove-Item $logFilePath -Force
    Write-Host "Previous LOG file found and deleted: $logFilePath" -ForegroundColor Yellow
}

Log-Message "Starting Copilot unlocking script..." -LogFilePath $logFilePath

# Set the execution policy
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    Write-Host "Remote Signed Policy Changed." -ForegroundColor Blue
    Log-Message "REMOTE SIGNED AND EXECUTION POLICY CHANGED." -LogFilePath $logFilePath
} catch {
    $errorMessage = $_.Exception.Message
    Log-Error -ErrorMessage $errorMessage -LogFilePath $logFilePath
}

Start-Sleep -Seconds 1.5

# Get Windows version
$windowsVersion = [System.Environment]::OSVersion.Version
Log-Message "OS version: $windowsVersion" -LogFilePath $logFilePath

# Ask user for confirmation before making registry changes
if (Confirm-Operation "Do you want to enable Copilot features? (if u clicked this you should press Y right?)") {
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
        Log-Message "PATH: $regPathBingChat" -LogFilePath $logFilePath
    }

    Start-Sleep -Seconds 1.5

    # Check if IsCopilotAvailable is already set to 1, otherwise set it to 1
    if ((Get-ItemProperty -Path $regPathCopilot -Name "IsCopilotAvailable").IsCopilotAvailable -ne 1) {
        Set-ItemProperty -Path $regPathCopilot -Name "IsCopilotAvailable" -Value 1
        Write-Host "IsCopilotAvailable value changed to 1." -ForegroundColor Green
        Log-Message "IsCopilotAvailable value changed to 1." -LogFilePath $logFilePath
    } else {
        Write-Host "IsCopilotAvailable is ALREADY set to 1, moving on to the next operation." -ForegroundColor Green
        Log-Message "IsCopilotAvailable is DONE." -LogFilePath $logFilePath
        Log-Message "PATH: $regPathCopilot" -LogFilePath $logFilePath
    }

    Start-Sleep -Seconds 1.5

    # Check if ShowCopilotButton is already set to 1, otherwise set it to 1
    if ((Get-ItemProperty -Path $regPathExplorer -Name "ShowCopilotButton").ShowCopilotButton -ne 1) {
        Set-ItemProperty -Path $regPathExplorer -Name "ShowCopilotButton" -Value 1
        Write-Host "ShowCopilotButton value changed to 1." -ForegroundColor Green
        Log-Message "ShowCopilotButton value changed to 1." -LogFilePath $logFilePath
    } else {
        Write-Host "ShowCopilotButton is ALREADY set to 1, Copilot should be enabled now." -ForegroundColor Green
        Log-Message "ShowCopilotButton is DONE." -LogFilePath $logFilePath
        Log-Message "PATH: $regPathExplorer" -LogFilePath $logFilePath
    }

    Start-Sleep -Seconds 1.5

    Write-Host "CONFIGURATION COMPLETED!, Enjoy." -ForegroundColor Green
    Log-Message "COPILOT SHOULD BE ENABLED!" -LogFilePath $logFilePath
} else {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    Log-Message "Operation cancelled by user. (you have trust issues?)" -LogFilePath $logFilePath
}

