/*
#NAME: PointCacheBatchV2
#VERSION:1.0
#SOURCE:David Almeida, david.almeida@makevisual.com
#HISTORY:03.04.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by David Almeida
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.03.2025 >> Start Development
--*****************************************************
PointCacheV2ToolModule = "2.0"
try(removeSubRollout MakeToolbox.theSubrollout PointCacheBatch)catch()

-- creates the UI
rollout PointCacheBatch ("PointCacheBatch v" + (PointCacheV2ToolModule as string))
(
	local
	-- Variable to store the default and previous Folder Name entry text.
	DefaultFolderName = "FolderName",
	-- Variable to store the starting Versioned Folder Name entry text.
	DefaultFolderVersionName = (@"\" + DefaultFolderName + "_v001"),
	-- Variable to store the invalid characters for the Folder Name entry text.
	InvalidCharacters = @"\/|?;:.>,<~^´`'!=+*",
	-- Array to store the objects that a point cache was not created/loaded.
	SkippedObjs = #(),
	-- The current folder directory where the caches will be saved/loaded from
	CurrentDir = undefined,
	-- The root folder directory where the local cache folder will be created on
	CacheRootFolder = undefined,
	-- The root folder directory where subfolders with the caches will be saved/loaded from
	CacheLocalFolder = undefined,
	-- Variable to store the Skin Modifier Stack position on the selected object
	SkinModIndex = undefined,
	-- Variable to store if Skin Modifier is enabled on the selected object
	SkinModEnabled = undefined,
	-- Variable to store the Point Cache Modifier Stack position on the selected object
	PointCacheIndex = undefined,
	-- Variable to store the current Point Cache Modifier being worked on by the script
	CurrentPointCache = undefined,
	-- Variable to store the selected Point Cache file format
	FileExtension = ".pc2"
	group "Point Cache Batch"
	(
		button MakeCacheButton "Create Cache" width:149 height:26 tooltip:"Creates the point cache for the selected objects" enabled:false
		button LoadCacheButton "Load Cache" width:149 height:26 offset:[0,-3] tooltip:"Loads the point cache for the selected objects" enabled:false
		checkbox BruteForceCheckBox "Brute Force Caching" checked:true offset:[-7,-2] tooltip:"Brute forces the point cache by adding a little turbulence to the geometry to trigger the caching algorithm"
		progressbar PointCacheProgBar "" height:10 width:149 offset:[-5,0] color:(color 28 149 177)
		label ProgressLabel "" offset:[0,-17]
		label CurrentStatusLbl "Ready"
		label CurrentOperationLbl "..."
	)
	group "Cache Root Folder" 
	(
		button RootFolderButton "Select Root Folder" width:131 offset:[12,0] tooltip:"Click to select the root of the cached files" across:2
		button RootFolderOpenButton "..." width:21 height:21 enabled:false offset:[32,0] tooltip:"Opens current root folder in Explorer"
		checkbox CreateSubFoldersCheckBox "Create folders from layers" checked:true offset:[-7,0] tooltip:"Creates subfolders based on the layer name of each object" 
	)
	groupBox VersioningGroupBox "" width:158 height:85 offset:[-10,0]
		checkbox EnableVersioningCheckbox "Enable versioning" checked:true offset:[-7,-93] enabled:false tooltip:"Enables or disables version control on the created/loaded caches. Recommended to be always enabled."
		edittext FolderVersionNameEditText "" text:DefaultFolderName height:20 multiLine:false enabled:false tooltip:"Cache folder version name."
		spinner CurrentVersionSpinner "Version:" range:[1,999,1] width:80 type:#integer offset:[10,0] enabled:false across:2 tooltip:"Cache version number."
		button UpdateVersionButton "Create" height:20 offset:[8,-2] enabled:false tooltip:"Creates the local versioned cache folder. If the folder does not exist, its name will be trailed by *"
		label FolderVersionNameLabel DefaultFolderVersionName enabled:false

	groupBox FrameRangeGroupBox "Frame Range" width:158 height:62 offset:[-10,7]
		spinner framesStartSpinner range:[-99999,99999,0] width:60 type:#integer offset:[-11,-50] across:3
		label SpinnerToLabel "to" offset:[2,-50]
		spinner framesEndSpinner range:[-99999,99999,100] width:60 type:#integer offset:[-11,-50]
		button timeSnap "Snap to Timeline" width: 151 height:20 tooltip:"Set the current timeline start frame and end frame."
	
	groupBox CacheOptionsGroupBox "Cache Options" width:158 height:62 offset:[-10,4]
		spinner SamplesFrameSpinner "Samples/frame:" height:20 range:[1,999,1] width:90 type:#integer offset:[45,-50] tooltip:"Number of caching samples for each frame."
		checkbox PC2FileCheckButton ".pc2" checked:true offset:[8,0] tooltip:"Select cache file format" across:2
		checkbox XMLFileCheckButton ".xml" checked:false offset:[15,0] tooltip:"Select cache file format"
	
	groupBox IfCacheExistsGroupBox "If Cache Exists" width:158 height:45 offset:[-10,4]
		checkbox CacheReplaceCheckButton "Replace" checked:true offset:[8,-30] tooltip:"Select replace or skip existing cache files" across:2
		checkbox CacheSkipCheckButton "Skip" checked:false offset:[15,-30] tooltip:"Select replace or skip existing cache files"
	
	groupBox UtilitiesGroupBox "Utilities" width:158 height:88 offset:[-10,10]
		button AddPointCacheButton "Add Point Cache Modifer" width:151 offset:[0,-76] tooltip:"Adds a point cache modifier (if not present) on selected objects above the skin modifier"
		button TurnOnCacheButton "Cache On" width:76 offset:[-3,-3] tooltip:"Enables point cache modifiers on selected objects" across:2
		button TurnOffCacheButton "Cache Off" width:76 offset:[3,-3] tooltip:"Disables point cache modifiers on selected objects"
		button TurnOnSkinButton "Skin On" width:76 offset:[-2,-3] tooltip:"Enables skin modifiers on objects with point cache modifiers" across:2
		button TurnOffSkinButton "Skin Off" width:76 offset:[4,-3] tooltip:"Disables skin modifiers on objects with point cache modifiers"
	
	-- Function: Load_or_Create_PointCache_FN
	-- Description: Loads or creates a point cache for the specified object based on the LoadPointCache flag. Configures cache parameters such as filename, frame range, and sample rate.
	-- Parameters:
	--   CurrentNode: The 3ds Max node (object) to process.
	--   PointCacheMod: The Point Cache modifier to configure and operate on.
	--   FilePath: String path where the cache will be saved or loaded from.
	--   LoadPointCache: Boolean flag (true for loading a cache, false for creating a new cache).
	-- Return Value: None
	-- Notes: Assumes the cache directory exists or can be created. Sets the cache to pre-load in RAM (loadtype = 2). Updates the UI to reflect the current operation.
	function Load_or_Create_PointCache_FN CurrentNode PointCacheMod FilePath LoadPointCache =
	(
		makeDir CurrentDir
		PointCacheMod.fileName = FilePath
		PointCacheMod.recordStart = framesStartSpinner.value
		PointCacheMod.recordEnd = framesEndSpinner.value
		PointCacheMod.sampleRate = 1.0/SamplesFrameSpinner.value
		CurrentOperationLbl.text = (CurrentNode.name)
		if (NOT LoadPointCache) do
		(
			cacheOps.RecordCache PointCacheMod
		)
		PointCacheMod.loadtype = 2
		PointCacheMod.loadTypeNetwork = 2
	)
	-- Function: AddSet_PointCacheMod_Above_SkinMod_FN
	-- Description: Adds a Point Cache modifier to the specified node if it doesn’t exist, or sets the existing one as the current modifier for further operations. Places 
	-- the modifier above the Skin modifier in the stack.
	-- Parameters:
	--   CurrentNode: The 3ds Max node (object) to modify.
	-- Return Value: None
	-- Notes: Relies on the variable SkinModIndex to determine the position. Updates the CurrentPointCache variable.
	function AddSet_PointCacheMod_Above_SkinMod_FN CurrentNode =
	(
		if PointCacheIndex == undefined then
		(
			CurrentPointCache = Point_Cache()
			addModifier CurrentNode CurrentPointCache before:(SkinModIndex - 1)
		)
		else
		(
			CurrentPointCache = CurrentNode.modifiers[PointCacheIndex]
		)
	)
	-- Function: SkinMod_PointCacheMod_IndexerFN
	-- Description: Searches the modifier stack of the specified node for Skin and Point Cache modifiers, storing their stack positions and the Skin modifier’s enabled state in variables.
	-- Parameters:
	--   CurrentNode: The 3ds Max node (object) whose modifier stack to analyze.
	-- Return Value: None
	-- Notes: Updates variables SkinModIndex, SkinModEnabled, and PointCacheIndex. Assumes the node has a valid modifier stack.
	function SkinMod_PointCacheMod_IndexerFN CurrentNode = 
	(
		-- Loops through all modifiers of each selected object
		SkinModIndex = undefined
		SkinModEnabled = undefined
		PointCacheIndex = undefined
		for j = CurrentNode.modifiers.count to 1 by -1 do
		(
			CurrentMod = CurrentNode.modifiers[j]
			if ((classof CurrentMod) == Skin) then
			(
				SkinModIndex = j
				if (CurrentMod.enabled) then
				(
					SkinModEnabled = true
				)
				else
				(
					SkinModEnabled = false
				)
			)
			if (classof CurrentMod) == Point_Cache then
			(
				PointCacheIndex = j
			)
		)
	)
	-- Function: PointCache_SetupFN
	-- Description: Sets up and processes selected objects for either creating or loading point caches, handling UI updates, error checking, and progress tracking.
	-- Parameters:
	--   LoadCacheFlag: Boolean flag (true to load caches, false to create caches).
	-- Return Value: None
	-- Notes: Uses variables like CacheLocalFolder, SkippedObjs, and UI elements. Includes a "brute force" hack with a noise modifier if enabled. Provides user feedback via progress bar and labels.
	function PointCache_SetupFN LoadCacheFlag =
	(
		clearListener()
		if selection.count != 0 then
		(
			if LoadCacheFlag then
			(
				-- This sets the label of the Status Label to display the current operation, in this case when loading caches.
				CurrentStatusLbl.text = "Loading"
			)
			else
			(
				-- Creates a noise modifier to be applied to the animated objects : THIS IS A HACK TO BRUTEFORCE THE CACHING. An error report was submitted to Max devs.
				BruteForceNoise = Noisemodifier animate:true strength:[0.0001,0,0]

				-- This sets the label of the Status Label to display the current operation, in this case when creating caches.
				CurrentStatusLbl.text = "Caching"
			)

			-- Creates an empty array to collect the objects that were skipped while creating or loading caches.
			SkippedObjs = #()

			-- Resets the progress bar.
			PointCacheProgBar.color = (color 28 149 177)
			PointCacheProgBar.value = 0
			ProgressBarIndex = 0
			ProgressBarMaxValue = selection.count

			-- Loops through all selected objects
			for i in selection do
			(
				ProgressBarIndex += 1

				-- This routine sets the folder where caches will be created on or loaded from, taking into account if the user wants to use the current layer the object is in
				-- as name for a subfolder to be created under the selected root folder.
				if CreateSubFoldersCheckBox.checked then
				(
					CurrentDir = (CacheLocalFolder + "\\" + (i.layer.name))
				)
				else
				(
					CurrentDir = CacheLocalFolder
				)

				-- Calls the function to grab the Stack's index and status (if enabled or disabled) of the Skin modifier (if present) and the Stack's index of the 
				-- Point Cache modifier (if present).
				SkinMod_PointCacheMod_IndexerFN i

				-- This routine serves to catch, collect and print any object that does not have a Skin modifier applied to it based on the collected Skin modifier's
				-- index captured on the SkinMod_PointCacheMod_IndexerFN function just above.
				if SkinModIndex == undefined then
				(
					append SkippedObjs i
					if LoadCacheFlag then
					(
						print  ("SKIN MODIFIER NOT FOUND, SKIPPING LOAD CACHE ON -> " + (i.name) )
					)
					else
					(
						print  ("SKIN MODIFIER NOT FOUND, SKIPPING CACHING ON -> " + (i.name))
					)
				)
				else
				(
					CurrentFilePath = (CurrentDir + "\\" + i.name + FileExtension)

					-- This routine is called if a Skin modifier is applied to the current object. It will check if a cache file for the current object exists on the
					-- CurrentFilePath variable (in the case the user wants to load a cache file) OR if the LoadCacheFlag is NOT TRUE (essentially checking if the user
					-- is trying to create a cache file). Under these conditions, if a cache file is NOT found, and the user is trying to LOAD a cache (LoadCacheFlag is true)
					-- the test will fail. It will always succed if the user is trying to create a cache (LoadCacheFlag is false) or if the cache exists.
					if (doesFileExist CurrentFilePath) OR (NOT LoadCacheFlag) then
					(

						-- Calls the function to Add a Point Cache modifier (if it does not exist) or Set the existing Point Cache modifier as the Current Point Cache mod the 
						-- script will operate on
						AddSet_PointCacheMod_Above_SkinMod_FN i

						-- This routine will check if the detected Skin modifier is enabled on the selected object. If the Skin mod is disabled, it will further check if the
						-- user is loading a cache - if the LoadCacheFlag is TRUE, it will proceed to load the cache. If the user is trying to create a cache with the skin mod
						-- turned OFF, it will catch, collect and print the current object to the listener.
						if SkinModEnabled then
						(

							-- This routine checks if Brute Force mode is enabled (HACK!). If yes, it will add an animated Noise modifier just before the Skin modifier, proceed
							-- to call the caching function, and then delete the Noise modifier. THIS IS A HACK AND SHOULD BE REMOVED ONCE THE POINT CACHE MODIFIER IS FIXED!
							if BruteForceCheckBox.checked AND (NOT LoadCacheFlag) then 
							(
								addModifier i BruteForceNoise before:(SkinModIndex)
								Load_or_Create_PointCache_FN i CurrentPointCache CurrentFilePath LoadCacheFlag
								deleteModifier i (SkinModIndex + 1)
							)
							else
							(
								Load_or_Create_PointCache_FN i CurrentPointCache CurrentFilePath LoadCacheFlag
							)
						)
						else
						(

							-- This routine will be executed if a Skin mod is present BUT is disabled. If the user is trying to load a cache it will call the function to do so.
							-- If not, it will throw an error on the listener after collecting the current object
							if LoadCacheFlag then
							(
								Load_or_Create_PointCache_FN i CurrentPointCache CurrentFilePath LoadCacheFlag
							)
							else
							(
								append SkippedObjs i
								print  ("SKIN MODIFIER DISABLED, SKIPPING CACHING ON -> " + (i.name) )
							)
						)
					)
					else
					(
						append SkippedObjs i
						print  ("CACHE FILE WASN'T FOUND, SKIPPING LOAD CACHE ON -> " + (i.name) )
					)
				)

				-- Updates the progress bar and its label at the end of the current object iteration.
				PointCacheProgBar.value = 100.0*ProgressBarIndex/ProgressBarMaxValue
				ProgressLabel.text = ((PointCacheProgBar.value as string) + "%")
			)

			-- This routine is called after all objects have been processed either to create or load the caches. It will update the status label, the progress bar label and color,
			-- and will warn the user in the case any objects were skipped the caching/loading procedure and point them to the listener so they can troubleshoot their objects.
			if SkippedObjs.count == 0 then
			(
				CurrentStatusLbl.text = "Done"
				CurrentOperationLbl.text = "No errors found"
				if LoadCacheFlag then
				(
					CurrentOperationLbl.tooltip = "All caches succesfully loaded on selected objects."
				)
				else
				(
					CurrentOperationLbl.tooltip = "All selected objects succesfully cached."
				)
				PointCacheProgBar.color = green
				ProgressLabel.text = ""
			)
			else
			(
				CurrentStatusLbl.text = ((SkippedObjs.count as string) + " objects skipped")
				CurrentOperationLbl.text = "Check the listener"
				CurrentOperationLbl.tooltip = "Some objects were skipped, check the listener."
				PointCacheProgBar.color = yellow
				ProgressLabel.text = ""
			)
		)
		else
		(
			if LoadCacheFlag then
			(
				messageBox "Select one or more objects to load the point cache(s)"
			)
			else
			(
				messageBox "Select one or more objects to point cache"
			)
		)
	)
	-- Function: ModifierOnOffFN
	-- Description: Enables or disables a specific type of modifier on all selected objects based on the provided switch.
	-- Parameters:
	--   Switch: Boolean value (true to enable, false to disable the modifier).
	--   ClassOfMod: The class of the modifier to toggle (e.g., Point_Cache, Skin).
	-- Return Value: None
	-- Notes: Updates the modifier’s enabled state and notifies dependents. Assumes at least one object is selected and modifiers exist.
	function ModifierOnOffFN Switch ClassOfMod =
	(
		if selection.count != 0 do
		(
			for i in selection do
			(
				for CurrentModifier in i.modifiers do
				(
					if (classof CurrentModifier) == ClassOfMod do
					(
						CurrentModifier.enabled = Switch
						notifydependents CurrentModifier partid:0 msg:0x0211
					)
				)
			)
		)
	)
	function Check_Folder_VersionFN =
	(
		if EnableVersioningCheckbox.checked then
		(
			FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = true
			FolderVersionNameLabel.text = (@"\" + FolderVersionNameEditText.text + "_v" + (formattedPrint CurrentVersionSpinner.value format:"03d"))
			CacheLocalFolder = (CacheRootFolder + FolderVersionNameLabel.text)
		)
		else
		(
			FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = false
			CacheLocalFolder = CacheRootFolder
		)
		if (getDirectories (CacheLocalFolder)).count == 0 then
		(
			FolderVersionNameLabel.text += "*"
			CacheLocalFolder = undefined
			MakeCacheButton.enabled = LoadCacheButton.enabled = false
			CurrentOperationLbl.text = "Folder version not found"
			CurrentOperationLbl.tooltip = "The current folder version was not found. Check the Cache Root Folder path or press the Create button on the Enable Versioning section to create the current Folder version."
		)
		else
		(
			CacheLocalFolder = (CacheRootFolder + FolderVersionNameLabel.text)
			MakeCacheButton.enabled = LoadCacheButton.enabled = true
			CurrentOperationLbl.text = "..."
			CurrentOperationLbl.tooltip = ""
		)
	)




	on MakeCacheButton pressed do
	(
		if CacheLocalFolder != undefined then
		(
			PointCache_SetupFN false
		)
		else
		(
			messageBox "Select a folder to store the cache files"
		)
	)
	on LoadCacheButton pressed do
	(
		if CacheLocalFolder != undefined then
		(
			PointCache_SetupFN true
		)
		else
		(
			messageBox "Select a folder to load the cache files from"
		)
	)
	on RootFolderButton pressed do
	(
		if CacheRootFolder == undefined then
		(
			CacheRootFolder = getSavePath initialDir:(pathConfig.getCurrentProjectFolder())
		)
		else
		(
			PrevCacheRootFolder = CacheRootFolder
			CacheRootFolder = getSavePath initialDir:(CacheRootFolder)
			-- This routine is needed because if the user hits CANCEL on the "Choose a folder" window, the script will revert to the last saved path
			if CacheRootFolder == undefined do
			(
				CacheRootFolder = PrevCacheRootFolder
			)
		)
		if CacheRootFolder != undefined do
		(
			EnableVersioningCheckbox.enabled = true
			Check_Folder_VersionFN()
			if CacheRootFolder.count > 16 then
			(
				RootFolderButton.text = @"" + (substring CacheRootFolder 1 3) + "..." + (substring CacheRootFolder (CacheRootFolder.count - 15) (25))
				if CacheRootFolder.count > 40 then
				(
					RootFolderButtonTooltipString = ""
					CharCounter = 0
					for i = 1 to CacheRootFolder.count do
					(
						CharCounter += 1
						if CacheRootFolder[i] == "\\" then
						(
							if CharCounter > 30 then
							(
								CharCounter = 0
								RootFolderButtonTooltipString = RootFolderButtonTooltipString + "\\" + "\n"
							)
							else
							(
							RootFolderButtonTooltipString = RootFolderButtonTooltipString + "\\"
							)
						)
						else
						(
							RootFolderButtonTooltipString += CacheRootFolder[i]
						)
					)
					RootFolderButton.tooltip = RootFolderButtonTooltipString
				)
				else
				(
					RootFolderButton.tooltip = CacheRootFolder
				)
			)
			else
			(
				RootFolderButton.text = CacheRootFolder
				RootFolderButton.tooltip = CacheRootFolder
			)
			RootFolderOpenButton.enabled = true
		)
	)
	on RootFolderOpenButton pressed do
	(
		shellLaunch "explorer.exe" CacheRootFolder
	)
	on EnableVersioningCheckbox changed val do
	(
		FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = val
		Check_Folder_VersionFN()
	)
	on FolderVersionNameEditText entered val do
	(
		if val == "" then
		(
			messageBox "Invalid folder name"
			FolderVersionNameEditText.text = DefaultFolderName
		)
		else
		(
			InvalidCharFlag = false
			for i = 1 to val.count do
			(
				CurrentCharacter = val[i]
				for j = 1 to InvalidCharacters.count do
				(
					CurrentInvalidCharacter = InvalidCharacters[j]
					if CurrentInvalidCharacter == CurrentCharacter do
					(
						InvalidCharFlag = true
					)
				)
			)
			if InvalidCharFlag then
			(
				messageBox "Invalid folder name"
				FolderVersionNameEditText.text = DefaultFolderName
			)
			else
			(
				Check_Folder_VersionFN()
			)
		)
		DefaultFolderName = FolderVersionNameEditText.text
	)
	on CurrentVersionSpinner changed val do
	(
		Check_Folder_VersionFN()
	)

	on UpdateVersionButton pressed do
	(
		--makeDir 
		NewCacheFolder = (CacheRootFolder + FolderVersionNameLabel.text)
		if NewCacheFolder[NewCacheFolder.count] == "*" do
		(
			CacheLocalFolder = (substring NewCacheFolder 1 (NewCacheFolder.count - 1))
			makeDir CacheLocalFolder
			Check_Folder_VersionFN()
		)
	)


	on timeSnap pressed do
	(
		framesStartSpinner.value = animationrange.start
		framesEndSpinner.value = animationrange.end
	)
	on XMLFileCheckButton changed state do
	(
		FileExtension = ".xml"
		XMLFileCheckButton.checked = true
		PC2FileCheckButton.checked = false
	)
	on PC2FileCheckButton changed state do
	(
		FileExtension = ".pc2"
		XMLFileCheckButton.checked = false
		PC2FileCheckButton.checked = true
	)
	on CacheReplaceCheckButton changed state do
	(
		CacheReplaceCheckButton.checked = true
		CacheSkipCheckButton.checked = false
	)
	on CacheSkipCheckButton changed state do
	(
		CacheReplaceCheckButton.checked = false
		CacheSkipCheckButton.checked = true
	)
	on AddPointCacheButton pressed do
	(
		if selection.count != 0 then
		(
			for i in selection do
			(
				SkinMod_PointCacheMod_IndexerFN i
				AddSet_PointCacheMod_Above_SkinMod_FN i
			)
		)
		else
		(
			messageBox "Select one or more objects to add a point cache modifier above the skin modifier"
		)
	)
	on TurnOnCacheButton pressed do
	(
		ModifierOnOffFN true Point_Cache
	)
	on TurnOffCacheButton pressed do
	(
		ModifierOnOffFN false Point_Cache
	)
	on TurnOnSkinButton pressed do
	(
		ModifierOnOffFN true Skin
	)
	on TurnOffSkinButton pressed do
	(
		ModifierOnOffFN false Skin
	)
	on PointCacheBatch open do
	(
		framesStartSpinner.value = animationrange.start
		framesEndSpinner.value = animationrange.end
		--UpdateVersionButton.images = (color 255 0 0)
	)
)

AddSubRollout MakeToolbox.theSubrollout PointCacheBatch