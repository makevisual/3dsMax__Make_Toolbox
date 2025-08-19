global MakeToolbox
global MT_Functions
try( cui.UnRegisterDialogBar MakeToolbox )catch()
try( DestroyDialog MakeToolbox ) catch()
struct MT_Functions_str
(
	MakeToolboxDirectory = (pathConfig.removePathLeaf (getSourceFileName())),
	MakeToolboxModulesDir = (this.MakeToolboxDirectory + @"\modules"),
	MakeToolboxModules = getfiles ( this.MakeToolboxModulesDir + @"\*.ms" ),
	MakeToolboxVersion = (substring (pathConfig.stripPathToLeaf (pathConfig.removePathLeaf this.MakeToolboxDirectory)) 14 100),
	MakeINIFile = ((getDir #plugcfg) + @"\MakeToolbox\MakeToolbox_Settings.ini"),
	-- This will return an INI file. If one does not exist, or this version is newer it will create or update it
	function fnGetIni =
	(
		curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )
		createNewIni = false
		if (doesfileexist curFile) then
		(
			versionINI = ( getIniSetting curfile "Startup" "version")
			prop1f = filterstring versionINI "." 
			prop2f = filterstring MT_Functions.MakeToolboxVersion "." 
			for i in 1 to prop1f.count do
			(
				if prop2f[i] > prop1f[i] do
				(
					createNewIni = true
				)
			)
			if prop1f.count == 0 do
			(
				createNewIni = true
			)
		)
		else
		(createNewIni = true) 
		--  If one does not exist, or this version is newer it will create or update it
		if createNewIni
		then
		(
			makedir ( ( getdir #plugcfg ) + @"\MakeToolbox\" )
			newfile = createFile ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" ) 
			close 	newFile
			curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

			setIniSetting curfile "Startup" "version" 					MT_Functions.MakeToolboxVersion
			setIniSetting curfile "Startup" "startupToolbox" 			"true"
			setIniSetting curfile "Startup" "startupAutobak"			"true"

			setINISetting curfile "Sidebar" "CurPreset"					"common"
			setINISetting curfile "Sidebar" "MT_docked" 				"true"
			setINISetting curfile "Sidebar" "MT_docked_left"			"true"
			setINISetting curfile "Sidebar" "MT_pos" 					"[150,150]"
			setINISetting curfile "Sidebar" "MT_height" 				"500"

			setINISetting curfile "Presets" "animation"	 				"#( \"MT_ControllerCollapse.ms\" , \"MT_TransformsBaker.ms\")"
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
	function get_modules =
	(
		moduleNames = #()
		moduleNames = for module in MT_Functions.MakeToolboxModules collect (substring ( getFilenameFile module ) 4 1000 )
		return moduleNames
	),
	function ScriptLauncher_run =
	(
		global scriptmanager_open
		addModuleToMemory = false
		targetDir = (MT_Functions.MakeToolboxDirectory + @"\scriptsRepo")
		filein ( MT_Functions.MakeToolboxDirectory + @"\MakeToolboxScriptmanager.ms" )
		scriptManager_open (targetDir) buttonText:"Run Script" titleText:"Choose script to run"
	),
	function UI_SidebarInfo =
	(
		rollout SidebarInfo "Make Toolbox Info"
		(
			label lab1 ""
			button btn1 "Open online help" width:150 height:30

			on SidebarInfo open do 
			(
				lab1.text = ( "Version " + ( MT_Functions.MakeToolboxVersion ) )
			)

			on btn1 pressed do 
			(
				shelllaunch "http://makevisual.com/brain/index.php?title=Make_Toolbox" ""
			)
		)
		CreateDialog SidebarInfo 200 65
	),
	function UI_Sidebar_modulesClear =
	(
		for i in 1 to MakeToolbox.theSubrollout.rollouts.count do
		(
			removeSubRollout MakeToolbox.theSubrollout MakeToolbox.theSubrollout.rollouts[MakeToolbox.theSubrollout.rollouts.count]
		)
		setinisetting MT_Functions.MakeINIFile "Presets" "current" "#()"
	),
	function UI_Sidebar_moduleLoad arg_int = -- arg_int: the selected index
	(

		modules 			= MT_FUnctions.MakeToolboxModules
		loadedModules 		= ( execute ( getinisetting this.MakeINIFile "Presets" "current" ) )
		append loadedModules ( ( getfilenamefile modules[arg_int] ) + @".ms" )
		setinisetting this.MakeINIFile "Presets" "current" ( loadedModules as string )
		filein modules[arg_int]
	),
	function UI_Sidebar_resized =
	(
		MakeToolbox.theSubrollout.height 		= (MakeToolbox.height - 76)
 		MakeToolbox.btn_attach_left.pos 		= [0,(MakeToolbox.height - 20)]
 		MakeToolbox.btn_scripts.pos 			= [50,(MakeToolbox.height - 20)]
 		MakeToolbox.btn_info.pos 				= [105,(MakeToolbox.height - 20)]
		MakeToolbox.btn_attach_right.pos 		= [125,(MakeToolbox.height - 20)]

		setIniSetting this.MakeINIFile "Sidebar" "MT_height" (MakeToolbox.height as string)
 	),
 	function UI_Sidebar_init =
 	(
		MT_docked 		= execute ( getinisetting this.MakeINIFile "Sidebar" "MT_docked" )
		MT_docked_left  = execute ( getinisetting this.MakeINIFile "Sidebar" "MT_docked_left" )
		MT_height 		= execute ( getinisetting this.MakeINIFile "Sidebar" "MT_height" )
		MT_pos 	 		= execute ( getinisetting this.MakeINIFile "Sidebar" "MT_pos" )

		if MT_docked == false
		then
		(
			MakeToolbox.btn_attach_right.checked = false
			MakeToolbox.btn_attach_left.checked = false
			MakeToolbox.height = MT_height

 			SetDialogPos MakeToolbox MT_pos
		)
		else 
		(
			if MT_docked_left then
			(
				MakeToolbox.btn_attach_left.checked = true
			)
			else
			(
				MakeToolbox.btn_attach_right.checked = true
			)
			MT_Functions_str.UI_Sidebar_Attach MT_docked_left
		)
		MakeToolbox.thedrop.items = this.get_modules()
 		curPreset 	= ( getinisetting this.MakeINIFile "Sidebar" "CurPreset" )
  		modules 	= ( execute ( getinisetting this.MakeINIFile "Presets" "current" ) )
 	   	MT_Functions_str.UI_Sidebar_LoadModules modules
 	),
	function UI_Sidebar_moved =
	( 
		setIniSetting this.MakeINIFile "Sidebar" "MT_pos" ( GetDialogPos MakeToolbox as string )
	),
	function UI_Sidebar_Detach =
	(
		cui.UnRegisterDialogBar MakeToolbox
 		MakeToolbox.height				= 500
  		MakeToolbox.width 				= 175
		setIniSetting this.MakeINIFile "Sidebar" "MT_docked" "false"
		setIniSetting this.MakeINIFile "Sidebar" "MT_docked_left" "false"
	),
	function UI_Sidebar_Attach attachLeft = 
	(
 		MakeToolbox.height				= 250
		if attachLeft then
		(
			cui.registerdialogbar 	MakeToolbox style:#(#cui_dock_left,#cui_floatable)
			cui.dockdialogbar 		MakeToolbox #cui_dock_left
			setIniSetting MT_Functions.MakeINIFile "Sidebar" "MT_docked_left" "true"
		)
		else
		(
			cui.registerdialogbar 	MakeToolbox style:#(#cui_dock_right,#cui_floatable)
			cui.dockdialogbar 		MakeToolbox #cui_dock_right
			setIniSetting MT_Functions.MakeINIFile "Sidebar" "MT_docked_left" "false"
		)
		setIniSetting MT_Functions.MakeINIFile "Sidebar" "MT_docked" "true"
	),
	function UI_Sidebar_LoadModules arg_modules = -- arg: array of modules to load
	(
		MT_Functions_str.UI_Sidebar_modulesClear()
		modulePath = MT_Functions.MakeToolboxModulesDir

 		for module in arg_modules do 
 		(
 			filein ( modulePath + @"\" + module )

 		)
 		setINISetting MT_Functions.MakeINIFile "Presets" "current" ( arg_modules as string )
	),
	function UI_Sidebar_PresetToggle arg = -- arg: the chosen preset
	(
		presetButtons = #(MakeToolbox.btn_H1,MakeToolbox.btn_H2,MakeToolbox.btn_H3,MakeToolbox.btn_H4,MakeToolbox.btn_H5,MakeToolbox.btn_H6)
		for presetButton in presetButtons do ( presetButton.checked = false )
		presetButtons[arg].checked = true
		targetModules = #()
		case arg of 
		(
			1:( -- common
				targetModules =  execute ( getinisetting this.MakeINIFile "Presets" "common" )
 				setinisetting MT_Functions.MakeINIFile "Sidebar" "CurPreset" "common"
 				MT_Functions_str.UI_Sidebar_LoadModules targetModules
			)

			2:( -- modeling
				targetModules =  execute ( getinisetting this.MakeINIFile "Presets" "modeling" )
 				setinisetting MT_Functions.MakeINIFile "Sidebar" "CurPreset" "modeling"
 				MT_Functions_str.UI_Sidebar_LoadModules targetModules
			)

			3:( -- rigging
				targetModules =  execute ( getinisetting this.MakeINIFile "Presets" "rigging" )
 				setinisetting MT_Functions.MakeINIFile "Sidebar" "CurPreset" "rigging"
 				MT_Functions_str.UI_Sidebar_LoadModules targetModules
			)

			4:( -- animation
				targetModules =  execute ( getinisetting this.MakeINIFile "Presets" "animation" )
 				setinisetting MT_Functions.MakeINIFile "Sidebar" "CurPreset" "animation"
 				MT_Functions_str.UI_Sidebar_LoadModules targetModules
			)

			5:( -- render
				targetModules =  execute ( getinisetting this.MakeINIFile "Presets" "render" )
 				setinisetting MT_Functions.MakeINIFile "Sidebar" "CurPreset" "render"
 				MT_Functions_str.UI_Sidebar_LoadModules targetModules
			)

			6:(
				messagebox "Current modules are now automatically saved as your startup layout. \n \nWhen you re-launch the toolbox, it will have the \nsame layout as when you last closed the it."
			)
		)
	),
	function UI_Sidebar =
	(
		rollout MakeToolbox ("Make Toolbox v" + MT_Functions.MakeToolboxVersion)
		(
			checkbutton btn_H1 "C" 		height:29 width:29  pos:[0,0] 		checked:true 	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h1.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Common Tools"
			checkbutton btn_H2 "M" 		height:29 width:29 	pos:[(29),0] 	checked:false  	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h2.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Modeling Tools"
			checkbutton btn_H3 "Ri" 	height:29 width:29 	pos:[(29*2),0] 	checked:false  	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h3.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rigging tools"
			checkbutton btn_H4 "A" 		height:29 width:29	pos:[(29*3),0] 	checked:false  	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h4.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Animation Tools"
			checkbutton btn_H5 "Rn" 	height:29 width:29 	pos:[(29*4),0] 	checked:false  	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h5.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rendering Tools"
			checkbutton btn_H6 "!" 		height:29 width:29 	pos:[(29*5),0] 	checked:false  	border:true 	images:#( ( this.MakeToolboxDirectory + @"\images\h6.jpg" ) , ( this.MakeToolboxDirectory + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Custom Presets" 
			dropdownlist theDrop items:#() height:100 width:150 tooltip:"Select your script from the dropdown." pos:[2,32]
			button clearModules " C" width:19 height:19 tooltip:"Clears the loaded scripts." pos:[153,33]
			SubRollout 	theSubrollout 		"Subrollout" 	height:940 	width:178 pos:[-2,55]	
			checkbutton btn_attach_left 		"<" 	height:20 align:#left width:50 	tooltip:"attaches/detaches the toolbox to the left"--pos:[75,0]
			button btn_scripts 			"Scripts" 	height:20 width:55 pos:[3,0] 	tooltip:"Runs the script launcher"
			button btn_info		 		"?" 		height:20 width:20 pos:[120,0] 	tooltip:"gives information and help about the toolbox and modules"
			checkbutton btn_attach_right		 	">" 		height:20 width:50 pos:[150,0] 	visible:true tooltip:"attaches/detaches the toolbox to the right"

			on btn_H1 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 1	)
			on btn_H2 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 2	)
			on btn_H3 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 3	)
			on btn_H4 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 4	)
			on btn_H5 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 5	)
 			on btn_H6 changed state do ( MT_Functions.UI_Sidebar_PresetToggle 6	)
			on theDrop selected arg do 
			(
				MT_Functions.UI_Sidebar_moduleLoad arg
			)
			on clearModules pressed do 
			(
				MT_Functions.UI_Sidebar_modulesClear()
			)
			on btn_attach_right changed state do 
			(	
				if state then
				(
					if btn_attach_left.checked do
					(
						btn_attach_left.checked = false
						MT_Functions.UI_Sidebar_Detach()
					)
					MT_Functions.UI_Sidebar_Attach false
				)
				else
				(
					MT_Functions.UI_Sidebar_Detach()
				)
			)
			on btn_attach_left changed state do 
			(
				if state then
				(
					if btn_attach_right.checked do
					(
						btn_attach_right.checked = false
						MT_Functions.UI_Sidebar_Detach()
					)
					MT_Functions.UI_Sidebar_Attach true
				)
				else
				(
					MT_Functions.UI_Sidebar_Detach()
				)
			)
 			on MakeToolbox resized arg do
			(
 				MT_Functions.UI_Sidebar_resized()
			) 
 			on MakeToolbox moved arg do
			(
  				MT_Functions.UI_Sidebar_moved()
			)
			on btn_Scripts pressed do 
			(
				MT_Functions.ScriptLauncher_run()
			)
			on btn_info pressed do 
			(
				MT_Functions.UI_SidebarInfo()
			)
		)
	),
	function MT_Sidebar_Launch = 
	(
  		DisableSceneRedraw()
  		--Color Pipeline adjustments (removed the old gamma settings IDisplayGamma that is deprecated) to account for changes in 3dsMax 2025 and later
 		curGammaSetting = ColorPipelineMgr.Mode
  		try
  		(
 			ColorPipelineMgr.Mode = #Unmanaged
			try( cui.UnRegisterDialogBar MakeToolbox )catch()
			try( DestroyDialog MakeToolbox ) catch()
			
			MakeToolbox = this.UI_Sidebar()
			createDialog MakeToolbox 175 1 1 1 style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing) lockWidth:true
			MT_Functions.UI_Sidebar_init()
 			ColorPipelineMgr.Mode = curGammaSetting
  			EnableSceneRedraw()
  		)
  		catch
  		(
 			ColorPipelineMgr.Mode = curGammaSetting
  			EnableSceneRedraw()
  		)
	)
)
MT_Functions = MT_Functions_str()
if MT_Functions != undefined do 
(	
	MT_Functions.fnGetIni()
	MT_Functions.MT_Sidebar_Launch()
)