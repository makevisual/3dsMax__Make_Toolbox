/*
--**********************************************************************************--
--                                                                                  --
--                              POINT CACHE BATCH                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Point Cache Batch
#VERSION: 2.00.3
#LAST UPDATED: 2026.08.11

#DESCRIPTION:
A tool for batch creating and loading Point Cache files for selected objects, 
designed for skinned meshes and TyMesher objects. It provides a comprehensive UI 
for managing cache paths, versioning, frame ranges, and other modifier settings.

#INSTRUCTIONS:
Select a root folder for your caches. Select the objects you want to process.
Configure the frame range, versioning, and other options. Click 'Create Cache' 
to bake new caches or 'Load Cache' to apply existing ones.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Point_Cache_Batch

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com): Original script and early versions.
    #Contributors:
        - Neil Barck: Additional features.
        - David Almeida (david.almeida@makevisual.com): Major rewrite, new features, bugfixes and UI updates.

#HISTORY:
    - v2.00.3 (2026.08.11): Changed "Save/load from layers" and "Enable versioning" to be OFF by default.
    - v2.00.2 (2026.01.06): Added support for tySpliner objects so animated splines are supported in caching and loading operations.
    - v2.00.1 (2025.05.09): Added support for TyMesher objects and loading caches without a skin modifier.
    - v2.00.0 (2025.03.03): Major rewrite: removed globals, added status bar, layer-based subfolders, version control, and utility buttons.
    - v1.11.2 (2022.02.14): Fixed file writing bug in newer 3ds Max versions.
    - v1.11.1 (2018.04.30): Added UI for selecting .xml or .pc2 file types.
    - v1.11.0 (2017.03.24): Added WSM support, auto-detection of cache versions, and converted to .pc2 format.
    - v1.10.1 (2016.02.18): General settings improvements.
    - v1.09.1 (2016.02.18): Improved global scope names.
    - v1.09.1 (2015.09.22): Performance optimizations.
    - v1.09.0 (2015.09.22): Added toggle for Match Geo modifier.
    - v1.08.0 (2015.09.22): Added 4 samples per frame override.
    - v1.07.0 (2015.09.22): Added safety pre-cache calculation for jiggle modifier.
    - v1.05.0 (2014.10.30): Added automatic enabling of point cache before caching.
    - v1.04.0 (2014.01.08): Added auto-setup of point cache modifier on selection.
    - v1.03.0 (2013.09.11): Fixed progress bar bugs.
    - v1.02.0 (2013.09.11): Added toggle for cache modifiers.
    - v1.01.0 (2013.06.18): Added batch path setting.
    - v1.00.0 (2013.06.07): Initial release.

--**********************************************************************************--
*/
PointCacheBatchToolModule = "2.00.3"
try(removeSubRollout MakeToolbox.theSubrollout PointCacheBatch)catch()

