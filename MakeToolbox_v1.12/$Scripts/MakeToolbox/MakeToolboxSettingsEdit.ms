--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 3.29.2012 >> Release -ad
--- version 1.12 : 3.29.2012 >> Added support for 2013 and 
--					other versions of 3DSMax
--*****************************************************


--Destroys dialog if it exists
try(destroyDialog MakeToolboxSettingsdialog)catch()

--Declarations / read ini
(
global modulesDirectory = getIniSetting MakeToolboxSettingsINI "Modules Directory" "modulesDirectory"
global runningManDirectory = getIniSetting MakeToolboxSettingsINI "Running Man Directory" "runningManDirectory"
)

--Rollout construction
rollout MakeToolboxSettingsdialog "Make Toolbox Settings" width:600 height:110
(
	
--Refresh ini settings
on MakeToolboxSettingsdialog open do
	(
	modulesDirectory = getIniSetting MakeToolboxSettingsINI "Modules Directory" "modulesDirectory"
	runningManDirectory = getIniSetting MakeToolboxSettingsINI "Running Man Directory" "runningManDirectory"
	)	
	
--Generate the UI
Group " Load Directories "
	(
	button chooseModules " Modules Dir" height:17 width:100 align:#left offset:[-4,-2]
	edittext chooseModulesEditText readonly:true width:486 offset:[92,-22] text:(modulesDirectory as string)
	button chooseRunningMan " RunningMan Dir" height:17 width:100 align:#left offset:[-4,-2]
	edittext chooseRunningManEditText readonly:true width:486 offset:[92,-22] text:(runningManDirectory as string)
	)
button okButton "OK" height:25 width:50 offset:[270,12]
button cancelButton "Cancel" height:25 width:62 offset:[214,-30]
button resetButton " Reset Defaults" Height:17 width:100 offset:[-5,-43] align:#left
button updateModulesButton " Update Modules" Height:17 width:100 offset:[-5,-3] align:#left

--Buttons
on updateModulesButton pressed do
	(
	if querybox "Attempt to copy files from the network into your local max directory? If you are uncomfortable with what this means, then don't do it." then
		(
		try
			(
			versionVar =  (maxVersion())[1]

			case versionVar of 
				(
				13000: (ShellLaunch "C:\Program Files\Autodesk\3ds Max 2011\Scripts\MakeToolbox\updateModules_2011.bat" "")
				15000: (ShellLaunch "C:\Program Files\Autodesk\3ds Max 2011\Scripts\MakeToolbox\updateModules_2013.bat" "")
				)
			
			)catch()
		)
	)	
	
on chooseModules pressed do
	(
	modulesDirectory = getSavePath()
	if modulesDirectory != undefined then
		(
		chooseModulesEditText.text = modulesDirectory
		setIniSetting MakeToolboxSettingsINI "Modules Directory" "modulesDirectory" (modulesDirectory)
		)else()
	)

on chooseRunningMan pressed do
	(
	runningManDirectory = getSavePath()
	if runningManDirectory != undefined then
		(
		chooseRunningManEditText.text = runningManDirectory
		setIniSetting MakeToolboxSettingsINI "Running Man Directory" "runningManDirectory" (runningManDirectory)
		)else()
	)
on resetButton pressed do 
	(
		
	versionVar =  (maxVersion())[1]

	case versionVar of 
		(
		13000: (modulesDirectory = "C:\Program Files\Autodesk\3ds Max 2011\Scripts\MakeToolbox\modules")
		15000: (modulesDirectory = "C:\Program Files\Autodesk\3ds Max 2013\Scripts\MakeToolbox\modules")
		)
		
	runningManDirectory = "U:\makeToolbox\ScriptRepository"
	chooseModulesEditText.text = modulesDirectory
	chooseRunningManEditText.text = runningManDirectory
	setIniSetting MakeToolboxSettingsINI "Modules Directory" "modulesDirectory" (modulesDirectory)
	setIniSetting MakeToolboxSettingsINI "Running Man Directory" "runningManDirectory" (runningManDirectory)
	)
	
on cancelButton pressed do try(destroyDialog MakeToolboxSettingsdialog)catch()
	
on okButton pressed do
	(
	try
		(	
		destroyDialog MakeToolboxSettingsdialog
		filein "$Scripts\Startup\MakeToolbox_Start.ms"
		)catch()
	)
)

createDialog MakeToolboxSettingsdialog