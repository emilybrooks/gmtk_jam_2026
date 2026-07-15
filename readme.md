# GMTK Jam 2026

## Building (Windows)
1. Install [Godot 4.7-stable Standard](https://godotengine.org/download/archive/4.7-stable/) and add it to the path. You can do this manually, or [install Godot with Scoop](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html#path
), which will automatically add it to the path.

2. With the project open, go to `Editor > Manage Export Templates...`

3. Select `Windows x86_64`, `Linux x86_64`, and `Web Single-Threaded`

4. Click "Install Selected Templates"

5. Run build.ps1 in PowerShell

The exported binaries will be placed in `<project root>\game\`
