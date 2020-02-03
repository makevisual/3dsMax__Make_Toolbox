

struct MT_Functions
(
	function get_ini =
	(
		-- try and get the file
		curFile = ( ( getdir #userscripts ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

		-- make a new one if it does not exist
		if 	 ( doesfileexist curFile ) 
		then ( )					
		else 
		(
			makedir ( ( getdir #userscripts ) + @"\MakeToolbox\" )
			newfile = createFile ( ( getdir #userscripts ) + @"\MakeToolbox\MakeToolbox_Settings.ini" ) 
			close 	newFile
			curFile = ( ( getdir #userscripts ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

			setINISetting curfile "Sidebar" "moduleRepository" 		@"U:\Make_Tools\MakeToolbox\ModulesRepositry"
			setINISetting curfile "Sidebar" "scriptRepository"	 	@"U:\Make_Tools\MakeToolbox\ScriptRepository"
			setINISetting curfile "Sidebar" "CurPreset"				@"common"
			setINISetting curfile "Sidebar" "MT_docked" 			@"true"
			setINISetting curfile "Sidebar" "MT_pos" 				@"[150,150]"
			setINISetting curfile "Sidebar" "MT_height" 			@"500"
			setINISetting curfile "Sidebar" "MT_OpenOnLaunch" 		@"true"
			setINISetting curfile "Presets" "animation"	 			"#( \"MT_ControllerCollapse.ms\" , \"MT_TransformsBaker.ms\" , \"MT_Camera_Shaker.ms\" , \"MT_DebrisMaker.ms\" , \"MT_ParticleConnector.ms\" )"
			setINISetting curfile "Presets" "common"	 			"#( \"MT_MaterialsAndWires.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_Lock_Transforms.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_ColorsThinger.ms\" )"
			setINISetting curfile "Presets" "effects"	 			"#( \"MT_ParticleBake.ms\" , \"MT_TransformsBaker.ms\" , \"MT_ControllerCollapse.ms\" , \"MT_Cluster_attach.ms\" , \"MT_ParticleConnector.ms\" ) "
			setINISetting curfile "Presets" "modeling"	 			"#( \"MT_GeometryPrimitives.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_Cluster_attach.ms\" , \"MT_RemoveWingedVerts.ms\" , \"MT_ObjectConformer.ms\" ) "
			setINISetting curfile "Presets" "render"	 			"#( \"MT_TurntableMaker.ms\" , \"MT_TextureResizer.ms\" , \"MT_MaterialsAndWires.ms\" , \"MT_Isolate_A_Light.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_ColorsThinger.ms\" ) "
			setINISetting curfile "Presets" "rigging"	 			"#( \"MT_EditPivots.ms\" , \"MT_MirrorRig.ms\" , \"MT_ControllerTools.ms\" , \"MT_SkinningTools.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_BasicRigs.ms\" ) "
			setINISetting curfile "Presets" "current"	 			@"#()"
			setINISetting curfile "Autobak" "posOffset" 			@"[0,0]"
		)
		
		-- return the ini file
		return curFile
	),

	function get_modules =
	(
		moduleNames 	 	= #()
		moduleRepository 	= getinisetting ( MT_Functions.get_ini() ) "Sidebar" "moduleRepository"
		modules 			= getfiles ( moduleRepository + @"\*.ms" )

		moduleNames = for module in modules collect (substring ( getFilenameFile module ) 4 1000 )
		return moduleNames
	),

	function ScriptLauncher_run =
	(
		global scriptmanager_open
		addModuleToMemory = false
		targetDir = ( getINISetting ( MT_Functions.get_ini() ) "Sidebar" "scriptRepository" )  
		filein ( MT_files + @"\bin\MakeToolboxScriptmanager.ms" )
		scriptManager_open (targetDir + "\\") buttonText:"Run Script" titleText:"Choose script to run"
	),

	function Toggle_OpenOnLaunch =
	(
		if ( execute ( getinisetting ( MT_functions.get_ini() ) "Sidebar" "MT_OpenOnLaunch" ) )
		then
		(
			filestr = ("try( filein \"" + MT_files + "MakeToolbox_Launch.ms\" ) catch()" )
			newfile = createFile ( ( getdir #userStartupScripts ) + @"\MakeToolbox.ms" ) 
			format	filestr to:newFile
			close 	newFile
		)
		else
		(
			filestr = ""
			newfile = createFile ( ( getdir #userStartupScripts ) + @"\MakeToolbox.ms" ) 
			format	filestr to:newFile
			close 	newFile
		)
	),

	function UI_SidebarInfo =
	(
		rollout SidebarInfo "Make Toolbox Info"
		(
			label lab1 ""
			button btn1 "Open online help" width:150 height:30

			on SidebarInfo open do 
			(
				lab1.text = ( "Version " + ( MT_versionNumber as string ) )
			)

			on btn1 pressed do 
			(
				shelllaunch "http://makevisual.com/brain/index.php?title=Make_Toolbox" ""
			)
		)

		CreateDialog SidebarInfo 200 65
	),

	function UI_SidebarCustomPresets_init =
	(
		curPresets  		= getinisetting ( MT_Functions.get_ini() ) "Presets"
 		curCustomPresets 	= #()

 		for item in curPresets do
		(
			if item != "animation" and item != "animation" and item != "common" and item != "effects" and item != "modeling" and item != "render" and item != "rigging" and item != "current"
			then ( append curCustomPresets item )
		)

		MT_SidebarCustomPresets.ddl_presets.items 	= curPresets
		MT_SidebarCustomPresets.ddl_presets2.items 	= curCustomPresets

 		setdialogpos MT_SidebarCustomPresets ( ( getdialogpos MakeToolbox ) + [190,0] ) 
	),

	function UI_SidebarCustomPresets_Save =
	(
		curPreset = ( execute ( getINISetting ( MT_Functions.get_ini() ) "Presets" "Current" ) )
		setinisetting ( MT_Functions.get_ini() ) "Presets" ( MT_SidebarCustomPresets.edt_saveName.text ) ( curPreset as string )
		setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" ( MT_SidebarCustomPresets.edt_saveName.text )
		MT_Functions.UI_SidebarCustomPresets_init()
	),

	function UI_SidebarCustomPresets_Load arg_preset =
	(
		presets 			= ( getinisetting ( MT_Functions.get_ini() ) "Presets" )
 		chosenPrest 		= presets[arg_preset]
 		setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" chosenPrest
  		modules 			= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" chosenPrest ) )

	   	MT_Functions.UI_Sidebar_LoadModules modules
	),

	function UI_SidebarCustomPresets_Delete arg_selected =
	(
		if arg_selected != undefined
		then 
		(
			delIniSetting ( MT_Functions.get_ini() ) "Presets" arg_selected
			MT_Functions.UI_SidebarCustomPresets_init()
		)
	),

	function UI_SidebarCustomPresets =
	(
		rollout MakeToolboxCustomPresets "Make Toolbox Custom Presets"
		(
			groupbox grp1 "Load preset" height:45 offset:[-5,0] width:(MakeToolboxCustomPresets.width - 15)
			dropdownlist ddl_presets offset:[ 0, -33 ]

			groupbox grp2 "Save custom preset" height:70 offset:[-5,5] width:(MakeToolboxCustomPresets.width - 15)
			edittext edt_saveName text:"custom preset 1" height:20 offset:[ 0, -58 ]
			button btn_savePreset "Save current modules as preset" width:(MakeToolboxCustomPresets.width - 25)

			groupbox grp3 "Delete custom preset" height:70 offset:[-5,5] width:(MakeToolboxCustomPresets.width - 15)
			dropdownlist ddl_presets2 offset:[ 0, -58 ]
			button btn_deletePreset "Delete selected preset" width:(MakeToolboxCustomPresets.width - 25)

			on ddl_presets selected arg do 
			(
				MT_Functions.UI_SidebarCustomPresets_Load arg
			)

			on btn_savePreset pressed do 
			(
				MT_Functions.UI_SidebarCustomPresets_Save()
			)

			on btn_deletePreset pressed do 
			(
 				MT_Functions.UI_SidebarCustomPresets_Delete ddl_presets2.selected
			)

		)

		try ( DestroyDialog MakeToolboxCustomPresets )catch()
		createDialog MakeToolboxCustomPresets 300 205 style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing)

		MT_SidebarCustomPresets = MakeToolboxCustomPresets
	),

	function UI_SidebarSettings = 
	(
		rollout MakeToolboxSettings ("Make Toolbox Settings v" + (MT_versionNumber as string))
		(
			button 		btn_setModulesDir "Modules"	width:60 height:20	align:#left pos:[5,5]
			button  	btn_setScriptsDir "Scripts"	width:60 height:20 	align:#left pos:[5,25]
			label 		lab_modules	width:( MakeToolboxSettings.width - 70 )	style_sunkenedge:true	height:20	pos:[65,5]
			label 		lab_scripts	width:( MakeToolboxSettings.width - 70 )	style_sunkenedge:true	height:20	pos:[65,25]
			checkbox 	chk_startup "Launch MAKE Toolbox on 3dsMax Startup" offset:[51,0]

			on btn_setModulesDir pressed do 
			(
				newPath = getSavepath()
				if newPath != undefined 
				then 
				(
					setinisetting ( MT_Functions.get_ini() ) "Sidebar" "moduleRepository" newPath
					MT_Settings.lab_modules.text = ( "  " + newPath )
				)	
				else()
			)

			on btn_setScriptsDir pressed do 
			(
				newPath = getSavepath()
				if newPath != undefined 
				then 
				(
					setinisetting ( MT_Functions.get_ini() ) "Sidebar" "scriptRepository" newPath
					MT_Settings.lab_scripts.text = ( "  " + newPath )
				)	
				else()
			)

			on chk_startup changed state do 
			(
				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "MT_OpenOnLaunch" ( state as string )
				MT_Functions.Toggle_OpenOnLaunch()
			)
		)

 		try( DestroyDialog MakeToolboxSettings ) catch()

		createDialog MakeToolboxSettings 500 70  style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing)
		return MakeToolboxSettings
	),

	function UI_SidebarSettings_init = 
	(
		modulesDir 		= getinisetting ( MT_Functions.get_ini() ) "Sidebar" "moduleRepository"
		settingsDir 	= getinisetting ( MT_Functions.get_ini() ) "Sidebar" "scriptRepository"
		openOnLaunch 	= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "MT_OpenOnLaunch" ) )

		MT_Settings.lab_modules.text 		= ( "  " + modulesDir )
		MT_Settings.lab_scripts.text 		= ( "  " +  settingsDir )
		MT_Settings.chk_startup.checked 	= openOnLaunch
	),

	function UI_Sidebar_modulesClear =
	(
		for i in 1 to MakeToolbox.theSubrollout.rollouts.count do
		(
			removeSubRollout MakeToolbox.theSubrollout MakeToolbox.theSubrollout.rollouts[MakeToolbox.theSubrollout.rollouts.count]
		)
		setinisetting ( MT_Functions.get_ini() ) "Presets" "current" "#()"
	),

	function UI_Sidebar_moduleLoad arg_int = -- arg_int: the selected index
	(
		moduleRepository 	= getinisetting ( MT_Functions.get_ini() ) "Sidebar" "moduleRepository"
		modules 			= getfiles ( moduleRepository + @"\*.ms" )

		loadedModules 		= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "current" ) )
		append loadedModules ( ( getfilenamefile modules[arg_int] ) + @".ms" )

		setinisetting ( MT_Functions.get_ini() ) "Presets" "current" ( loadedModules as string )

		filein modules[arg_int]
	),

	function UI_Sidebar_resized =
	(
		MakeToolbox.theSubrollout.height 		= (MakeToolbox.height - 76)
 		MakeToolbox.btn_settings.pos 			= [0,(MakeToolbox.height - 20)]
 		MakeToolbox.btn_scripts.pos 			 	= [70,(MakeToolbox.height - 20)]
 		MakeToolbox.btn_info.pos 				= [135,(MakeToolbox.height - 20)]
 		MakeToolbox.btn_detach.pos 				= [155,(MakeToolbox.height - 20)]
		MakeToolbox.btn_attach.pos 				= [155,(MakeToolbox.height - 20)]

		iniFile = MT_Functions.get_ini()
		setIniSetting iniFile "Sidebar" "MT_height" (MakeToolbox.height as string)
 	),

 	function UI_Sidebar_init =
 	(
		MT_docked 	= execute ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "MT_docked" )
		MT_height 	= execute ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "MT_height" )
		MT_pos 	 	= execute ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "MT_pos" )

		if MT_docked == false
		then
		(
			MakeToolbox.btn_detach.visible 	= false
			MakeToolbox.btn_attach.visible	= true
			MakeToolbox.height 				= MT_height
 			SetDialogPos MakeToolbox MT_pos
		)
		else 
		(
			MT_Functions.UI_Sidebar_Attach()
		)

		MakeToolbox.thedrop.items = MT_Functions.get_modules()
 		curPreset 	= ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" )
  		modules 	= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" curPreset ) )
 	   	MT_Functions.UI_Sidebar_LoadModules modules
 	),

	function UI_Sidebar_moved =
	( 

		setIniSetting ( MT_Functions.get_ini() ) "Sidebar" "MT_pos" ( GetDialogPos MakeToolbox as string )
	),

	function UI_Sidebar_Detach =
	(
		cui.UnRegisterDialogBar MakeToolbox

		MakeToolbox.btn_detach.visible 	= false
		MakeToolbox.btn_attach.visible 	= true
 		MakeToolbox.height				= 500
  		MakeToolbox.width 				= 175

		setIniSetting ( MT_Functions.get_ini() ) "Sidebar" "MT_docked" "false"
	),

	function UI_Sidebar_Attach = 
	(
 		MakeToolbox.height				= 2000
		MakeToolbox.btn_detach.visible 	= true
		MakeToolbox.btn_attach.visible 	= false

		try
		(
			cui.registerdialogbar 	MakeToolbox style:#(#cui_dock_left,#cui_floatable)
			cui.dockdialogbar 		MakeToolbox #cui_dock_left
		)
		catch()

		setIniSetting ( MT_Functions.get_ini() ) "Sidebar" "MT_docked" "true"
	),

	function UI_Sidebar_LoadModules arg_modules = -- arg: array of modules to load
	(
		MT_Functions.UI_Sidebar_modulesClear()
		modulePath = ( getinisetting ( MT_Functions.get_ini() ) "Sidebar" "moduleRepository" )

 		for module in arg_modules do 
 		(
 			filein ( modulePath + @"\" + module )
 		)

 		setINISetting ( MT_Functions.get_ini() ) "Presets" "current" ( arg_modules as string )
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
				targetModules =  execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "common" )
 				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" "common"
 				MT_Functions.UI_Sidebar_LoadModules targetModules
			)

			2:( -- modeling
				targetModules =  execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "modeling" )
 				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" "modeling"
 				MT_Functions.UI_Sidebar_LoadModules targetModules
			)

			3:( -- rigging
				targetModules =  execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "rigging" )
 				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" "rigging"
 				MT_Functions.UI_Sidebar_LoadModules targetModules
			)

			4:( -- animation
				targetModules =  execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "animation" )
 				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" "animation"
 				MT_Functions.UI_Sidebar_LoadModules targetModules
			)

			5:( -- render
				targetModules =  execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "render" )
 				setinisetting ( MT_Functions.get_ini() ) "Sidebar" "CurPreset" "render"
 				MT_Functions.UI_Sidebar_LoadModules targetModules
			)

			6:(
 				MT_Functions.UI_SidebarCustomPresets()
 				MT_Functions.UI_SidebarCustomPresets_init()
			)
		)
	),

	function UI_Sidebar =
	(
 		try( cui.UnRegisterDialogBar MakeToolbox )catch()
 		try( DestroyDialog MakeToolbox ) catch()

		-- The Sidebar Rollout
		rollout MakeToolbox ("Make Toolbox v" + (MT_versionNumber as string))
		(
			checkbutton btn_H1 "C" 		height:29 width:29  pos:[0,0] 		checked:true 	border:true 	images:#( ( MT_files + @"\bin\images\h1.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Common Tools"
			checkbutton btn_H2 "M" 		height:29 width:29 	pos:[(29),0] 	checked:false  	border:true 	images:#( ( MT_files + @"\bin\images\h2.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Modeling Tools"
			checkbutton btn_H3 "Ri" 	height:29 width:29 	pos:[(29*2),0] 	checked:false  	border:true 	images:#( ( MT_files + @"\bin\images\h3.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rigging tools"
			checkbutton btn_H4 "A" 		height:29 width:29	pos:[(29*3),0] 	checked:false  	border:true 	images:#( ( MT_files + @"\bin\images\h4.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Animation Tools"
			checkbutton btn_H5 "Rn" 	height:29 width:29 	pos:[(29*4),0] 	checked:false  	border:true 	images:#( ( MT_files + @"\bin\images\h5.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rendering Tools"
			checkbutton btn_H6 "!" 		height:29 width:29 	pos:[(29*5),0] 	checked:false  	border:true 	images:#( ( MT_files + @"\bin\images\h6.jpg" ) , ( MT_files + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Custom Presets" 
				
			dropdownlist theDrop items:#() height:100 width:150 tooltip:"Select your script from the dropdown." pos:[2,32]
			button clearModules " C" width:19 height:19 tooltip:"Edits the chosen script." pos:[153,33]

			SubRollout 	theSubrollout 		"Subrollout" 	height:940 	width:178 pos:[-2,55]	
			imgtag 		MT_headderCheat 					width:180 	height:2 bitmap:MT_headderCheatBM pos:[-2,27] tooltip: "Rig Nodes and Control Splines"
			timer 		clock 				"testClock" 	interval:500 --tick every 5 seconds
				
			button btn_settings 		"Settings" 	height:20 align:#left width:70 	tooltip:"allows you to se the directories that the toolbox is reading from"--pos:[75,0]
			button btn_scripts 			"Scripts" 	height:20 width:65 pos:[3,0] 	tooltip:"Runs the script launcher"
			button btn_info		 		"?" 		height:20 width:20 pos:[120,0] 	tooltip:"gives information and help about the toolbox and modules"
			button btn_detach		 	">" 		height:20 width:20 pos:[150,0] 	visible:false 	tooltip:"detaches the toobox"
			button btn_attach		 	"<" 		height:20 width:20 pos:[150,0] 	visible:true 	tooltip:"attaches the toolbox"

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

			on btn_attach pressed do 
			(
				MT_Functions.UI_Sidebar_Attach()
			)

			on btn_detach pressed do 
			(
				MT_Functions.UI_Sidebar_Detach()
			)

 			on MakeToolbox resized arg do
			(
 				MT_Functions.UI_Sidebar_resized()
			) 

 			on MakeToolbox moved arg do
			(
  				MT_Functions.UI_Sidebar_moved()
			)

			on btn_settings pressed do 
			(
				MT_Settings = MT_Functions.UI_SidebarSettings()
				MT_Functions.UI_SidebarSettings_init()
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

 		try( cui.UnRegisterDialogBar MakeToolbox )catch()
 		try( DestroyDialog MakeToolbox ) catch()

		createDialog MakeToolbox 175 1 1 1 style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing) lockWidth:true
	),

	function MT_Sidebar_Launch = 
	(
		DisableSceneRedraw()

		curGammaSetting 					= IDisplayGamma.colorCorrectionMode

		try
		(
			IDisplayGamma.colorCorrectionMode 	= #none

			MT_Functions.UI_Sidebar()
			MT_Functions.UI_Sidebar_init()
			MT_Functions.Toggle_OpenOnLaunch()

			IDisplayGamma.colorCorrectionMode 	= curGammaSetting
			EnableSceneRedraw()
		)
		catch
		(
			IDisplayGamma.colorCorrectionMode 	= curGammaSetting
			EnableSceneRedraw()
		)
	)
)

MT_Functions.MT_Sidebar_Launch()