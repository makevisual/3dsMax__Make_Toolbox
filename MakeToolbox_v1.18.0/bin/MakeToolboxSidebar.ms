

struct MT_Functions
(
	function get_ini =
	(
		-- try and get the file
		curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

		-- make a new one if it does not exist
		if 	 ( doesfileexist curFile ) 
		then ( )					
		else 
		(
			makedir ( ( getdir #plugcfg ) + @"\MakeToolbox\" )
			newfile = createFile ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" ) 
			close 	newFile
			curFile = ( ( getdir #plugcfg ) + @"\MakeToolbox\MakeToolbox_Settings.ini" )

			setIniSetting curfile "Startup" "startupToolbox" 			"true"
			setIniSetting curfile "Startup" "startupAutobak"			"true"

			setINISetting curfile "Sidebar" "CurPreset"					"common"
			setINISetting curfile "Sidebar" "MT_docked" 				"true"
			setINISetting curfile "Sidebar" "MT_pos" 					"[150,150]"
			setINISetting curfile "Sidebar" "MT_height" 				"500"

			setINISetting curfile "Presets" "animation"	 				"#( \"MT_ControllerCollapse.ms\" , \"MT_TransformsBaker.ms\" , \"MT_Camera_Shaker.ms\" , \"MT_DebrisMaker.ms\" , \"MT_ParticleConnector.ms\" )"
			setINISetting curfile "Presets" "common"	 				"#( \"MT_MaterialsAndWires.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_Lock_Transforms.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_ColorsThinger.ms\" )"
			setINISetting curfile "Presets" "effects"	 				"#( \"MT_ParticleBake.ms\" , \"MT_TransformsBaker.ms\" , \"MT_ControllerCollapse.ms\" , \"MT_Cluster_attach.ms\" , \"MT_ParticleConnector.ms\" ) "
			setINISetting curfile "Presets" "modeling"	 				"#( \"MT_GeometryPrimitives.ms\" , \"MT_MirrorRig.ms\" , \"MT_EditPivots.ms\" , \"MT_Cluster_attach.ms\" , \"MT_RemoveWingedVerts.ms\" , \"MT_ObjectConformer.ms\" ) "
			setINISetting curfile "Presets" "render"	 				"#( \"MT_TurntableMaker.ms\" , \"MT_TextureResizer.ms\" , \"MT_MaterialsAndWires.ms\" , \"MT_Isolate_A_Light.ms\" , \"MT_ModifierGlobals.ms\" , \"MT_ColorsThinger.ms\" ) "
			setINISetting curfile "Presets" "rigging"	 				"#( \"MT_EditPivots.ms\" , \"MT_MirrorRig.ms\" , \"MT_ControllerTools.ms\" , \"MT_SkinningTools.ms\" , \"MT_PointCacheBatch.ms\" , \"MT_BasicRigs.ms\" ) "
			setINISetting curfile "Presets" "current"	 				"#()"
			setINISetting curfile "Autobak" "posOffset" 				"[0,0]"
		)
		
		return curFile
	),

	function get_modules =
	(
		moduleNames 	 	= #()
		moduleRepository 	= MakeToolbox1.modulesDir
		modules 			= getfiles ( moduleRepository + @"\*.ms" )

		moduleNames = for module in modules collect (substring ( getFilenameFile module ) 4 1000 )
		return moduleNames
	),

	function ScriptLauncher_run =
	(
		global scriptmanager_open
		addModuleToMemory = false
		targetDir = MakeToolbox1.scriptsDir
		filein ( MakeToolbox1.execDir + @"\bin\MakeToolboxScriptmanager.ms" )
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
				lab1.text = ( "Version " + ( MakeToolbox1.version as string ) )
			)

			on btn1 pressed do 
			(
				shelllaunch "http://makevisual.com/brain/index.php?title=Make_Toolbox" ""
			)
		)

		CreateDialog SidebarInfo 200 65
	),

	function UI_SidebarSettings = 
	(
		rollout MakeToolboxSettings ("Make Toolbox Settings v" + (MakeToolbox1.version as string))
		(
			label 		lab_directory "Toolbox Dir:" style_sunkenedge:false	pos:[10,10]
 			label 		lab_directoryShow width:380	style_sunkenedge:true	height:20	pos:[73,8]
			button 		btn_dirOpen "..." pos:[460,8]
			checkbox 	chk_startupToolbox "Launch MAKE Toolbox on Startup" offset:[60,0]
			checkbox 	chk_startupAutobak "Launch MAKE Toolbox Autobak on Startup" offset:[60,0] align:#left

			on MakeToolboxSettings open do
			(
				--try ( lab_directoryShow.text = " no directory found " ) catch ()
				try ( lab_directoryShow.text = " no directory found " ) catch ()
			)
			
			on chk_startupToolbox changed state do 
			(
				setinisetting ( MT_Functions.get_ini() ) "Startup" "startupToolbox" ( state as string )
			)

			on chk_startupAutobak changed state do 
			(
				setinisetting ( MT_Functions.get_ini() ) "Startup" "startupAutobak" ( state as string )
			)

			on btn_dirOpen pressed do 
			(
				shelllaunch MakeToolbox1.execDir ""
			)
		)

 		try( DestroyDialog MakeToolboxSettings ) catch()

		createDialog MakeToolboxSettings 500 80  style:#(#style_titlebar, #style_border, #style_sysmenu,#style_resizing)
		return MakeToolboxSettings
	),

	function UI_SidebarSettings_init = 
	(
		modulesDir 				= MakeToolbox1.modulesDir
		openSidebarOnLaunch 	= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Startup" "startupToolbox" ) )
		openAutobakOnLaunch 	= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Startup" "startupAutobak" ) )

		MakeToolbox1.uiSettings.lab_directoryShow.text 		= ( "  " + MakeToolbox1.execDir )
		MakeToolbox1.uiSettings.chk_startupToolbox.checked 	= openSidebarOnLaunch
		MakeToolbox1.uiSettings.chk_startupAutobak.checked 	= openAutobakOnLaunch
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
		moduleRepository 	= MakeToolbox1.modulesDir
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
 		MakeToolbox.btn_scripts.pos 			= [70,(MakeToolbox.height - 20)]
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
  		modules 	= ( execute ( getinisetting ( MT_Functions.get_ini() ) "Presets" "current" ) )
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
 		MakeToolbox.height				= 250
		MakeToolbox.btn_detach.visible 	= true
		MakeToolbox.btn_attach.visible 	= false

		--try
		--(
			cui.registerdialogbar 	MakeToolbox style:#(#cui_dock_left,#cui_floatable)
			cui.dockdialogbar 		MakeToolbox #cui_dock_left
		--)
		--catch()

		setIniSetting ( MT_Functions.get_ini() ) "Sidebar" "MT_docked" "true"
	),

	function UI_Sidebar_LoadModules arg_modules = -- arg: array of modules to load
	(
		MT_Functions.UI_Sidebar_modulesClear()
		modulePath = MakeToolbox1.modulesDir 

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
				messagebox "Current modules are now automatically saved as your startup layout. \n \nWhen you re-launch the toolbox, it will have the \nsame layout as when you last closed the it."
			)
		)
	),

	function UI_Sidebar =
	(
 		try( cui.UnRegisterDialogBar MakeToolbox )catch()
 		try( DestroyDialog MakeToolbox ) catch()

		-- The Sidebar Rollout
 		rollout MakeToolbox ("Make Toolbox v" + (MakeToolbox1.version as string))
		(
			checkbutton btn_H1 "C" 		height:29 width:29  pos:[0,0] 		checked:true 	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h1.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Common Tools"
			checkbutton btn_H2 "M" 		height:29 width:29 	pos:[(29),0] 	checked:false  	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h2.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Modeling Tools"
			checkbutton btn_H3 "Ri" 	height:29 width:29 	pos:[(29*2),0] 	checked:false  	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h3.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rigging tools"
			checkbutton btn_H4 "A" 		height:29 width:29	pos:[(29*3),0] 	checked:false  	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h4.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Animation Tools"
			checkbutton btn_H5 "Rn" 	height:29 width:29 	pos:[(29*4),0] 	checked:false  	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h5.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Rendering Tools"
			checkbutton btn_H6 "!" 		height:29 width:29 	pos:[(29*5),0] 	checked:false  	border:true 	images:#( ( MakeToolbox1.execDir + @"\bin\images\h6.jpg" ) , ( MakeToolbox1.execDir + @"\images\ha.jpg" ), 4, 2, 1, 3, 4) 		tooltip:"Custom Presets" 
				
			dropdownlist theDrop items:#() height:100 width:150 tooltip:"Select your script from the dropdown." pos:[2,32]
			button clearModules " C" width:19 height:19 tooltip:"Edits the chosen script." pos:[153,33]

			SubRollout 	theSubrollout 		"Subrollout" 	height:940 	width:178 pos:[-2,55]	
			imgtag 		MT_headderCheat 					width:180 	height:2 bitmap:MT_headderCheatBM pos:[-2,27] tooltip: "Rig Nodes and Control Splines"
				
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
				MakeToolbox1.uiSettings = MT_Functions.UI_SidebarSettings()
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
--  		DisableSceneRedraw()

-- 		curGammaSetting 					= IDisplayGamma.colorCorrectionMode

--  		try
--  		(
-- 			IDisplayGamma.colorCorrectionMode 	= #none
			MT_Functions.UI_Sidebar()
			MT_Functions.UI_Sidebar_init()
-- 			IDisplayGamma.colorCorrectionMode 	= curGammaSetting
--  			EnableSceneRedraw()
			
--  		)
--  		catch
--  		(
-- 			IDisplayGamma.colorCorrectionMode 	= curGammaSetting
--  			EnableSceneRedraw()
--  		)
	)
)

MT_Functions.MT_Sidebar_Launch()