# Financial Advisor
-I created this app in Visual Studio, using C++ and SFML. I constructed a fully working GUI with different buttons, text input boxes, and more. Upon running the program, it takes the user to a user authentication screen, where they are prompted to input login credentials or sign up for the app. If the wrong credentials are entered, or the user tries to access the app without an account, their access will be denied. Upon entering correct credentials, the user will be transported to the home screen, where they are prompted by four different buttons. "Add transaction" takes the user to a screen where they can input different dollar amounts to deposit or withdraw from their running balance in the app. Every new account is initialized with the balance of $0. "View Transaction History" takes the user to a screen where all of their prior transactions (deposits & withdrawals) can be viewed. It comes with the type of transaction, the amount, the date, and the balance left afterwards. "Budget Calculator" takes the user to a screen where they are prompted to enter a budget amount, where they can then also enter how much of the budget has been spent, and a remaining dollar amount is displayed for what is left in the budget. The final button on the home screen is used to clear the running balance in the app, as well as the transaction history.

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

## Necessary Fonts
- Note that in order to run this app you must have a folder named "Fonts" within your folder containing your .vcxproj files. I specifically used "MagnisaSans-Regular.ttf" for this project, as well as "QuickMoney.ttf".

## Setting up the Precompiled Header
- In the solution explorer in Visual Studio, right click on the "pch.cpp" file, and select properties.
- Navigate to "C/C++" and then to "Precompiled Headers". In "Precompiled Header" select "Create (/Yc)", and in "Precompiled Header File" type "pch.h".
- Hit "Apply", then press "Ok".
- Now go into the project properties, select "C/C++", then "Precompiled Headers", then select "Use (/Yu)" from "Precompiled Header".
- Next type "pch.h" in the "Precompiled Header File" slot, then press "Apply" and "Ok".
- Now the app can be run!
