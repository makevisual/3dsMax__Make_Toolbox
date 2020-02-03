@echo off

del "C:\Program Files\Autodesk\3ds Max 2011\scripts\Startup\MakeToolbox_Start.ms"
rmdir /s /q "C:\Program Files\Autodesk\3ds Max 2011\scripts\MakeToolbox"

xcopy %~dp0$Scripts\*.* "C:\Program Files\Autodesk\3ds Max 2011\Scripts\" /E /Y