# Load and parse the VM deployment configuration from the JSON file into a PowerShell object
$config = Get-Content "D:\repositories\powershell\client_setup\client_deploy.json" | ConvertFrom-Json

# Create VM
New-VM -Name $config.VMName `
       -MemoryStartupBytes $config.MemoryStartupBytes `
       -Generation $config.Generation `
       -SwitchName $config.SwitchName `
       -Path $config.VMPath

# Configure processor and memory
Set-VMProcessor -VMName $config.VMName -Count $config.ProcessorCount

Set-VMMemory -VMName $config.VMName `
             -DynamicMemoryEnabled $config.DynamicMemoryEnabled `
             -StartupBytes $config.MemoryStartupBytes

# Set checkpoint behavior only (auto-start removed)
Set-VM -Name $config.VMName -AutomaticCheckpointsEnabled $config.AutomaticCheckpointsEnabled

# Ensure Secure Boot is enabled (required for TPM)
Set-VMFirmware -VMName $config.VMName -EnableSecureBoot On

# Enable TPM if requested
if ($config.Security.EnableTPM) {
    try {
        $guardianName = $config.Security.KeyProtectorOwner

        # Check for existing guardian or create a new one
        $guardian = Get-HgsGuardian -Name $guardianName -ErrorAction SilentlyContinue
        if (-not $guardian) {
            $guardian = New-HgsGuardian -Name $guardianName -GenerateCertificates
        }

        # Create a key protector using the Guardian
        $kp = New-HgsKeyProtector -Owner $guardian -AllowUntrustedRoot

        # Apply the key protector to the VM
        Set-VMKeyProtector -VMName $config.VMName -KeyProtector $kp.RawData

        # Enable TPM using pipeline
        Get-VM -Name $config.VMName | Enable-VMTPM

        Write-Host "TPM enabled for '$($config.VMName)' using guardian '$guardianName'."
    } catch {
        Write-Error "Failed to enable TPM: $_"
    }
}

# Create and attach differencing disk if specified
if ($config.DifferencingDisk) {
    $disk = $config.DifferencingDisk

    # Ensure parent VHD exists
    if (-not (Test-Path $disk.ParentPath)) {
        throw "Parent VHD not found: $($disk.ParentPath)"
    }

    # Create differencing disk only if it doesn't already exist
    if (-not (Test-Path $disk.Path)) {
        New-VHD -Path $disk.Path -ParentPath $disk.ParentPath -Differencing
        Write-Host "Differencing disk created at '$($disk.Path)'."
    } else {
        Write-Host "Differencing disk already exists at '$($disk.Path)'. Skipping creation."
    }

    # Attach to SCSI controller
    Add-VMHardDiskDrive -VMName $config.VMName `
                        -ControllerType $disk.ControllerType `
                        -ControllerNumber $disk.ControllerNumber `
                        -ControllerLocation $disk.ControllerLocation `
                        -Path $disk.Path
}

Write-Host "VM '$($config.VMName)' deployed successfully with TPM and differencing disk (if configured)."

# Start the VM
Start-VM -Name $config.VMName
Write-Host "VM '$($config.VMName)' has been started."