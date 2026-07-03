/*
--**********************************************************************************--
--                                                                                  --
--                                   MIRROR RIG                                     --
--                                                                                  --
--**********************************************************************************--

#NAME: Mirror Rig
#VERSION: 1.4
#LAST UPDATED: 2026.07.03

#DESCRIPTION:
A tool to mirror object hierarchies, such as character rigs, across a specified axis. 
It includes rigging-specific options to handle constraints, object naming, duplication,
and geometry normals automatically.

#INSTRUCTIONS:
Select the objects (or hierarchy) to mirror. Choose the desired mirror axis (X, Y, or Z) 
and configure your options for mirror method, duplication, rig checks, and renaming. 
Click one of the main mirror buttons to perform the operation.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Mirror_Rig

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Added non-negative scale mirror and hierarchy options.

#HISTORY:
	- v1.4 (2026.07.03): Bug fixing on the way the script recreates hierarchies when "Mirror entire Hierarchy" is turned OFF.
						 Bug fixed when mirroring bones and keeping their bone property.
    - v1.3 (2025.08.20): Added non-negative scale mirror and option to mirror the entire or partial hierarchy.
    - v1.2 (2015.02.09): Fixed naming bug, added normal flipping, and fixed a parent/unparent bug.
    - v1.1 (2013.08.12): Added clone and instance duplication ability.
    - v1.0 (2012.03.01): Initial integration into MakeToolbox.

--**********************************************************************************--
*/

mirrorRigModuleVer = 1.4

try(removeSubRollout MakeToolbox.theSubrollout mirrorRigModule)catch()

