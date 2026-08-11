/*
--**********************************************************************************--
--                                                                                  --
--                                SCENE UTILITIES                                   --
--                                                                                  --
--**********************************************************************************--

#NAME: Scene Utilities
#VERSION: 2.4
#LAST UPDATED: 2026.08.11

#DESCRIPTION:
A collection of utilities for scene cleanup and management. Functions include removing 
missing maps, plugins, and note tracks, saving and restoring object names, and 
creating overscan cameras from existing ones.

#INSTRUCTIONS:
Click the desired button to perform an action, such as "Remove Missing Maps" to clean 
the scene, or "Save Name on Selected" to store object names. To create an overscan 
camera, select an existing camera in the scene first.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Scene_Utilities

#CREDITS:
    #Author: Romain Faure (rf.romainfaure@gmail.com)
    #Contributors:
        - Neil Barck: Added features for removing maps/plugins and creating cameras.
        - David Almeida (david.almeida@makevisual.com): Naming convention updates and UI improvements.

#HISTORY:
    - v2.4 (2026.08.11): Updated the Save/Fetch name feature to use a new "MAKE_NodeName" property while maintaining legacy support.
    - v2.3 (2025.09.29): Added tooltips to all UI elements.
    - v2.2 (2025.06.30): Updated the Save/Fetch name feature to use a new "Make_NodeName" property while maintaining legacy support.
    - v2.1 (2011.12.05): Added functions for saving/fetching names and creating overscan cameras.
    - v2.0 (2018.05.01): Added functions for removing missing maps and plugins.
    - v1.0 (2011.03.13): Initial integration into MakeToolbox.

--**********************************************************************************--
*/
SceneUtilitiesModuleVer = 2.4
try(removeSubRollout MakeToolbox.theSubrollout SceneUtilitiesModule)catch()

global SU_plugins_missingClasses
global SU_plugins_missingInstances	

