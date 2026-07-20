$project_dir = $PSScriptRoot
$exe_name = "game"
$godot_dir = Join-Path $project_dir "godot"
$license_dir = Join-Path $project_dir "docs\license"
$release_dir = Join-Path $project_dir "game"

$windows_x64_release_dir = Join-Path $release_dir "windows_x64"
$linux_release_dir = Join-Path $release_dir "linux_x64"
$web_release_dir = Join-Path $release_dir "web"

# Clean the game folder
Get-ChildItem -Path $release_dir -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Confirm:$false -Force

# build windows x64
New-Item -Type dir $windows_x64_release_dir > $null
$godot_output = Join-Path $windows_x64_release_dir "$($exe_name).exe"
godot --headless --path $godot_dir --export-release "Windows Desktop" $godot_output
# Stop the script if the previous line returns a non-zero exit code.
if(!$?) { Exit $LASTEXITCODE } 
Copy-Item -Path $license_dir -Destination $(Join-Path $windows_x64_release_dir "license") -Recurse

# zip windows x64
$zip_output = Join-Path $release_dir "windows_x64.zip"
$zip_files = Join-Path $windows_x64_release_dir "*"
7z a $zip_output $zip_files

# build linux
New-Item -Type dir $linux_release_dir > $null
$godot_output = Join-Path $linux_release_dir "$($exe_name).x86_64"
godot --headless --path $godot_dir --export-release "Linux" $godot_output
if(!$?) { Exit $LASTEXITCODE }
Copy-Item -Path $license_dir -Destination $(Join-Path $linux_release_dir "license") -Recurse

# zip linux
$zip_output = Join-Path $release_dir "linux_x64.zip"
$zip_files = Join-Path $linux_release_dir "*"
7z a $zip_output $zip_files

# build web
New-Item -Type dir $web_release_dir > $null
$godot_output = Join-Path $web_release_dir "index.html"
godot --headless --path $godot_dir --export-release "Web" $godot_output
if(!$?) { Exit $LASTEXITCODE }

# zip web
$zip_output = Join-Path $release_dir "web.zip"
$zip_files = Join-Path $web_release_dir "*"
7z a $zip_output $zip_files
