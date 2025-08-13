
## 🛠️ Code Compilation Helper
Compiles large and small codebases into one text file labelled with file path names to give wide codebase context to LLMs (chatgpt etc)

## 1. Create the Script File
First, you need to create the script that will perform the compilation.

a. Create a bin directory in your home folder if you don't already have one (gets around locked down mac permissions):

mkdir -p ~/bin

b. Create the script file:

touch ~/bin/compile-selection

c. Make the script executable:

chmod +x ~/bin/compile-selection

d. Open the file (nano ~/bin/compile-selection) and paste the compile-selection.sh script (attatched in this repo) into it

e. Save the file and exit the editor.

## 2. Create a macOS Quick Action
Use the built-in Automator app to create a right-click menu item.

a. Open the Automator app.
b. Select New Document, then choose Quick Action.
c. At the top of the workflow panel, set "Workflow receives current" to files or folders in any application.
d. Search for the "Run Shell Script" action and drag it into the workflow panel.
e. In the "Run Shell Script" action, set "Pass input:" to as arguments.
f. Replace the content of the script box with this single line:

/bin/bash ~/bin/compile-selection "$@"

g. Go to File > Save and name it Compile to Txt File.

## 3. (Optional) Assign a Keyboard Shortcut
For faster access, you can assign a global keyboard shortcut.

a. Open System Settings > Keyboard > Keyboard Shortcuts....
b. Select "Services" from the sidebar.
c. Find "Compile to Txt File" under the "Files and Folders" section.
d. Click "Add Shortcut" and assign a unique key combination (e.g., Cmd + Option + Shift + C).

## 4. How to Use
You can now select any file(s) or folder(s) (i.e. your codebase) in Finder, IntelliJ, or VS Code. Then, either:

Right-click and choose Quick Actions > Compile to Txt File.

Use the keyboard shortcut you assigned.

A system notification will appear, and the compiled .txt file will be saved in your Documents/compiled-code folder ready to hand off to an LLM