# FRM Bypass BadUSB Script for Flipper Zero

## Overview

This comprehensive BadUSB script is designed to bypass Factory Reset Protection (FRM) on old Android tablets using a Flipper Zero device. The script includes multiple bypass methods and provides a user-friendly GUI for method selection.

## What is FRM?

Factory Reset Protection (FRM) is a security feature introduced by Google to prevent unauthorized access to Android devices after a factory reset. When enabled, it requires the previous owner's Google account credentials to set up the device after a reset.

## Features

- **Multiple Bypass Methods**: ADB, Recovery Mode, Fastboot, and System Properties
- **GUI Interface**: Easy-to-use graphical interface for method selection
- **Automatic ADB Installation**: Downloads and installs ADB if not present
- **Comprehensive Error Handling**: Detailed error messages and troubleshooting
- **Safety Checks**: Warnings and confirmations before executing dangerous operations
- **Cross-Platform Support**: Works on Windows systems with PowerShell

## Supported Devices

- **Android Versions**: 4.0+ (API level 14+)
- **Device Brands**: Samsung, LG, HTC, Motorola, and generic Android tablets
- **Connection**: USB OTG support required
- **Requirements**: USB debugging capability (preferred)

## Bypass Methods

### 1. ADB Method (Recommended)
- Removes FRM-related files from the device
- Resets device provisioning settings
- Clears Google services data
- Most reliable for compatible devices

### 2. Recovery Mode Method
- Boots device into recovery mode
- Allows manual FRM bypass
- Requires custom recovery for best results
- Good for devices with locked bootloaders

### 3. Fastboot Method
- Uses fastboot commands to unlock device
- Wipes data partition completely
- Requires unlocked bootloader
- Most thorough but may void warranty

### 4. System Properties Method
- Modifies system properties to bypass FRM checks
- Less invasive than other methods
- Good for devices with limited access
- May work on some locked devices

## Installation

1. **Download the Scripts**:
   - `main.ps1` - Main PowerShell script
   - `frm-bypass-badusb.txt` - Flipper Zero BadUSB script
   - `FRM-Bypass-BadUSB.txt` - Detailed documentation

2. **Prepare Flipper Zero**:
   - Copy `frm-bypass-badusb.txt` to your Flipper Zero
   - Ensure Flipper Zero is properly configured

3. **Prepare Target Device**:
   - Enable USB debugging (if possible)
   - Connect device via USB
   - Ensure device is recognized by computer

## Usage

### Method 1: Flipper Zero Execution
1. Connect Flipper Zero to target device
2. Execute the BadUSB script
3. Follow on-screen instructions
4. Select appropriate bypass method from GUI

### Method 2: Direct PowerShell Execution
1. Run PowerShell as Administrator
2. Execute: `irm https://raw.githubusercontent.com/beigeworm/BadUSB-Files-For-FlipperZero/main/FRM-Bypass-BadUSB/main.ps1 | iex`
3. Select bypass method from GUI
4. Follow instructions

### Method 3: Manual ADB Commands
```bash
adb devices
adb shell "rm -rf /data/system/locksettings.db*"
adb shell "rm -rf /data/system/gatekeeper*"
adb shell "settings put global device_provisioned 0"
adb shell "settings put secure user_setup_complete 0"
adb shell "pm clear com.google.android.gms"
adb reboot
```

## Troubleshooting

### Common Issues

**ADB Not Found**:
- Script will attempt to download ADB automatically
- Ensure internet connection is available
- Check Windows Defender/firewall settings

**Device Not Recognized**:
- Install proper USB drivers for your device
- Enable USB debugging on target device
- Try different USB cable or port

**Permission Denied**:
- Run script as Administrator
- Check device USB debugging settings
- Ensure device is properly unlocked

**FRM Still Active**:
- Try different bypass method
- Check device compatibility
- Verify Android version support
- Consider hardware-based methods

### Error Codes

- **Error 1**: ADB not found or not working
- **Error 2**: Device not connected or recognized
- **Error 3**: Permission denied for ADB commands
- **Error 4**: FRM bypass failed
- **Error 5**: Device not compatible with selected method

## Safety and Legal Considerations

### ⚠️ Important Warnings

- **Educational Purpose Only**: This script is for educational and research purposes
- **Ownership Required**: Only use on devices you own or have explicit permission to modify
- **Warranty Void**: Some methods may void device warranty
- **Data Loss**: Always backup important data before attempting bypass
- **Legal Compliance**: Ensure you have proper authorization before use

### Legal Disclaimer

This script is provided for educational and research purposes only. Users are responsible for ensuring they have proper authorization to modify any devices they use this script on. The authors are not responsible for any damage or legal issues that may arise from the use of this script.

## Technical Details

### File Structure
```
FRM-Bypass-BadUSB/
├── main.ps1                    # Main PowerShell script
├── frm-bypass-badusb.txt       # Flipper Zero BadUSB script
├── FRM-Bypass-BadUSB.txt       # Detailed documentation
└── README.md                   # This file
```

### Dependencies
- PowerShell 5.0+
- Windows 7+ (recommended Windows 10+)
- Internet connection (for ADB download)
- USB drivers for target device
- Administrator privileges (recommended)

### System Requirements
- **RAM**: 512MB minimum
- **Storage**: 100MB free space
- **Network**: Internet connection for ADB download
- **USB**: USB 2.0+ port
- **OS**: Windows 7+ (PowerShell 5.0+)

## Success Indicators

### Positive Results
- Device boots without FRM prompts
- No Google account verification required
- Device can be set up as new
- No factory reset protection warnings
- Full access to device settings

### Negative Results
- Device still shows FRM prompts
- Google account verification still required
- Device remains locked to previous owner
- Error messages during execution
- Device fails to boot properly

## Alternative Methods

If this script doesn't work, consider:

1. **Manual ADB Commands**: Use ADB directly with custom commands
2. **Custom Recovery**: Flash custom recovery and wipe data
3. **Firmware Flashing**: Flash custom firmware without FRM
4. **Hardware Methods**: Use specialized hardware tools
5. **Professional Services**: Use professional unlocking services

## Contributing

We welcome contributions to improve this script:

- **Bug Reports**: Report issues with specific device models
- **Feature Requests**: Suggest new bypass methods
- **Code Improvements**: Enhance error handling and compatibility
- **Documentation**: Improve instructions and troubleshooting

## Version History

### v1.0 (Current)
- Initial release with multiple bypass methods
- ADB-based FRM bypass
- Recovery mode bypass
- Fastboot bypass
- System properties bypass
- GUI interface for method selection
- Comprehensive error handling
- Safety checks and warnings

### Planned Features
- Support for newer Android versions
- Additional bypass methods
- Better device detection
- Automated method selection
- Enhanced error recovery
- More detailed logging

## Support

For support and questions:

1. **Check Documentation**: Review this README and script comments
2. **Test Compatibility**: Verify device compatibility before use
3. **Report Issues**: Include device model, Android version, and error details
4. **Community Help**: Seek help from Android development communities

## Final Notes

This script represents a comprehensive approach to FRM bypass on older Android tablets. While it includes multiple methods and safety checks, success is not guaranteed on all devices. Always ensure you have proper authorization before attempting to modify any device's security settings.

Remember: **Use responsibly and legally!**