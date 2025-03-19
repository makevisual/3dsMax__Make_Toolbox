/*
#NAME: TyFlow Asset Remap
#VERSION:1.0
#SOURCE:David Almeida, david.almeida@makevisual.com
#HISTORY:03.17.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Modified by David Almeida
--*****************************************************
-- HISTORY:
--- version 1.00 : 03.17.2025 >> Start Development
--*****************************************************
TyAssetRemapToolModule = "0.1"
try(removeSubRollout MakeToolbox.theSubrollout TyAssetRemap)catch()

-- creates the UI
rollout TyAssetRemap ("TyFlow Asset Remap " + (TyAssetRemapToolModule as string))
(
	local
	AssetPath = undefined,
	SearchDirectories = #(),
	TyflowArray = #(),
	AssetsToRemap = 0,
	AssetsRemaped = 0,
	DuplicateAssets = #(),
	DuplicateTyFlow = #(),
	MissingAssets = #(),
	MissingTyFlow = ()
	group "Path Select"
	(
		button TyAssetPathButton "Select Assets Path" width:133 height:21 pos:[6,24] across:2 tooltip:"Select the path of the assets to remap"
		button TyAssetClearPath "X" width:21 height:21 enabled:false pos:[138,24] tooltip:"Reset path" 
		label SelectedFolderTxtLBL "Selected folder:"
		label SelectedFolderLBL "-"
	)
	checkbox TyAssetSubFolderCheckbox "Search subfolders" checked:true tooltip:"Check to search inside subfolders"
	checkbox TyAssetMissingCheckbox "Only missing assets" checked:true tooltip:"Check to remap only missing assets"
	checkbox TyAssetSelectedTyFlowCheckbox "Only selected TyFlow(s)" checked:false tooltip:"Check to remap only the selected TyFlow(s)"
	button TyAssetRepathButton "Remap" width:160 enabled:false tooltip:"Remap tyFlow assets"
	label AssetsToRemapLBL "Assets to remap: -"
	label AssetsRemapedLBL "Assets remapped: -"
	label AssetsDuplicateLBL "Duplicate Assets: -"
	label AssetsMissingLBL "Missing Assets: -"
	-- function to clear variables at every iteration or folder change
	function clearVar = 
	(
		AssetsToRemapLBL.text = "Assets to remap: -" 
		AssetsRemapedLBL.text = "Assets remapped: -"
		AssetsDuplicateLBL.text = "Duplicate Assets: -"
		AssetsMissingLBL.text = "Missing Assets: -"
		AssetsToRemap = 0
		AssetsRemaped = 0
		DuplicateAssets = #()
		MissingAssets = #()
	)
	-- function to collect folders and subfolders until a maximum iteration
	function FolderCollect rootFolder =
	(
		SearchDirectories = (getDirectories (rootFolder + "\\*"))
		InitialCount = 0
		CurrentCount = SearchDirectories.count
		SubfolderLevel = 0
		SubfolderLimit = 20
		while (InitialCount < CurrentCount) AND (SubfolderLevel < SubfolderLimit) do
		(
			for i = (InitialCount + 1) to CurrentCount do
			(
				SearchDirectories = SearchDirectories + (getDirectories (SearchDirectories[i] + "*"))
			)
			InitialCount = CurrentCount
			CurrentCount = SearchDirectories.count
			SubfolderLevel += 1
		)
		append SearchDirectories (rootFolder + "\\")
	)
	-- function to set new paths
	function RemapFunction MissingFileName CurrEvent loopIndex CurrTyFlow =
	(
		if TyAssetSubFolderCheckbox.checked then
		(
			TimesRemapped = 0
			for CurrentPath in SearchDirectories do
			(
				DefaulWorkingDir = sysInfo.currentdir
				sysInfo.currentdir = CurrentPath
				if doesFileExist MissingFileName do
				(
					AssetsRemaped += 1
					NewAssetPath = (CurrentPath + MissingFileName)
					CurrEvent.vrmeshFilename_tab[loopIndex] = NewAssetPath
					append DuplicateAssets ((CurrTyFlow.name as string) + " | " + NewAssetPath)
					TimesRemapped += 1
					if TimesRemapped > 1 do 
					(	
						AssetsRemaped -= 1
					)
				)
				sysInfo.currentdir = DefaulWorkingDir
			)
			if  TimesRemapped == 0 do
			(
				append MissingAssets ((CurrTyFlow.name as string) + " | " + MissingFileName)
			)
			if TimesRemapped == 1 do
			(
				deleteitem DuplicateAssets (DuplicateAssets.count)
			)
			if TimesRemapped > 1 do
			(
				DuplicateAssets[DuplicateAssets.count] = (DuplicateAssets[DuplicateAssets.count] + " <- USING")
			)
		)
		else
		(
			DefaulWorkingDir = sysInfo.currentdir
			sysInfo.currentdir = AssetPath


			if doesFileExist MissingFileName then
			(
				AssetsRemaped += 1
				NewAssetPath = (AssetPath + "\\" + MissingFileName)
				CurrEvent.vrmeshFilename_tab[loopIndex] = NewAssetPath
			)
			else
			(
				append MissingAssets ((CurrTyFlow.name as string) + " | " + MissingFileName)
			)
			sysInfo.currentdir = DefaulWorkingDir
		)
	)
	-- function for repathing the TyFlow VRay Proxy Assets
	function TyAssetRepathFunction =
	(
		if TyAssetSelectedTyFlowCheckbox.checked then
		(
			TyflowArray = (for i in selection where (isKindOf i tyflow) collect i)
		)
		else
		(
			TyflowArray = (for i in objects where (isKindOf i tyflow) collect i)
		)
		if TyflowArray.count != 0 then
		(
			clearVar()
			for i in TyflowArray do
			(
				EventsArray = (for j = 1 to i[4].numsubs where (isKindOf i[4][j] tyEvent) collect i[4][j])
				for CurrentEvent in EventsArray do
				(
					EventPropNames = getpropnames CurrentEvent
					for k = 1 to CurrentEvent.numsubs do
					(
						if EventPropNames[k] == #shape do
						(
							for l = 1 to CurrentEvent[k].shape_type_tab.count do
							(
								if CurrentEvent[k].shape_type_tab[l] == 3 do
								(
									Currentfilename = filenameFromPath CurrentEvent[k].vrmeshFilename_tab[l]
									OriginalFilePath = pathConfig.removePathLeaf CurrentEvent[k].vrmeshFilename_tab[l]
									if (doesDirectoryExist OriginalFilePath) then
									(
										DefaulWorkingDir = sysInfo.currentdir
										sysInfo.currentdir = OriginalFilePath
										if (NOT (doesFileExist Currentfilename)) OR (NOT TyAssetMissingCheckbox.checked) then
										(
											AssetsToRemap += 1
											sysInfo.currentdir = DefaulWorkingDir
											RemapFunction Currentfilename CurrentEvent[k] l i
										)
										else
										(
											sysInfo.currentdir = DefaulWorkingDir
										)
									)
									else
									(
										AssetsToRemap += 1
										RemapFunction Currentfilename CurrentEvent[k] l i
									)
								)
							)
						)
					)
				)
			)
		)
		else
		(
			messagebox "No TyFlow object(s) in this scene or no Tyflow object(s) selected"
		)
		AssetsToRemapLBL.text = ("Assets to remap: " + (AssetsToRemap as string))
		AssetsRemapedLBL.text = ("Assets remapped: " + (AssetsRemaped as string))
		if DuplicateAssets.count > 0 do
		(
			AssetsDuplicateLBL.text = ("Duplicate Assets: " + (DuplicateAssets.count as string))
			print "Duplicate Assets:"
			print DuplicateAssets
		)
		if MissingAssets.count > 0 do
		(
			AssetsMissingLBL.text = ("Missing Assets: " + (MissingAssets.count as string))
			print "Missing Assets:"
			print MissingAssets
		)
		if (MissingAssets.count > 0) OR (DuplicateAssets.count > 0) do
		(
			messagebox "Some duplicate and/or missing assets were detected.\nCheck the listener for more info."
		)
	)
	on TyAssetPathButton pressed do
	(
		AssetPath = getSavePath caption:"Select assets folder" initialDir:(pathConfig.getCurrentProjectFolder())
		if AssetPath != undefined do
		(
			TyAssetPathButton.text = TyAssetPathButton.tooltip = AssetPath
			TyAssetClearPath.enabled = true
			TyAssetRepathButton.enabled = true
			FolderCollect AssetPath
			FoldersArray = filterstring AssetPath "\\"
			if TyAssetSubFolderCheckbox.checked then
			(
				SelectedFolderLBL.text = ("  " + FoldersArray[FoldersArray.count] + " + subfolders")
			)
			else
			(
				SelectedFolderLBL.text = ("  " + FoldersArray[FoldersArray.count])
			)
		)
	)
	on TyAssetClearPath pressed do
	(
		AssetPath = undefined
		TyflowArray = #()
		TyAssetPathButton.text = "Select Assets Path"
		TyAssetPathButton.tooltip = "Select the path of the assets to remap"
		TyAssetClearPath.enabled = false
		TyAssetRepathButton.enabled = false
		SearchDirectories = ()
		SelectedFolderLBL.text = "-"
		clearVar()
	)
	on TyAssetSubFolderCheckbox changed val do
	(
		if AssetPath != undefined do
		(
			FoldersArray = filterstring AssetPath "\\"
			if val then
			(
				SelectedFolderLBL.text = ("  " + FoldersArray[FoldersArray.count] + " + subfolders")
			)
			else
			(
				SelectedFolderLBL.text = ("  " + FoldersArray[FoldersArray.count])
			)
		)
	)
	on TyAssetRepathButton pressed do
	(	try
		(
			if TyAssetSelectedTyFlowCheckbox.checked AND (selection.count == 0) then
			(
				messagebox "Select Tyflow object(s)"
			)
			else
			(
				TyAssetRepathFunction()
			)
		)
		catch
		(
			--catches any errors
			messagebox "Unexpected error, please try again."
		)
	)
)

AddSubRollout MakeToolbox.theSubrollout TyAssetRemap