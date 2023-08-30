# Fallout 4 Crowd Control MOD
This repository holds the source code of the F4CC mod.

For information about this MOD and how to use it see: [f4cc.kmrkle.tv](https://f4cc.kmrkle.tv)

## Prerequisites
To compile this MOD, you will need the following prerequisites installed:

- Microsoft Windows.
  - PowerShell 3.0+ is required for the build scripts. PowerShell 3.0 comes pre-installed with Windows 8 and Windows Server 2012 and newer.
- [Visual Studio 2022](https://visualstudio.microsoft.com/vs/) (any edition).
    - Installation workload: *Desktop Development with C++*
- [.NET Framework 3.5 runtime](https://dotnet.microsoft.com/en-us/download/dotnet-framework) (for the Papyrus compiler)
- Steam version of Fallout 4 (1.10.163).
- Steam version of Fallout 4: Creation Kit (1.10.162.0).
- [7-Zip](https://www.7-zip.org/) (x64) binary for packaging the FOMOD.
- *(optional) [F4SE](https://f4se.silverlock.org/) (0.6.23) installed into Fallout 4 for running / debugging the MOD*.

## Configure
You will need to make the following edits to set up the build environment:

- Edit `\set-paths.cmd` to point the build system to the correct paths of:

   - Fallout 4
   - Visual Studio tools (normally under `\Common7\Tools`)
   - 7-Zip (7z.exe)

   \
   *If you've used the default paths to install everything and are using Visual Studio 2022 Community, then the paths will already be set up and no edits are necessary.*

<!-- 2. *(optional)* Edit your `Fallout4Custom.ini` file which is located in your `\Documents\My Games\Fallout4` folder to include the following:
   ```
   [Archive]
   bInvalidateOlderFiles=1
   sResourceDataDirsFinal=
   ```
   This will allow you to debug the Papyrus scripts by simply editing them and then running `\Papyrus\build.cmd`. -->

## Building
- Make sure to start Fallout 4 at least once, otherwise Creation Kit will not open.

- Make sure to start the Fallout 4 Creation Kit at least once and unpack the base scripts when prompted.

- Run `\deploy_release.cmd` to compile everything and create a .7z deployment of the MOD.

- A new .7z FOMOD compatible file will be placed in `\F4CC-Installer\deploy\Release`.

After building the MOD for the first time, all of the necessary files will be placed into the proper Fallout 4 paths, setting the game up for running and debugging the MOD.

## License

### Source Code

The source code of this project is © 2023 kmrkle.tv community licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Binary Distribution

The binary distribution of this project (which is available at [f4cc.kmrkle.tv](https://f4cc.kmrkle.tv)) is licensed under the [Creative Commons Attribution-NoDerivatives 4.0 International Public License](http://creativecommons.org/licenses/by-nd/4.0/).

## Credits

This software includes portions of code licensed under:

### MIT License

Copyright (c) 2021 Superxwolf

The full license can be found [here](/F4CC-Installer/ModArchive/InFomod/LICENSE_Superxwolf.txt).