-- creates the UI
rollout mirrorRigModule ("Mirror Rig v" + (mirrorRigModuleVer as string))
(
	local
	defaultSearchPairs = #(#("Left","Right"),#("Right","Left"),#("left","right"),#("right","left"),#("_L_","_R_"),#("_R_","_L_"),#("_l_","_r_"),#("_r_","_l_")),
	customSearchPair = #(),
	searchPairs = #(),
	MirroRig_PreviewItemNames

	-- UI Elements
	groupbox mirrorGroup "Mirroring" offset: [-10,-5] width:155 height:43
		button mirrorXButton "Mirror X" pos:[9,18] width:47 tooltip:"Flip your selection using world X axis."
		button mirrorYButton "Mirror Y" pos:[57,18] width:47  tooltip:"Flip your selection using world Y axis."
		button mirrorZButton "Mirror Z" pos:[105,18] width:47 tooltip:"Flip your selection using world Z axis."

	groupbox MirrorMethod "Mirror Method" offset: [-10,5] width: 155 height:90
		checkbox ScaleMirror_checkbox "Use negative scale" offset: [0,-80] checked:false tooltip:"Mirror your selection by applying a negative scale to the objects. Use this method for complex rigs"
		checkbox MirrorAllHierarchy_checkbox "Mirror entire hierarchy" checked:true tooltip:"Mirror all selected objects AND the hierarchy they are part of."
		radiobuttons AxisFlip_Radiobutton "" labels:#("Flip 2nd axis", "Flip 3rd axis") enabled:true tooltip:"Choose axis to rotate."

	groupbox duplicateGroup "Duplication" offset: [-10,4] width: 155 height:50
		checkBox makeCopy "Mirror as duplicate" offset:[0,-40] checked:true tooltip:"Make copies of the selected objects and mirrors them."
		checkBox instanceCheck "Duplicate as instance" offset:[0,-4] checked:false enabled:true tooltip:"Make instances of the selected objects and mirrors them."

	groupbox rigChecksGroup "Rig Checks" offset: [-10,3] width: 155 height:70 					visible:true 
		checkBox flipLookatsCheck "Flip Lookat constraints" offset:[0,-60] checked:true 		visible:true 
		checkBox flipNormalsCheck "Flip Geometry Normals" offset:[0,-4] checked:false 			visible:true  enabled:false
		checkBox autoBreakCheck "Auto Breakout Selection" offset:[0,-4] checked:false 			visible:true 

	groupbox renameGroup "Renaming" offset: [-10,7] width: 155 height:95						visible:true 
		checkbox autoRenameCheck "Auto: 'Left' <=> 'Right'" offset:[0,-85] checked:true 			visible:true 
		checkbox customRenameCheck "Custom rename" offset:[0,-4] checked:false enabled:true 	visible:true 
		edittext changeFromBox "" offset:[-6,-2] width:70 enabled:false  						visible:true 
		edittext changeToBox "" offset:[70,-22] width:70 enabled:false 							visible:true 
		label labChange "to" offset:[0,-20] enabled:false 										visible:true 
		button previewRenamingButton "Preview renaming" height:20 width:145 alighn:#left 		visible:true

	-- Functions
	function setSearchPairs = -- sets the current search pairs based on ui choices
	(
		if autoRenameCheck.checked == true then
		(
			searchPairs = defaultSearchPairs
		)
		else
		(
			searchPairs = #(#(changeFromBox.text,changeToBox.text))
		)
		return searchPairs
	)

	function resetNames set1 set2 =
	(
		for i in 1 to set2.count do
		(
			set2[i].name = set1[i].name
		)
	)
		
	function flipNormalsFunction argArr =
	(
		
		-- loop through objects to flip their normals
		for i in argArr do
		(
			-- if it is geometry, and not a bone...
			if (superclassof i) == GeometryClass and (classof i) != BoneGeometry then
			(
				curMods = i.modifiers
				flipped = false
			
				-- look through its modifiers
				for j in curMods do
				(
					-- Flip any existing normal modifers
					if (classof j) == Normalmodifier then
					(
						if j.flip == true then
						(
							j.flip = false
						)
						else
						(
							j.flip = true
						)
						flipped = true
					)
					else()
				)
			
			-- Put a flipped normal modifier on if no previous normal modifiers were found
				if flipped == false	then
				(
					newNormalMod = normalmodifier flip:true
					addmodifier i newNormalMod
				)
				else()
			)
			else()
		)
	)

	function previewNameWindowFunction namesArr =
	(
		MirroRig_PreviewItemNames = namesArr
		try(closerolloutfloater namePreviewWindow)catch()
		rollout namePreviewWindow "Renaming Preview"
		(
			listbox theListbox "" width:170 offset:[-10,-4]
			
			on namePreviewWindow open do
			(
				theListbox.items = MirroRig_PreviewItemNames
			)
		)
		createDialog namePreviewWindow 175 140
	)
		
	function renameObjectsFunction objArrArg searchPairsArg modeArg = -- objectsArr: the objects to rename	searchPairsArg: paired strings in array	modeArg: 1=preview 2=do
	(
		-- Clear and set variables
		searchPairs = searchPairsArg
		objArr = undefined
		strArr = undefined
		failcount = 0
		objArr = objArrArg

		--Pass only if there are objects selected
		if objArr.count > 0 then
		(
			-- Set the selected objects names to an array, and duplicate name array for processing
			strArr = #()
			for i in 1 to objArr.count do
			(
				join strArr #(objArr[i].name)
			)
			newStrArr = deepcopy strArr
				
			-- Loop through and define the current search Pairs
			for j in 1 to searchPairs.count do
			(
				fromStr = searchPairs[j][1]
				toStr = searchPairs[j][2]
				
				-- Loop through the object array
				for i in 1 to strArr.count do
				(
					curStr = strArr[i]
					newStr = (substituteString curStr fromStr toStr) -- Test the search pairs
					if curStr != newStr then
					(
						newStrArr[i] = newStr
					)
					else
					(
						failCount = failcount+1
					) -- Add corrected pair to duplicate name array
				)
			)
			case modeArg of
			(
				1: -- Rename the objects with the duplicate array
				(
					previewNameWindowFunction newStrArr
				)
				2: -- Rename the objects with the duplicate array
				(
					for i in 1 to objArr.count do
					(
						objArr[i].name = newStrArr[i]
					)
				)
				default: Print "error"
			)
		)
	)

	function duplicateEnableUIFunction bool =
	(
		if bool == true then
		(
			instanceCheck.enabled = true
		)
		else
		(
			instanceCheck.enabled = false
		)
	)

	function renamingEnableUIFunction bool =
	(
		if bool == 1 then
		(
			if customRenameCheck.checked == true then
			(
				labChange.enabled = true
				changeFromBox.enabled = true
				changeToBox.enabled = true
			)
			else
			(
				labChange.enabled = false
				changeFromBox.enabled = false
				changeToBox.enabled = false
			)
			autoRenameCheck.checked = false
		)
		else
		(
			labChange.enabled = false
			changeFromBox.enabled = false
			changeToBox.enabled = false
			customRenameCheck.checked = false
		)
	)
	function breakoutFunction objArrArg = -- Unparents any objects that are parented to objects outside of the selection
	(
		objArr = objArrArg
		subObjArr = #()
		preserveArr = #()
		for i in 1 to objArr.count do -- loop the objects
		(
			if objArr[i].parent != undefined then
			(
				join subObjArr #(objArr[i])
			)
		)
		for i in 1 to subObjArr.count do
		(
			preserveVar = false
			for j in 1 to objArr.count do
			(
				if subObjArr[i].parent == objArr[j] then -- test to preserve
				(
					preserveVar = true
				)
			)
			join preserveArr #(preserveVar)
		)	
		for i in 1 to subObjArr.count do
		(
			if preserveArr[i] == true then
			()
			else
			(
				subObjArr[i].parent = undefined
			)
		)
	)
	function flipLookatsFunction objArrArg = -- searches for any lookat constraints and flips them 
	(
		objArr = objArrArg
		for i in 1 to objArr.count do
		(
			try
			(
				if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == off then 
				(
					lookatVal = 1
				)
				else
				()
				if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == on then
				(
					lookatVal = 2
				)
				else()
				if (lookatVal == 1) then
				(
					objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = on
				)
				else()
				if (lookatVal == 2) then
				(
					objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = off
				)
				else()
			)
			catch()
		)
	)
	-- Mirror New Hierarchy
	function FN_MirrorHierarchy CurrentNode flipDirection flipAxis &ClonedParent =
	(	
		if instanceCheck.checked then
		(
			CopyType = instance 
		)
		else
		(
			CopyType = copy
		)
		ClonedParent = CopyType CurrentNode wirecolor:CurrentNode.wirecolor name:CurrentNode.name boneEnable:CurrentNode.boneEnable
		ClonedParent.parent = undefined
		NewTransform = ClonedParent.transform
		NewTransform.row1 = flipAxis[1]*NewTransform.row1
		NewTransform.row2 = flipAxis[2]*NewTransform.row2
		NewTransform.row3 = flipAxis[3]*NewTransform.row3
		NewTransform.pos = NewTransform.pos*flipDirection
		ClonedParent.transform = NewTransform
		searchPairs = setSearchPairs()
		if autoRenameCheck.checked == true or customRenameCheck.checked == true then
		(
			searchPairsBool = 2
		)
		else
		(
			searchPairsBool = 1
		)
		renameObjectsFunction #(ClonedParent) searchPairs searchPairsBool
	)
	-- Recreate Hierarchy
	function FN_ReCreateHierarchy CurrentParent NewParent flipDirection flipAxis =
	(
		ClonedParent = undefined
		if CurrentParent.parent == undefined then
		(
			FN_MirrorHierarchy CurrentParent flipDirection flipAxis &ClonedParent
			NewParentNode = ClonedParent
		)
		else
		(
			NewParentNode = NewParent
		)
		if CurrentParent.children.count > 0 do
		(
			for CurrentChild in CurrentParent.children do
			(
				FN_MirrorHierarchy CurrentChild flipDirection flipAxis &ClonedParent
				ClonedParent.parent = NewParentNode
				FN_ReCreateHierarchy CurrentChild ClonedParent flipDirection flipAxis
			)
		)
	)
	-- Creates an array with the parents indexes of the nodes
	function FN_ParentIndexes &ParentIndexArray HierarchyArray =
	(
		for i = 1 to HierarchyArray.count do
		(
			if HierarchyArray[i].count > 1 then
			(
				ParentIndexArray[i] = #(0)
				for j = 2 to HierarchyArray[i].count do
				(
					ParentIndex = findItem HierarchyArray[i] (HierarchyArray[i][j].parent)
					append ParentIndexArray[i] ParentIndex
				)
			)
			else
			(
				ParentIndexArray[i] = #(0)
			)
		)
	)
	-- Removes unselected objects from the hierarchy array
	function FN_RemoveUnselected SelectedObjectsArray &HierarchyArray =
	(
		for i = HierarchyArray.count to 1 by -1 do
		(
			for j = HierarchyArray[i].count to 1 by -1 do
			(
				ItemIndex = finditem SelectedObjectsArray HierarchyArray[i][j]
				if ItemIndex == 0 do
				(
					deleteitem HierarchyArray[i] j
				)
			)
		)
	)
	-- Finds all nodes below the given parent nodes
	function FN_GrabAllChildren ParentArray &HierarchyArray =
	(
		for i = 1 to ParentArray.count do
		(

			allChildren = #(ParentArray[i])

			-- add children and their children etc recursively
			index = 0
			while index < allChildren.count do
			(
				index += 1
				join allChildren allChildren[index].children
			)

			HierarchyArray[i] = allChildren
		)
	)
	-- Find All Parents
	function FN_FindParents CurrArray &ParentArray =
	(
		ObjectsArray = deepcopy CurrArray
		while ObjectsArray.count != 0 do
		(
			for i = ObjectsArray.count to 1 by -1 do
			(
				NewParent = ObjectsArray[i].parent
				if NewParent == undefined then
				(
					appendIfUnique ParentArray ObjectsArray[i]
					deleteItem ObjectsArray i
				)
				else
				(
					appendIfUnique ObjectsArray NewParent
					deleteitem ObjectsArray i
				)
			)
		)
	)
	-- Main Function 
	function flipFunction objArrArg flipDirection flipAxis =
	(
		if objArrArg.count != 0 then
		(
			objArr = objArrArg
			if ScaleMirror_checkbox.checked then
			(
				-- breaks out any parented objects if breakout enabled
				if autoBreakCheck.checked == true then
				(
					breakoutFunction objArr
				)
				-- makes a copy of the selection
				if makeCopy.checked == true	do
				(
					if instanceCheck.checked == true then
					(
						maxOps.CloneNodes objArr actualNodeList:&objArr newNodes:&newArr cloneType:#instance
					)
					else
					(
						maxOps.CloneNodes objArr actualNodeList:&objArr newNodes:&newArr cloneType:#copy
					)
		 			resetNames objArr newArr
				)
				--rename the objects if enabled
				searchPairs = setSearchPairs()
				if autoRenameCheck.checked == true or customRenameCheck.checked == true then
				(
					searchPairsBool = 2
				)
				else
				(
					searchPairsBool = 1
				)
				renameObjectsFunction selection searchPairs searchPairsBool
				-- Actually do the FLIP!
				try
				(
					tempGroup = group selection name:"TempGroup"
					tempgroup.pivot = [0,0,0]
					scale tempgroup flipDirection
					ungroup tempGroup
				)
				catch
				(
					messagebox "Error: Not all of your selection is independent from outside objects, try enabling 'Auto Breakout' to automatically unparent any of these objects. WARNING! This will modify your hierarchy!"
				)
			)
			else
			(
				-- Find Hierarchy Main Parents
				ParentArray = #()
				FN_FindParents objArr &ParentArray
				if MirrorAllHierarchy_checkbox.checked then
				(
					for CurrentParent in ParentArray do
					(
						FN_ReCreateHierarchy CurrentParent undefined flipDirection flipAxis
					)
				)
				else
				(
					HierarchyArray = #()
					ParentIndexArray = #()
					ClonedHierarchyNodes = #()
					FN_GrabAllChildren ParentArray &HierarchyArray
					FN_RemoveUnselected objArr &HierarchyArray
					FN_ParentIndexes &ParentIndexArray HierarchyArray
					for i = 1 to HierarchyArray.count do
					(
						ClonedParent = undefined
						ParentIndex = undefined
						for j = 1 to HierarchyArray[i].count do
						(
							FN_MirrorHierarchy HierarchyArray[i][j] flipDirection flipAxis &ClonedParent
							append ClonedHierarchyNodes ClonedParent
							if ParentIndexArray[i][j] != 0 do
							(
								ClonedParent.parent = ClonedHierarchyNodes[ParentIndexArray[i][j]]
							)
						)
					)
				)
				if NOT makeCopy.checked do
				(
					delete objArr
				)
			)
			-- flips any lookat constraints if enabled
			if flipLookatsCheck.checked == true then
			(
				flipLookatsFunction objArr
			)
			if (flipNormalsCheck.enabled == true) AND (flipNormalsCheck.checked == true) then
			(
				flipNormalsFunction objArr
			)
			clearUndoBuffer() -- why?
		)
		else
		(
			messagebox "Select one or more objects to mirror."
		)
	)
	-- event handlers
	on mirrorXButton pressed do
	(
		try
		(
			if ScaleMirror_checkbox.checked then
			(
				flipFunction (selection as array) [-1,1,1] undefined
			)
			else
			(
				if AxisFlip_Radiobutton.state == 1 then
				(
					flipFunction (selection as array) [-1,1,1] #([-1, 1, 1],[1, -1, -1],[-1, 1, 1]) -- TODO: DEAL WITH HIERARCHIES!
				)
				else
				(
					flipFunction (selection as array) [-1,1,1] #([-1, 1, 1],[-1, 1, 1],[1, -1, -1])
				)
			)
		)
		catch
		(
			messagebox "Unexpected Error."
		)
	)
	on mirrorYButton pressed do
	(
		try
		(
			if ScaleMirror_checkbox.checked then
			(
				flipFunction (selection as array) [1,-1,1] undefined
			)
			else
			(
				if AxisFlip_Radiobutton.state == 1 then
				(
					flipFunction (selection as array) [1,-1,1] #([1, -1, 1],[-1, 1, -1],[1, -1, 1])
				)
				else
				(
					flipFunction (selection as array) [1,-1,1] #([1, -1, 1],[1, -1, 1],[-1, 1, -1])
				)
			)
		)
		catch
		(
			messagebox "Unexpected Error."
		)
	)
	on mirrorZButton pressed do
	(
		try
		(
			if ScaleMirror_checkbox.checked then
			(
				flipFunction (selection as array) [1,1,-1] undefined
			)
			else
			(
				if AxisFlip_Radiobutton.state == 1 then
				(
					flipFunction (selection as array) [1,1,-1] #([1, 1, -1],[-1, -1, 1],[1, 1, -1])
				)
				else
				(
					flipFunction (selection as array) [1,1,-1] #([1, 1, -1],[1, 1, -1],[-1, -1, 1])
				)
			)
		)
		catch
		(
			messagebox "Unexpected Error."
		)
	)
	on ScaleMirror_checkbox changed state do
	(
		AxisFlip_Radiobutton.enabled = MirrorAllHierarchy_checkbox.enabled = NOT state
		flipNormalsCheck.enabled = state
	)
	on makeCopy changed state do
	(
		duplicateEnableUIFunction state
	)
	on autoRenameCheck changed state do
	(
		renamingEnableUIFunction 2
	)
	on customRenameCheck changed state do
	(
		renamingEnableUIFunction 1
	)
	on previewRenamingButton pressed do
	(
		setSearchPairs()
		renameObjectsFunction selection searchPairs 1
	)
)
AddSubRollout MakeToolbox.theSubrollout mirrorRigModule