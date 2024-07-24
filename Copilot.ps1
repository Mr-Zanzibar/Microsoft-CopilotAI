$logFilePath = Join-Path -Path $env:TEMP -ChildPath "CopilotConfigLog.txt"

# Function to log messages to a file
function Write-Log {
    param(
        [string]$Message,
        [string]$LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
}

# Function to log error messages to a file
function Write-ErrorLog {
    param(
        [string]$ErrorMessage,
        [string]$LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] ERROR: $ErrorMessage"
    Write-Host "ERROR: $ErrorMessage" -ForegroundColor Red
}

# Function to confirm operation
function Confirm-Action {
    param(
        [string]$Message
    )
    $choice = Read-Host -Prompt "$Message (Y/N)"
    return ($choice -eq "Y" -or $choice -eq "y")
}

# Function to set registry value if not already set
function Set-RegistryValueIfNeeded {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$LogFilePath
    )
    try {
        $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
        if ($currentValue -ne $Value) {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value
            Write-Host "$Name value changed to $Value." -ForegroundColor Green
            Write-Log "$Name value changed to $Value." -LogFilePath $LogFilePath
        } else {
            Write-Host "$Name is already set to $Value, moving on to the next operation." -ForegroundColor Green
            Write-Log "$Name is already set to $Value." -LogFilePath $LogFilePath
            Write-Log "PATH: $Path" -LogFilePath $LogFilePath
        }
    } catch {
        Write-ErrorLog -ErrorMessage $_.Exception.Message -LogFilePath $LogFilePath
    }
}

# Main script execution
if (Test-Path $logFilePath) {
    Remove-Item $logFilePath -Force
    Write-Host "Previous LOG file found and deleted: $logFilePath" -ForegroundColor Yellow
}

Write-Log "Starting Copilot unlocking script..." -LogFilePath $logFilePath

# Set the execution policy
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    Write-Host "Remote Signed Policy Changed." -ForegroundColor Blue
    Write-Log "Remote signed and execution policy changed." -LogFilePath $logFilePath
} catch {
    Write-ErrorLog -ErrorMessage $_.Exception.Message -LogFilePath $logFilePath
}

Start-Sleep -Seconds 1.5

# Get Windows version
$windowsVersion = [System.Environment]::OSVersion.Version
Write-Log "OS version: $windowsVersion" -LogFilePath $logFilePath

if (Confirm-Action "Do you want to enable Copilot features? (if you clicked this you should press Y right?)") {
    Start-Sleep -Seconds 1.5

    # Registry keys
    $regPathBingChat = "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat"
    $regPathCopilot = "HKCU:\Software\Microsoft\Windows\Shell\Copilot"
    $regPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    # Set registry values
    Set-RegistryValueIfNeeded -Path $regPathBingChat -Name "IsUserEligible" -Value 1 -LogFilePath $logFilePath
    Start-Sleep -Seconds 1.5
    Set-RegistryValueIfNeeded -Path $regPathCopilot -Name "IsCopilotAvailable" -Value 1 -LogFilePath $logFilePath
    Start-Sleep -Seconds 1.5
    Set-RegistryValueIfNeeded -Path $regPathExplorer -Name "ShowCopilotButton" -Value 1 -LogFilePath $logFilePath

    Start-Sleep -Seconds 1.5

    Write-Host "Configuration completed! Enjoy." -ForegroundColor Green
    Write-Host "Look in settings." -ForegroundColor Green
    Write-Log "Copilot should be enabled!" -LogFilePath $logFilePath
} else {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    Write-Log "Operation cancelled by user." -LogFilePath $logFilePath
}
