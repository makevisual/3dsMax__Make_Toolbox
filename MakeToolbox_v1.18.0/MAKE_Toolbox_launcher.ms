--------------------------------------------------
-- Made by Aaron Dabelow theonlyaaron@gmail.com --
--------------------------------------------------

-- The Main Struct for this thing 
global MakeToolbox 	-- Reserved ro the UI item. This must remain this for the modules to load and unload properly
global MakeToolbox1 -- The data object for everything else, this is what should be used for future features
clearlistener()

struct MakeToolbox1Str 
(
	-- Function for forcing a launch, regardless of settings, intended to be called from the UI
	function fnLaunchForce =
	(
		-- MakeToolbox.execDir
		filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxSidebar.ms" )
		filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxAutobak.ms" )
	),

	-- Function for deciding to launch at startup 
	function fnLaunchSoft =
	(
		if ( execute ( getinisetting MakeToolbox1.iniFile "Startup" "startupToolbox" ) )
		then ( filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxSidebar.ms" ) )

		if ( execute ( getinisetting MakeToolbox1.iniFile "Startup" "startupAutobak" ) )
		then ( filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxAutobak.ms" ) )
	),

	-- Global properties to be shared around 
	version 	= undefined,
	iniFile 	= undefined,
	uiSidebar 	= undefined, 
	uiAutobak 	= undefined, 
	uiSettings 	= undefined, 
	uiPresets 	= undefined, 
	execDir 	= undefined, 
	modulesDir 	= undefined,
	scriptsDir 	= undefined,
	functions 	= undefined 
)

-- set some settings
MakeToolbox1 			= MakeToolbox1Str()
MakeToolbox1.version 	= "1.18.0"
MakeToolbox1.execDir 	= getFilenamePath( getThisScriptFilename() )
MakeToolbox1.modulesDir	= ( MakeToolbox1.execDir + @"\bin\modules\" )
MakeToolbox1.scriptsDir	= ( MakeToolbox1.execDir + @"\bin\scriptsRepo\" )
MakeToolbox1.iniFile 	= ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

-- call one of these two functions for the different launch situations 
--MakeToolbox1.fnLaunchForce()
--MakeToolbox1.fnLaunchSoft()
