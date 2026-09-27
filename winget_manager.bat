@echo off
setlocal enabledelayedexpansion

:: Create lists directory if it doesn't exist to store lists cleanly
if not exist "update_lists" mkdir "update_lists"

:: ========================================================
:: ARGUMENT CHECK (Automated Silent Execution)
:: ========================================================
if "%~1"=="1" (
    if exist "update_lists\list_default.txt" (
        echo [INFO] Argument 1 detected. Running default list automatically...
        for /f "usebackq delims=" %%A in ("update_lists\list_default.txt") do (
            echo Updating %%A...
            winget upgrade --id "%%A" --accept-source-agreements --accept-package-agreements
        )
        goto :eof
    ) else (
        echo [ERROR] Argument 1 passed, but no list labeled 'default' was found.
        goto :eof
    )
)

:: ========================================================
:: INTERACTIVE MAIN MENU
:: ========================================================
:MAIN_MENU
cls
echo ========================================================
echo               WINGET ADVANCED APP MANAGER
echo ========================================================
echo  1. Run 'default' List
echo  2. Run Custom List(s) (Choose one or more)
echo  3. Edit / Delete Saved Lists
echo  4. Display All Installed Apps (Name, ID, Version)
echo  5. Create New Update List (Pick via number/CSV)
echo  6. Exit
echo ========================================================
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto :RUN_DEFAULT
if "%choice%"=="2" goto :RUN_CUSTOM
if "%choice%"=="3" goto :EDIT_LISTS
if "%choice%"=="4" goto :DISPLAY_ALL
if "%choice%"=="5" goto :CREATE_LIST
if "%choice%"=="6" goto :eof
goto :MAIN_MENU

:RUN_DEFAULT
cls
echo ========================================================
echo                  RUNNING DEFAULT LIST
echo ========================================================
if not exist "update_lists\list_default.txt" (
    echo [ERROR] No default list found. Create a list first and name it 'default'.
    pause
    goto :MAIN_MENU
)
for /f "usebackq delims=" %%A in ("update_lists\list_default.txt") do (
    echo Updating %%A...
    winget upgrade --id "%%A" --accept-source-agreements --accept-package-agreements
)
echo Default updates finished.
pause
goto :MAIN_MENU

:RUN_CUSTOM
cls
echo ========================================================
echo                  RUN CUSTOM LISTS
echo ========================================================
set count=0
for %%F in ("update_lists\list_*.txt") do (
    set /a count+=1
    set "listname=%%~nF"
    set "listname=!listname:list_=!"
    set "list[!count!]=!listname!"
    echo  !count!. !listname!
)
if %count%==0 (
    echo No lists saved yet.
    pause
    goto :MAIN_MENU
)
echo ========================================================
set /p pick="Enter list numbers to run (comma separated, e.g., 1,3): "
for %%N in (%pick%) do (
    set "target=!list[%%N]!"
    if defined target (
        echo.
        echo --- Processing List: !target! ---
        for /f "usebackq delims=" %%A in ("update_lists\list_!target!.txt") do (
            echo Updating %%A...
            winget upgrade --id "%%A" --accept-source-agreements --accept-package-agreements
        )
    )
)
pause
goto :MAIN_MENU

:EDIT_LISTS
cls
echo ========================================================
echo                  EDIT / DELETE LISTS
echo ========================================================
set count=0
for %%F in ("update_lists\list_*.txt") do (
    set /a count+=1
    set "listname=%%~nF"
    set "listname=!listname:list_=!"
    set "list[!count!]=!listname!"
    echo  !count!. !listname!
)
if %count%==0 (
    echo No lists available.
    pause
    goto :MAIN_MENU
)
echo ========================================================
set /p edit_pick="Select a list number to modify: "
set "target=!list[%edit_pick%]!"
if not defined target goto :MAIN_MENU

echo.
echo Chosen list: !target!
echo  1. Delete List
echo  2. View Included IDs
echo  3. Cancel
set /p edit_action="Choose action (1-3): "
if "%edit_action%"=="1" (
    del "update_lists\list_!target!.txt"
    echo List '!target!' deleted.
    pause
)
if "%edit_action%"=="2" (
    echo.
    echo --- App IDs in !target! ---
    type "update_lists\list_!target!.txt"
    echo -----------------------------
    pause
)
goto :MAIN_MENU

:DISPLAY_ALL
cls
echo Fetching installed applications via Winget... This might take a moment.
winget list
pause
goto :MAIN_MENU

:CREATE_LIST
cls
echo Scanning machine for installed applications...

set "temp_ids=%TEMP%\selected_ids.txt"
if exist "%temp_ids%" del "%temp_ids%"

:: Offload processing to a bulletproof inline PowerShell parser
powershell -NoProfile -Command ^
    "$raw = winget list | Select-String -Pattern '^\s*[-]+' -NotMatch; " ^
    "$header = $raw[0].ToString(); " ^
    "$idStart = $header.IndexOf('Id'); " ^
    "$versionStart = $header.IndexOf('Version'); " ^
    "$apps = @(); " ^
    "for ($i=1; $i -lt $raw.Count; $i++) { " ^
    "    $line = $raw[$i].ToString(); " ^
    "    if ($line.Trim() -and $line -notmatch '^Name\s+Id') { " ^
    "        $name = $line.Substring(0, $idStart).Trim(); " ^
    "        $id = $line.Substring($idStart, ($versionStart - $idStart)).Trim(); " ^
    "        if ($id) { " ^
    "            $apps += [PSCustomObject]@{ Index = $apps.Count + 1; Name = $name; Id = $id }; " ^
    "            Write-Host ('[{0}] {1} ({2})' -f $apps.Count, $name, $id); " ^
    "        } " ^
    "    } " ^
    "}; " ^
    "if ($apps.Count -eq 0) { Write-Host 'No apps found.'; exit; }; " ^
    "$csv = Read-Host 'Enter numbers of apps to include (separated by commas, e.g. 1,4,6)'; " ^
    "$choices = $csv.Split(',') | ForEach-Object { [int]$_.Trim() }; " ^
    "foreach ($c in $choices) { " ^
    "    $match = $apps | Where-Object { $_.Index -eq $c }; " ^
    "    if ($match) { " ^
    "        $match.Id | Out-File -FilePath '%temp_ids%' -Append -Encoding ascii; " ^
    "        Write-Host ('Added ID: ' + $match.Id); " ^
    "    } " ^
    "}"

echo.
if not exist "%temp_ids%" (
    echo [INFO] No applications were selected or saved.
    pause
    goto :MAIN_MENU
)

set /p save_choice="Would you like to save this list of applications to update? (Y/N): "
if /i "%save_choice%"=="Y" (
    set /p list_name="Enter name for this list (use 'default' to link with automation parameter): "
    set "list_name=!list_name:.txt=!"
    copy /y "%temp_ids%" "update_lists\list_!list_name!.txt" >nul
    echo List successfully saved under 'update_lists\list_!list_name!.txt'!
)

if exist "%temp_ids%" del "%temp_ids%"
pause
goto :MAIN_MENU
