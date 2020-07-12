/*
#NAME:Scene Utilities
#VERSION:2.1.0
#INSTRUCTIONS:
Remove note tracks from scene file
http://www.makevisual.com/learning/MT_SceneUtilities.htm
#SOURCE:rf.romainfaure@gmail.com
#HISTORY:03.13.2011 >> Add to MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by rf.romainfaure@gmail.com
-- Modified by Neil Barck
--*****************************************************
-- HISTORY:
--- version 1.00  : 03.13.2011 >> Add to MakeToolBox
--- version 2.0.0 : 5.1.2018 >> Added fuctions and ui for removing missings maps and plugins - NB
--- version 2.1.0 : 12.5.2011 >> Added funcions for save/fetch name and creating overscan camera - NB
--*****************************************************
SceneUtilitiesModuleVer = ""
try(removeSubRollout MakeToolbox.theSubrollout SceneUtilitiesModule)catch()

global SU_plugins_missingClasses
global SU_plugins_missingInstances	

rollout SceneUtilitiesModule ("Scene Utilities" + (SceneUtilitiesModuleVer as string))
(	
button Btn_RemoveMaps "Remove Missing Maps" width:160 height:20 offset:[0,-3]
button Btn_RemovePlugins "Remove Missing Plugins" width:160 height:20 offset:[0,-3]
button RemoveNoteTrackBtn "Remove NoteTrack" width:160 height:20 offset:[0,-3]
label SaveFetch	"Save and Fetch Name"	
button Btn_SaveNameSelected "Save Name on Selected" width:160 height:20 offset:[0,-3]
button Btn_FetchNameSelected "Fetch Name on Selected" width:160 height:20 offset:[0,-3]
label Lbl_CreateCam	"Overscan Camera"
button Btn_CreateCamera "Create Overscan Camera" width:160 height:20 offset:[-10,-3]
spinner Spn_OverscanAmount "Overscan Amount:" range:[1,2,1.1] width: 90 offset:[71,0]
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
			-- print trackIndex
			ct = numNoteTracks m
			id = ct
			for i = 1 to ct do
			(
				tr = getNoteTrack m id		
				deleteNoteTrack m tr
				id = id - 1
				ith = mod i 200
				-- if  ith  < 1 then Print id
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
		for curObj in curObjs do (	setUserProp curObj "AssetName" curObj.name )
	)

	on Btn_FetchNameSelected pressed do

	(
		curObjs = selection as array
		for curObj in curObjs do ( try ( curObj.name = ( getUserProp curObj "AssetName" ) )	catch ( print ( "error: no stored name on " + curObj.name ) ) )
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

