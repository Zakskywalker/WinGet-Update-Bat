@echo off
echo ==========================================
echo  Updating Visual Studio, Firefox, and More
echo ==========================================

:: Update Firefox
echo Checking for Mozilla Firefox updates...
winget upgrade --id Mozilla.Firefox --accept-source-agreements --accept-package-agreements

:: Update Visual Studio (Community, Professional, or Enterprise)
echo Checking for Visual Studio updates...
winget upgrade --id Microsoft.VisualStudio.2026.Enterprise --accept-source-agreements --accept-package-agreements

echo ==========================================
echo  All specified updates have been processed!
echo ==========================================
pause