-- Rollout: PointCacheBatch
-- Description: Defines the UI for the PointCacheBatchV2 tool, allowing users to create/load point caches, configure cache settings, manage versioning, and toggle modifiers on selected objects. 
-- Organized into groups for cache operations, folder selection, frame range, cache options, and utilities.
-- Notes: Integrated as a sub-rollout in the MakeToolbox. UI elements are disabled by default until a valid root cache folder is selected.
rollout PointCacheBatch ("PointCacheBatch v" + (PointCacheBatchToolModule as string))
(
	local
	-- Variable to store the default and also the previous Folder Name entry text, so in case the user tries to enter an invalid name, the script can rever back to the previous valid name.
	DefaultFolderName = "FolderName",
	-- Variable to store the starting Versioned Folder Name entry text.
	DefaultFolderVersionName = (@"\" + DefaultFolderName + "_v001"),
	-- Variable to store the invalid characters for the Folder Name entry text.
	InvalidCharacters = "\/|?;:.>,<~^´`'\"!=@+*#%&${}[]()",
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
		label CurrentOperationLbl "Select a root folder"
	)
	group "Cache Root Folder" 
	(
		button RootFolderButton "Select Root Folder" width:131 offset:[12,0] tooltip:"Click to select the root of the cached files" across:2
		button RootFolderOpenButton "..." width:21 height:21 enabled:false offset:[32,0] tooltip:"Opens current root folder in Explorer"
		checkbox CreateSubFoldersCheckBox "Save/load from layers" checked:false offset:[-7,0] tooltip:"Uses subfolders created based on scene layer names for saving and loading caches." 
	)
	groupBox VersioningGroupBox "" width:158 height:85 offset:[-10,0]
		checkbox EnableVersioningCheckbox "Enable versioning" checked:false offset:[-7,-93] enabled:false tooltip:"Enables or disables version control on the created/loaded caches. Recommended to be always enabled."
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
		try
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
		catch
		(
			--catches any errors
			messagebox "Unexpected error, please try again."	
		)
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
		SkinModEnabled = false
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
			if ((classof CurrentNode.baseobject) == tyMesher) OR ((classof CurrentNode.baseobject) == tySpliner) then
			(
				SkinModIndex = CurrentNode.modifiers.count
				SkinModEnabled = true
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
				if (SkinModIndex == undefined) AND (NOT LoadCacheFlag) then
				(
					append SkippedObjs i
					print  ("SKIN MODIFIER NOT FOUND, SKIPPING CACHING ON -> " + (i.name))
				)
				else
				(
					CurrentFilePath = (CurrentDir + "\\" + i.name + FileExtension)
					-- This routine is called if a Skin modifier is applied to the current object. It will check if a cache file for the current object exists on the
					-- CurrentFilePath variable (in the case the user wants to load a cache file) OR if the LoadCacheFlag is NOT TRUE (essentially checking if the user
					-- is trying to create a cache file). Under these conditions, if a cache file is NOT found, and the user is trying to LOAD a cache (LoadCacheFlag is true)
					-- the test will fail. It will always succed if the user is trying to create a cache (LoadCacheFlag is false) or if the cache exists.
					IsCurrentFilePathValid = (doesFileExist CurrentFilePath)
					if IsCurrentFilePathValid OR (NOT LoadCacheFlag) then
					(
						-- This routine returns true only if 3 conditions are satisfied: 1 - the current cache file exists; 2 - the user clicked the "Create Cache" button
						-- and the user has checked the "Skip" checkbutton, meaning they want to skip the creation of new caches on objects that already have them created.
						if IsCurrentFilePathValid AND (NOT LoadCacheFlag) AND (CacheSkipCheckButton.checked) then
						(
							append SkippedObjs i
							print  ("CACHE EXISTS AND USER SELECTED TO \"SKIP\" ON -> " + (i.name) )
						)
						else
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
	-- Function: Check_Folder_VersionFN
	-- Description: Checks and updates the cache folder versioning settings based on user input. Enables or disables versioning controls and ensures the cache directory is valid or creates
	-- a new version if needed.
	-- Parameters:
	--   None (uses global UI controls and variables like EnableVersioningCheckbox, FolderVersionNameEditText, CurrentVersionSpinner, UpdateVersionButton, FolderVersionNameLabel, CacheRootFolder,
	-- and CacheLocalFolder).
	-- Return Value: None
	-- Notes: Updates UI elements (e.g., enabling/disabling controls, setting labels) and verifies or creates the cache folder structure. If versioning is disabled, it defaults to the root 
	--folder. If versioning is enabled but the folder doesn’t exist, it marks it with an asterisk (*) and disables cache operations until the folder is created.
	function Check_Folder_VersionFN =
	(
		if EnableVersioningCheckbox.checked then
		(
			FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = true
			FolderVersionNameLabel.text = (@"\" + FolderVersionNameEditText.text + "_v" + (formattedPrint CurrentVersionSpinner.value format:"03d"))
			CacheLocalFolder = (CacheRootFolder + FolderVersionNameLabel.text)
			if (getDirectories CacheLocalFolder).count == 0 then
			(
				FolderVersionNameLabel.text += "*"
				CacheLocalFolder = undefined
				MakeCacheButton.enabled = LoadCacheButton.enabled = false
				CurrentOperationLbl.text = "Folder version not found"
				CurrentOperationLbl.tooltip = FolderVersionNameLabel.tooltip = "The current folder version was not found. Check the Cache Root Folder path or press the Create button on the Enable Versioning section to create the current Folder version."
			)
			else
			(
				CacheLocalFolder = (CacheRootFolder + FolderVersionNameLabel.text)
				MakeCacheButton.enabled = LoadCacheButton.enabled = true
				CurrentOperationLbl.text = "..."
				CurrentOperationLbl.tooltip = FolderVersionNameLabel.tooltip = ""
			)
		)
		else
		(
			FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = false
			CacheLocalFolder = CacheRootFolder
			MakeCacheButton.enabled = LoadCacheButton.enabled = true
			CurrentOperationLbl.text = "..."
			CurrentOperationLbl.tooltip = FolderVersionNameLabel.tooltip = ""
		)
	)
	-- Event Handler: on MakeCacheButton pressed
	-- Description: Handles the action when the "Create Cache" button is pressed, initiating the process to create point caches for selected objects if a valid cache folder is specified.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Checks if CacheLocalFolder is defined; if not, prompts the user to select a folder. Calls PointCache_SetupFN with false to indicate cache creation mode.
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
	-- Event Handler: on LoadCacheButton pressed
	-- Description: Handles the action when the "Load Cache" button is pressed, initiating the process to load point caches for selected objects if a valid cache folder is specified.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Checks if CacheLocalFolder is defined; if not, prompts the user to select a folder. Calls PointCache_SetupFN with true to indicate cache loading mode.
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
	-- Event Handler: on RootFolderButton pressed
	-- Description: Handles the action when the "Select Root Folder" button is pressed, allowing the user to choose or change the root directory for cache storage/loading.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Uses getSavePath to open a folder selection dialog, updates CacheRootFolder, and enables versioning controls if a folder is selected. Truncates long paths in 
	-- the button text for display and sets tooltips for full path visibility.
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
	-- Event Handler: on RootFolderOpenButton pressed
	-- Description: Handles the action when the "..." button next to the root folder is pressed, opening the current CacheRootFolder in Windows Explorer.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Uses shellLaunch to open the folder, assuming CacheRootFolder is defined and valid.
	on RootFolderOpenButton pressed do
	(
		shellLaunch "explorer.exe" CacheRootFolder
	)
	-- Event Handler: on EnableVersioningCheckbox changed
	-- Description: Handles changes to the "Enable versioning" checkbox, enabling or disabling versioning UI controls and updating the cache folder path accordingly.
	-- Parameters:
	--   val: Boolean value indicating the new state of the checkbox (true for enabled, false for disabled).
	-- Return Value: None
	-- Notes: Calls Check_Folder_VersionFN to refresh the folder path and UI state based on the new versioning setting.
	on EnableVersioningCheckbox changed val do
	(
		FolderVersionNameEditText.enabled = CurrentVersionSpinner.enabled = UpdateVersionButton.enabled = FolderVersionNameLabel.enabled = val
		Check_Folder_VersionFN()
	)
	-- Event Handler: on FolderVersionNameEditText entered
	-- Description: Handles the event when the user finishes editing the folder version name, validating it for invalid characters and updating the cache folder path.
	-- Parameters:
	--   val: String value entered in the FolderVersionNameEditText field.
	-- Return Value: None
	-- Notes: Checks for empty input or invalid characters (defined in InvalidCharacters) and reverts to the default name if invalid. Calls Check_Folder_VersionFN to update the folder path.
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
	-- Event Handler: on CurrentVersionSpinner changed
	-- Description: Handles changes to the version number spinner, updating the cache folder path to reflect the new version.
	-- Parameters:
	--   val: Integer value representing the new version number.
	-- Return Value: None
	-- Notes: Calls Check_Folder_VersionFN to refresh the folder path and UI state based on the new version number.
	on CurrentVersionSpinner changed val do
	(
		Check_Folder_VersionFN()
	)
	-- Event Handler: on UpdateVersionButton pressed
	-- Description: Handles the action when the "Create" button in the versioning section is pressed, creating a new versioned cache folder if it doesn’t exist.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Uses makeDir to create the folder if marked with an asterisk (*), then updates the folder path and UI state by calling Check_Folder_VersionFN.
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
	-- Event Handler: on timeSnap pressed
	-- Description: Handles the action when the "Snap to Timeline" button is pressed, setting the frame range spinners to match the current animation timeline range.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Updates framesStartSpinner and framesEndSpinner with the animationrange.start and animationrange.end values.
	on timeSnap pressed do
	(
		framesStartSpinner.value = animationrange.start
		framesEndSpinner.value = animationrange.end
	)
	-- Event Handler: on XMLFileCheckButton changed
	-- Description: Handles changes to the ".xml" checkbox, setting the cache file format to .xml and deselecting the .pc2 option.
	-- Parameters:
	--   state: Boolean value indicating whether the checkbox is checked or unchecked.
	-- Return Value: None
	-- Notes: Updates the FileExtension variable and ensures only one file format is selected at a time.
	on XMLFileCheckButton changed state do
	(
		FileExtension = ".xml"
		XMLFileCheckButton.checked = true
		PC2FileCheckButton.checked = false
	)
	-- Event Handler: on PC2FileCheckButton changed
	-- Description: Handles changes to the ".pc2" checkbox, setting the cache file format to .pc2 and deselecting the .xml option.
	-- Parameters:
	--   state: Boolean value indicating whether the checkbox is checked or unchecked.
	-- Return Value: None
	-- Notes: Updates the FileExtension variable and ensures only one file format is selected at a time.
	on PC2FileCheckButton changed state do
	(
		FileExtension = ".pc2"
		XMLFileCheckButton.checked = false
		PC2FileCheckButton.checked = true
	)
	-- Event Handler: on CacheReplaceCheckButton changed
	-- Description: Handles changes to the "Replace" checkbox, setting the behavior to replace existing cache files and deselecting the "Skip" option.
	-- Parameters:
	--   state: Boolean value indicating whether the checkbox is checked or unchecked.
	-- Return Value: None
	-- Notes: Ensures only one option ("Replace" or "Skip") is selected at a time for handling existing cache files.
	on CacheReplaceCheckButton changed state do
	(
		CacheReplaceCheckButton.checked = true
		CacheSkipCheckButton.checked = false
	)
	-- Event Handler: on CacheSkipCheckButton changed
	-- Description: Handles changes to the "Skip" checkbox, setting the behavior to skip existing cache files and deselecting the "Replace" option.
	-- Parameters:
	--   state: Boolean value indicating whether the checkbox is checked or unchecked.
	-- Return Value: None
	-- Notes: Ensures only one option ("Replace" or "Skip") is selected at a time for handling existing cache files.
	on CacheSkipCheckButton changed state do
	(
		CacheReplaceCheckButton.checked = false
		CacheSkipCheckButton.checked = true
	)
	-- Event Handler: on AddPointCacheButton pressed
	-- Description: Handles the action when the "Add Point Cache Modifier" button is pressed, adding a Point Cache modifier above the Skin modifier for all selected objects.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Checks if objects are selected; if not, prompts the user. Uses SkinMod_PointCacheMod_IndexerFN and AddSet_PointCacheMod_Above_SkinMod_FN to manage modifiers.
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
	-- Event Handler: on TurnOnCacheButton pressed
	-- Description: Handles the action when the "Cache On" button is pressed, enabling all Point_Cache modifiers on selected objects.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Calls ModifierOnOffFN with true to enable Point_Cache modifiers on all selected objects.
	on TurnOnCacheButton pressed do
	(
		ModifierOnOffFN true Point_Cache
	)
	-- Event Handler: on TurnOffCacheButton pressed
	-- Description: Handles the action when the "Cache Off" button is pressed, disabling all Point_Cache modifiers on selected objects.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Calls ModifierOnOffFN with false to disable Point_Cache modifiers on all selected objects.
	on TurnOffCacheButton pressed do
	(
		ModifierOnOffFN false Point_Cache
	)
	-- Event Handler: on TurnOnSkinButton pressed
	-- Description: Handles the action when the "Skin On" button is pressed, enabling all Skin modifiers on selected objects that have point caches.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Calls ModifierOnOffFN with true to enable Skin modifiers on all selected objects.
	on TurnOnSkinButton pressed do
	(
		ModifierOnOffFN true Skin
	)
	-- Event Handler: on TurnOffSkinButton pressed
	-- Description: Handles the action when the "Skin Off" button is pressed, disabling all Skin modifiers on selected objects that have point caches.
	-- Parameters:
	--   None (triggered by UI event).
	-- Return Value: None
	-- Notes: Calls ModifierOnOffFN with false to disable Skin modifiers on all selected objects.
	on TurnOffSkinButton pressed do
	(
		ModifierOnOffFN false Skin
	)
	-- Event Handler: on PointCacheBatch open
	-- Description: Handles the initialization of the PointCacheBatch rollout when it is first opened, setting default frame range values based on the current timeline.
	-- Parameters:
	--   None (triggered when the rollout is opened).
	-- Return Value: None
	-- Notes: Sets the framesStartSpinner and framesEndSpinner to match the animationrange.start and animationrange.end values.
	on PointCacheBatch open do
	(
		framesStartSpinner.value = animationrange.start
		framesEndSpinner.value = animationrange.end
	)
)
AddSubRollout MakeToolbox.theSubrollout PointCacheBatch