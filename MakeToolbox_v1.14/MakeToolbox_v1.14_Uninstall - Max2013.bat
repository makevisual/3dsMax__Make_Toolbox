@echo off

taskkill /f /im 3dsmax.exe

del "C:\Program Files\Autodesk\3ds Max 2013\scripts\Startup\MakeToolbox_Start.ms"
rmdir /s /q "C:\Program Files\Autodesk\3ds Max 2013\scripts\MakeToolbox"