rollout SceneUtilitiesModule ("Scene Utilities v" + (SceneUtilitiesModuleVer as string))
(	
button Btn_RemoveMaps "Remove Missing Maps" width:160 height:20 offset:[0,-3] tooltip:"Removes missing maps from the current scene"
button Btn_RemovePlugins "Remove Missing Plugins" width:160 height:20 offset:[0,-3] tooltip:"Removes missing plugins from the current scene"
button RemoveNoteTrackBtn "Remove NoteTrack" width:160 height:20 offset:[0,-3] tooltip:"Removes note tracks from the objects of the current scene"
label SaveFetch	"Save and Fetch Name"	
button Btn_SaveNameSelected "Save Name on Selected" width:160 height:20 offset:[0,-3] tooltip:"Saves the name of the selected objects on their User Defined properties"
button Btn_FetchNameSelected "Fetch Name on Selected" width:160 height:20 offset:[0,-3] tooltip:"Loads the name of the selected objects from their User Defined properties"
label Lbl_CreateCam	"Overscan Camera"
button Btn_CreateCamera "Create Overscan Camera" width:160 height:20 offset:[-10,-3] tooltip:"Creates new camera from the current selected camera with a larger FOV to overscan the frame"
spinner Spn_OverscanAmount "Overscan Amount:" range:[1,2,1.1] width: 90 offset:[71,0] tooltip:"Sets the amount of overscan to be applied to the new camera"
radiobuttons Rbt_CamType labels:#("Free","Physical")


	fn getMissingPluginInstances =
	(
		missingClasses 				= SU_plugins_missingClasses
		missingInstancesByClass 	= #()
		-- Iterate through the missing classes
		for j = 1 to missingClasses.count do
		(
			currentClass 			= missingClasses[j]
			currentClassInstances 	= getClassInstances currentClass
			-- Iterate through the missing instances of that class
			if currentClassInstances.count > 0 then
			(
				-- Make a new array (missingInstances) with the first object the name of the missing class
				missingInstances = #()
				append missingInstances (missingClasses[j] as string)
				for i = 1 to currentClassInstances.count do
				(
					-- add any instances of the missing plugin to the (missingInstances) array
					myClass = classOf currentClass
					append missingInstances myClass
				) 
				-- add the collected missing instances and name to the missingInstancesByClass array
				append missingInstancesByClass missingInstances
			) 
		) 
		-- Return all the missing instances sorted neatly
		return missingInstancesByClass
	)
	
	
	-- Get Missing plugin classes
	fn getMissingPluginClasses = 
	(
		str = stringStream ""
		apropos "*missing*" to:str
		seek str 0
		missingClasses = #()
		while not (eof str) do
		(
			ln = readLine str
			tk = filterString ln " "
			if tk.count == 4 then (
				clsName = tk[1]
				try
				(
					val = (execute clsName)
					sc = superClassOf val
					if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then
					(
						append missingClasses val
					)
					else ()
				)
				catch ()
			)
			else ()
		)
		return missingClasses
	)
	
	fn collectMissingPluginInstances = 
	(
		SU_plugins_missingClasses		= getMissingPluginClasses()
		SU_plugins_missingInstances		= getMissingPluginInstances()
	)

	fn replaceMissingPlugins = 
	(
		str = stringStream ""
		apropos "*missing*" to:str
		seek str 0
		cls = #()
		while not (eof str) do (
			ln = readLine str
			tk = filterString ln " "
			if tk.count == 4 then (
				clsName = tk[1]
				try (
					val = (execute clsName)
					sc = superClassOf val
					if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then (
						append cls val
					) else ()
				) catch ()
			) else ()
		)
		c = 0
		foundMissing = #()
		for j = 1 to cls.count do (
			cc = cls[j]
			ci = getClassInstances cc
			if ci.count > 0 then (
				for i = 1 to ci.count do (
					myClass = classOf cc
					append foundMissing myClass
					allClasses = myClass.classes
					for k = 1 to allClasses.count do (
						if allClasses[k].creatable then (
							newInst = createInstance allClasses[k]
							try (
								q = replaceInstances ci[i] newInst
								c += 1
								exit
							) catch ()
						)
					)
				)
			)
		) 
	)

	fn replaceMissingPluginsPrompt = 
	(
		message = ( "Permanently remove [ " + ( SU_plugins_missingInstances.count as string ) + " ] plugins? \n\nThis cannot be undone, and it is strongly \nreccomended to increment your scene file." )
		result = yesNoCancelBox message 
		if result == #yes then
		(
			replaceMissingPlugins()
		)else()
	)

	on RemoveNoteTrackBtn pressed do
	(
		trackIndex = 1

		m = trackViewNodes[trackIndex]
		while (m != undefined) do
		(
			print trackIndex
			ct = numNoteTracks m
			id = ct
			for i = 1 to ct do
			(
				tr = getNoteTrack m id		
				deleteNoteTrack m tr
				id = id - 1
				ith = mod i 200
				if  ith  < 1 then Print id
			)
			trackIndex = trackIndex + 1
			m = trackViewNodes[trackIndex]
		)
	)

	on Btn_RemoveMaps pressed do
	(
		ATSOps.CheckNetworkPaths = true -- Turns on status checking for network filepaths 
		atsops.Refresh() -- Updates Asset Tracker
		ATSOps.GetFilesByFileSystemStatus #Missing &nullList -- Builds list of assets with "Missing" Status in Asset Tracker
		if nullList.count > 0 do
		(	
			mList = #()
			for i = 1 to nullList.count do
			(
				append mList #(pathConfig.stripPathToLeaf nullList[i], nullList[i]) -- Builds sub array and appends to output array
			)
		)
		if nullList.count == 0 then
		(
			messageBox "No missing bitmaps were found" 		
		)
		if nullList.count > 0 then
		(
			message = ( "Permanently remove [ " + ( nullList.count as string ) + " ] unlinked bitmaps? \n\nThis cannot be undone, and it is strongly \nreccomended to increment your scene file." )
			result = yesNoCancelBox message 
			if result == #yes then
			(
				actionMan.executeAction -841213575 "23"
			)
			else()
		)

	)

	on Btn_RemovePlugins pressed do
	(
		collectMissingPluginInstances()
		replaceMissingPluginsPrompt()
	)

	on Btn_SaveNameSelected pressed do
	(
		curObjs = selection as array
		for curObj in curObjs do
		(
			-- Checks if the node is using the legacy "AssetName on its UserProperties, and deletes it if true"
			if (doesUserPropExist curObj "AssetName") do
			(
				deleteUserProp curObj "AssetName"
			)
			setUserProp curObj "MAKE_NodeName" curObj.name
		)
	)

	on Btn_FetchNameSelected pressed do

	(
		curObjs = selection as array
		for curObj in curObjs do
		(
			-- Checks if the node is using the legacy "AssetName on its UserProperties, changes it to the new "MAKE_NodeName", and deletes the legacy one"
			if (doesUserPropExist curObj "AssetName") OR (doesUserPropExist curObj "Make_NodeName") do
			(
				setUserProp curObj "MAKE_NodeName" (getUserProp curObj "AssetName")
				if (doesUserPropExist curObj "AssetName") then
				(
					deleteUserProp curObj "AssetName"
				)
				else
				(
					deleteUserProp curObj "Make_NodeName"
				)
			)
			try ( curObj.name = ( getUserProp curObj "MAKE_NodeName" ) )
			catch ( print ( "error: no stored name on " + curObj.name ) )
		)
	)

	on Btn_CreateCamera pressed do

	(

		overscanAmmount = Spn_OverscanAmount.value

		if superClassOf $ == camera then
		(

			
			cam_original 				= $
			if Rbt_CamType.state == 1 then
			(
				cam_overscan 			= Freecamera name: ( cam_original.name + "_Overscan")
				cam_overscan.transform = cam_original.transform
				cam_overscan.parent = cam_original
			)
			if Rbt_CamType.state == 2 then
			(
				cam_overscan = Physical targeted:off name: ( cam_original.name + "_Overscan")
				cam_overscan.transform = cam_original.transform
				cam_overscan.parent = cam_original
				cam_overscan.specify_fov = true
			)

			
			cam_original.layer.addnode cam_overscan
			
			cam_original.name 		= ( cam_original.name + "_Original")
			
			if Rbt_CamType.state == 1 then
			(
				cam_overscan.mpassEnabled = false
			)
			
			cam_overscan.fov 		= ( cam_original.fov * overscanAmmount )

			
		)
	)


)
AddSubRollout MakeToolbox.theSubrollout SceneUtilitiesModule

