# Load and parse the VM deployment configuration from the JSON file into a PowerShell object
$config = Get-Content "D:\repositories\powershell\dc_adds_setup\dc_deploy.json" | ConvertFrom-Json

# Check if VM already exists
if (-not (Get-VM -Name $config.VMName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating VM: $($config.VMName)"

    New-VM -Name $config.VMName `
           -MemoryStartupBytes $config.MemoryStartupBytes `
           -Generation $config.Generation `
           -SwitchName $config.SwitchName `
           -Path $config.VMPath
} else {
    Write-Host "VM '$($config.VMName)' already exists. Skipping creation."
}

# Configure processor and memory
Set-VMProcessor -VMName $config.VMName -Count $config.ProcessorCount

Set-VMMemory -VMName $config.VMName `
             -DynamicMemoryEnabled $config.DynamicMemoryEnabled `
             -StartupBytes $config.MemoryStartupBytes

# Set automatic checkpoint behavior
Set-VM -Name $config.VMName -AutomaticCheckpointsEnabled $config.AutomaticCheckpointsEnabled

# Create and attach differencing disk if defined
if ($config.DifferencingDisk) {
    $disk = $config.DifferencingDisk

    # Ensure parent exists
    if (-not (Test-Path $disk.ParentPath)) {
        throw "Parent VHD not found: $($disk.ParentPath)"
    }

    # Create differencing disk only if it doesn't exist
    if (-not (Test-Path $disk.Path)) {
        New-VHD -Path $disk.Path -ParentPath $disk.ParentPath -Differencing
        Write-Host "Created differencing disk: $($disk.Path)"
    } else {
        Write-Host "Differencing disk already exists: $($disk.Path)"
    }

    # Attach to SCSI controller
    Add-VMHardDiskDrive -VMName $config.VMName `
                        -ControllerType $disk.ControllerType `
                        -ControllerNumber $disk.ControllerNumber `
                        -ControllerLocation $disk.ControllerLocation `
                        -Path $disk.Path
}

# Start the VM
Start-VM -Name $config.VMName
Write-Host "VM '$($config.VMName)' started successfully."
