@echo off
setlocal

set MASM32=C:\masm32
if not exist "%MASM32%\bin\ml.exe" (
  echo MASM32 was not found at %MASM32%.
  echo Install MASM32 or update MASM32 in this script.
  exit /b 1
)

"%MASM32%\bin\ml.exe" /c /coff /Cp /nologo src\main.asm
if errorlevel 1 exit /b 1

"%MASM32%\bin\link.exe" /SUBSYSTEM:WINDOWS /nologo main.obj
if errorlevel 1 exit /b 1

if exist WaferFab.exe del WaferFab.exe
ren main.exe WaferFab.exe
del main.obj
echo Built WaferFab.exe
