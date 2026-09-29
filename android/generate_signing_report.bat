@echo off
echo ====================================
echo Generating SHA-1 and SHA-256 fingerprints
echo ====================================
echo.
cd %~dp0
call gradlew signingReport

echo.
echo ====================================
echo Copy the debug certificate fingerprints
echo and add them to your Firebase Console
echo ====================================
echo.
pause
