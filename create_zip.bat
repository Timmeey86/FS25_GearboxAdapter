@echo off
for %%a in ("%~dp0\.") do set "MOD_NAME=%%~nxa"
set "TEMP_FOLDER=%LOCALAPPDATA%\FarmSimTemp\%MOD_NAME%"
echo Copying relevant files to temp folder
robocopy . "%TEMP_FOLDER%" /mir /XD ".vscode" ".git" "ahk" "doc" "test" /XF "*.py" "*.fsproj" "*.bat" "*.md" "*.txt" "*.zip" ".gitignore" "luacov.*"
echo Creating zip file
set "ZIP_FILE_PATH=%~dp0\%MOD_NAME%.zip"
if exist "%ZIP_FILE_PATH%" del -q "%ZIP_FILE_PATH%"
pushd "%TEMP_FOLDER%"
tar -a -c -f "%ZIP_FILE_PATH%" "*.*"
popd

echo Creating AHK zip file
pushd "%~dp0\ahk"
tar -a -c -f "%~dp0\GearboxAdapter_Autohokey.zip" "*.*"
popd