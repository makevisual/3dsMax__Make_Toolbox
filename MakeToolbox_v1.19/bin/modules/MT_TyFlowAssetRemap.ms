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
	TyflowArray = #(),
	AssetsToRemap = 0,
	AssetsRemaped = 0
	button TyAssetPathButton "Select Assets Path" width:140 pos:[3,7] across:2 tooltip:"Select the path of the assets to remap"
	button TyAssetClearPath "X" width:21 height:21 enabled:false pos:[142,7] tooltip:"Reset path"
	checkbox TyAssetSubFolderCheckbox "Search subfolders" checked:true tooltip:"Check to search inside subfolders"
	checkbox TyAssetSelectedTyFlowCheckbox "Only selected TyFlow(s)" checked:false tooltip:"Check to remap only the selected TyFlow(s)"
	button TyAssetRepathButton "Remap" width:160 enabled:false tooltip:"Remap tyFlow assets"
	label AssetsToRemapLBL "Assets to remap: -"
	label AssetsRemapedLBL "Assets remapped: -"
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
			AssetsToRemap = 0
			AssetsRemaped = 0
			for i in TyflowArray do
			(
				EventsArray = (for j = 1 to i[4].numsubs where (isKindOf i[4][j] tyEvent) collect i[4][j])
				for CurrentEvent in EventsArray do
				(
					for k = 1 to CurrentEvent.numsubs do
					(
						try
						(
							for l = 1 to CurrentEvent[k].shape_type_tab.count do
							(
								if CurrentEvent[k].shape_type_tab[l] == 3 do
								(
									AssetsToRemap += 1
									if TyAssetSubFolderCheckbox.checked then
									(
										SearchDirectories = (getDirectories (AssetPath + "\\*"))
										append SearchDirectories (AssetPath + "\\")
										for CurrentPath in SearchDirectories do
										(


										DefaulWorkingDir = sysInfo.currentdir
										sysInfo.currentdir = CurrentPath
										Currentfilename = filenameFromPath CurrentEvent[k].vrmeshFilename_tab[l]
										if doesFileExist Currentfilename do
										(
											AssetsRemaped += 1
											NewAssetPath = (CurrentPath + (pathConfig.stripPathToLeaf CurrentEvent[k].vrmeshFilename_tab[l]))
											CurrentEvent[k].vrmeshFilename_tab[l] = NewAssetPath
										)
										sysInfo.currentdir = DefaulWorkingDir
										)
									)
									else
									(
										DefaulWorkingDir = sysInfo.currentdir
										sysInfo.currentdir = AssetPath
										Currentfilename = filenameFromPath CurrentEvent[k].vrmeshFilename_tab[l]
										if doesFileExist Currentfilename do
										(
											AssetsRemaped += 1
											NewAssetPath = (AssetPath + "\\" + (pathConfig.stripPathToLeaf CurrentEvent[k].vrmeshFilename_tab[l]))
											CurrentEvent[k].vrmeshFilename_tab[l] = NewAssetPath
										)
										sysInfo.currentdir = DefaulWorkingDir
									)
								)
							)
						)
						catch ()
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
	)
	on TyAssetPathButton pressed do
	(
		AssetPath = getSavePath caption:"Select assets folder" initialDir:(pathConfig.getCurrentProjectFolder())
		if AssetPath != undefined do
		(
			TyAssetPathButton.text = TyAssetPathButton.tooltip = AssetPath
			TyAssetClearPath.enabled = true
			TyAssetRepathButton.enabled = true
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
		AssetsToRemapLBL.text = "Assets to remap: -" 
		AssetsRemapedLBL.text = "Assets remapped: -"
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