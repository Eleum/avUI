# Export avUI folder contents, excluding .git and .gitignore
$sourceFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentDir = Split-Path -Parent $sourceFolder
$destFolder = Join-Path $parentDir "avUI"

# Create destination folder if it doesn't exist
if (!(Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder | Out-Null
    Write-Host "Created destination folder: $destFolder"
}

# Copy folder structure and files, excluding .git and .gitignore
Get-ChildItem -Path $sourceFolder -Recurse -Force | ForEach-Object {
    $relativePath = $_.FullName.Substring($sourceFolder.Length + 1)
    
    # Skip .git folder and .gitignore files
    if ($relativePath -like ".git*" -or $_.Name -eq ".gitignore" -or $_.Name -eq "export.ps1") {
        return
    }
    
    $destPath = Join-Path $destFolder $relativePath
    
    if ($_.PSIsContainer) {
        # Create directory
        if (!(Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath | Out-Null
        }
    } else {
        # Copy file
        Copy-Item -Path $_.FullName -Destination $destPath -Force
    }
}

Write-Host "Export completed successfully!"
Write-Host "Contents exported to: $destFolder"
