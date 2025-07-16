# Gather args
$process_name = $args[0]
$newest_zip_path = $args[1]

# Expand
Expand-Archive -Path $newest_zip_path -DestinationPath "tmp" -Force

# Wait for software to close
Start-Sleep -Seconds 5

# Change work directory to tmp/NavithorClient
$path_to_use = "tmp"
if (((Get-ChildItem -Path $path_to_use).Name -is [array]) -eq $false) {
    $path_to_use = (Get-ChildItem -Path $path_to_use).FullName
    Write-Host "Found single directory inside zip, search path changed to ${path_to_use}"
}

# Move contents of extracted directory to current directory
$pattern_matched_files = (Get-ChildItem -Path $path_to_use).FullName
foreach ($file_path in $pattern_matched_files) {
    Write-Host "Found entry: " + $file_path
    if (Test-Path -Path $file_path -PathType Leaf) {
        $file = (New-Object System.IO.FileInfo $file_path)
        $destination_file_path = [System.IO.Path]::Combine($pwd.Path, $file.Name)
        Write-Host "Moving file:" $file "to:" $destination_file_path
        [System.IO.File]::Copy($file_path, $destination_file_path, $true)
    }
    else {
        $dir = (New-Object System.IO.DirectoryInfo $file_path)
        Copy-Item $dir.FullName -Destination $pwd.Path -Force -Recurse
    }
}

[System.IO.Directory]::Delete("tmp", $true)

# Restart application
Start-Process $process_name
