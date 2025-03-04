--------------------------------------------------
-- Made by Aaron Dabelow theonlyaaron@gmail.com --
--------------------------------------------------

-- The Main Struct for this thing 
global MakeToolbox 	-- Reserved ro the UI item. This must remain this for the modules to load and unload properly
global MakeToolbox1 -- The data object for everything else, this is what should be used for future features

struct MakeToolbox1Str 
(
	-- Function for forcing a launch, regardless of settings, intended to be called from the UI
	function fnLaunchForce =
	(
		-- MakeToolbox.execDir
		filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxSidebar.ms" )
		--filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxAutobak.ms" )
	),

	-- Function for deciding to launch at startup 
	function fnLaunchSoft =
	(
		if ( execute ( getinisetting MakeToolbox1.iniFile "Startup" "startupToolbox" ) )
		then ( filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxSidebar.ms" ) )

		--if ( execute ( getinisetting MakeToolbox1.iniFile "Startup" "startupAutobak" ) )
		--then ( filein ( MakeToolbox1.execDir + @"/bin/MakeToolboxAutobak.ms" ) )
	),

	-- This will return an INI file. If one does not exist, or this version is newer it will create or update it
	function fnGetIni =
	(
		curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )
		createNewIni = false

		if 	 ( doesfileexist curFile )
		then
		(
			versionINI = ( getIniSetting curfile "Startup" "version")

			prop1f = filterstring versionINI "." 
			prop2f = filterstring MakeToolbox1.version "." 

			for i in 1 to prop1f.count do ( if prop2f[i] > prop1f[i] then createNewIni = true )
		)
		else ( createNewIni = true ) 

		--  If one does not exist, or this version is newer it will create or update it
		if createNewIni
		then
		(
			makedir ( ( getdir #plugcfg ) + @"\MakeToolbox\" )
			newfile = createFile ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" ) 
			close 	newFile
			curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

			setIniSetting curfile "Startup" "version" 					MakeToolbox1.version
			setIniSetting curfile "Startup" "startupToolbox" 			"true"
			setIniSetting curfile "Startup" "startupAutobak"			"true"

			setINISetting curfile "Sidebar" "CurPreset"					"common"
			setINISetting curfile "Sidebar" "MT_docked" 				"true"
			setINISetting curfile "Sidebar" "MT_pos" 					"[150,150]"
			setINISetting curfile "Sidebar" "MT_height" 				"500"

			setINISetting curfile "Presets" "animation"	 				"#( \"MT_ControllerCollapse.ms\" , \"MT_TransformsBaker.ms\" , \"MT_Camera_Shaker.ms\")"
			setINISetting curfile "Presets" "common"	 				"#( \"MT_MaterialsAndWires.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_Lock_Transforms.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_ColorsThinger.ms\" )"
			setINISetting curfile "Presets" "effects"	 				"#( \"MT_TransformsBaker.ms\" , \"MT_ControllerCollapse.ms\" , \"MT_Cluster_attach.ms\" ) "
			setINISetting curfile "Presets" "modeling"	 				"#( \"MT_GeometryPrimitives.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_Cluster_attach.ms\" , \"MT_RemoveWingedVerts.ms\" ) "
			setINISetting curfile "Presets" "render"	 				"#( \"MT_TurntableMaker.ms\", \"MT_MaterialsAndWires.ms\", \"MT_ModifierGlobals.ms\" , \"MT_ColorsThinger.ms\" ) "
			setINISetting curfile "Presets" "rigging"	 				"#( \"MT_EditPivots.ms\" , \"MT_MirrorRig.ms\" , \"MT_ControllerTools.ms\" , \"MT_SkinningTools.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_BasicRigs.ms\" ) "
			setINISetting curfile "Presets" "current"	 				"#( \"MT_MaterialsAndWires.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_Lock_Transforms.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_ColorsThinger.ms\" )"

			setINISetting curfile "Autobak" "posOffset" 				"[0,0]"
		)					

		return curFile
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
MakeToolbox1.version 	= "1.19.0"
MakeToolbox1.execDir 	= getFilenamePath( getThisScriptFilename() )
MakeToolbox1.modulesDir	= ( MakeToolbox1.execDir + @"\bin\modules\" )
MakeToolbox1.scriptsDir	= ( MakeToolbox1.execDir + @"\bin\scriptsRepo\" )
MakeToolbox1.iniFile 	= MakeToolbox1.fnGetIni()--( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

-- call one of these two functions for the different launch situations 
--MakeToolbox1.fnLaunchForce()
--MakeToolbox1.fnLaunchSoft()
