# Winget Advanced App Manager

A lightweight, automated Windows Batch & PowerShell hybrid script that manages software updates via Windows Package Manager (winget). It allows you to build custom update lists interactively, manage saved profiles, and run completely hands-off silent updates via command-line arguments.

Created by: Zak Millikin [Google Gemini Pro]

## 🚀 Quick Start
1. Place winget_manager.bat in a folder of your choice.
2. Double-click winget_manager.bat to launch the interactive menu.
3. Choose Option 5 to generate your first update profile.

---

## 🛠️ Main Menu Options

* 1. Run 'default' List  
  Instantly updates every application saved inside your default profile without asking for further inputs.
* 2. Run Custom List(s)  
  Displays all your saved list profiles. You can run a single list or chain multiple lists together by typing their numbers separated by commas (e.g., 1,3).
* 3. Edit / Delete Saved Lists  
  Allows you to view the application IDs saved inside a profile or delete old lists you no longer need.
* 4. Display All Installed Apps  
  Runs a raw live diagnostic scan of your computer's installed software using winget list.
* 5. Create New Update List (Pick via number/CSV)  
  Scans your PC and lists your apps with numbers next to them. Type the numbers you want to save using commas (e.g., 1,11,12,65), then give your list a name.
* 6. Exit  
  Safely closes the manager interface.

---

## 🤖 Automated Silent Execution (Headless Mode)

The script accepts an incoming tracking argument (1) to run updates silently in the background without prompting for inputs. This is perfect for Windows Task Scheduler or automated startup scripts.

### How to use it:
Open Command Prompt or a separate script and run:
winget_manager.bat 1

### Automation Rules:
* Requirement: You must have a saved list profile named default (saved as update_lists\list_default.txt).
* Behavior: If the 1 flag is present and a default list exists, it runs all updates entirely hands-off.
* Safety Catch: If no default list is configured, the script exits immediately to prevent errors or hangs.

---

## 📂 File Structure
The script dynamically creates and manages its own storage directory to keep your workplace clean:

Your-Folder/
├── winget_manager.bat   <- The main execution script
└── update_lists/        <- Auto-generated profiles directory
    ├── list_default.txt <- Automated updates profile
    └── list_workapps.txt<- Example custom profile

---

## ⚠️ Notes & Requirements
* Windows 10/11 with winget installed (built-in by default on modern Windows environments).
* Administrator Privileges: While the script runs fine as a standard user for most applications, some software updates (like Visual Studio) will trigger a standard Windows User Account Control (UAC) prompt to authorize structural installations. For completely silent background automation, run the script as an Administrator.
