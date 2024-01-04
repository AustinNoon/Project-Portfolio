# Space Attack

## Linking SFML
- Firstly, download the most recent SFML zip from the SFML website.
- Create a folder, named anything, and paste in the "include" and "lib" folders into the folder you created, then place it in your solution directory for your visual studio project.
- In the "bin" folder from the SFML zip, copy and paste the DLL files into the folder in your solution directory that shares the same name as your project. It should be the folder with your .vcxproj files.
- This game was completely created and run in Microsoft Visual Studio by myself, so now open visual studio.
- Head into the "project properties" tab, and select "All Configurations" from the configurations drop down menu, as well as "Win32" from the platforms drop down menu.
- Navigate to "C/C++" and then "General", where it says "Additional Include Directories" type "$(SolutionDir)\'your sfml folder name'\include".
- Next navigate to "Linker" then "General", and where it says "Additional Library Directories" type "$(SolutionDir)\'your sfml folder name'\lib".
- Still in "Linker", go to "Input" and switch the configuration type in the top left to "Release". In the "Additional Dependencies" slot type: "sfml-window.lib, sfml-graphics.lib, sfml-audio.lib, sfml-system.lib, sfml-network.lib".
- Switch the configuration type to "Debug" and repeat the current step, adding "-d" to each lib file, like this: "sfml-window-d.lib, sfml-graphics-d.lib, sfml-audio-d.lib, sfml-system-d.lib, sfml-network-d.lib".
- Hit the "Apply" button, then press the "Ok" button.

## Setting up the Precompiled Header
- In the solution explorer in Visual Studio, right click on the "pch.cpp" file, and select properties.
- Navigate to "C/C++" and then to "Precompiled Headers". In "Precompiled Header" select "Create (/Yc)", and in "Precompiled Header File" type "pch.h".
- Hit "Apply", then press "Ok".
- Now go into the project properties, select "C/C++", then "Precompiled Headers", then select "Use (/Yu)" from "Precompiled Header".
- Next type "pch.h" in the "Precompiled Header File" slot, then press "Apply" and "Ok".
- Now the game can be run!

## Future Plans & Additions
- Incorporate explosive animations upon enemy/player death.
- Incorporate SFX for both enemy and player.
- Incorporate enemy bullets.
- Incorporate level design/boss fights with different backgrounds (scrolling instead of static).
- Incorporate enemies of different size, health, and point values.
- Incorporate a menu system. (Pause, Exit, Save, ect).
