/*
#NAME:Mirror Rig
#VERSION:1.0
#INSTRUCTIONS:
Mirror a rig.
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.1.2012 >> Integrated into MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (3.1.2012):
--        1st version
--    - v1.1 (8.12.2013):
--		Added clone / instance ability - ad
--    - v1.2 (2.9.2015):
--		Fixed naming bug
--		Flip normals on geometry
--		Fixed parent/unparent bug
--*****************************************************

mirrorRigModuleVer = 1.3
defaultSearchPairs = #(#("Left","Right"),#("Right","Left"),#("left","right"),#("right","left"),#("_L_","_R_"),#("_R_","_L_"),#("_l_","_r_"),#("_r_","_l_"))--,#("_L","_R"),#("_R","_L"),#("_l","_r"),#("_r","_l"))
customSearchPair = #()
searchPairs = #()

try(removeSubRollout MakeToolbox.theSubrollout mirrorRigModule)catch()

-- creates the UI
rollout mirrorRigModule ("Mirror Rig v" + (mirrorRigModuleVer as string))
(
	-- UI Elements
	groupbox mirrorGroup "Mirroring" offset: [-10,-5] width:155 height:43
		button mirrorXButton "Mirror X" pos:[9,18] width:47 tooltip:"Flip your selection using world X axis."
		button mirrorYButton "Mirror Y" pos:[57,18] width:47  tooltip:"Flip your selection using world Y axis."
		button mirrorZButton "Mirror Z" pos:[105,18] width:47 tooltip:"Flip your selection using world Z axis."
	groupbox duplicateGroup "Duplication" offset: [-10,5] width: 155 height:50
		checkBox makeCopy "Mirror as duplicate" pos:[9,65] checked:false 
		checkBox instanceCheck "Duplicate as instance" offset:[-4,-4] checked:false enabled:false
	groupbox rigChecksGroup "Rig Checks" offset: [-10,0] width: 155 height:70 					visible:true 
		checkBox flipLookatsCheck "Flip Lookat constraints" pos:[9,118] checked:true 			visible:true 
		checkBox flipNormalsCheck "Flip Geometry Normals" offset:[-4,-4] checked:false 			visible:true 
		checkBox autoBreakCheck "Auto Breakout Selection" offset:[-4,-4] checked:false 			visible:true 
	groupbox renameGroup "Renaming" offset: [-10,5] width: 155 height:95						visible:true 
		checkbox autoRenameCheck "Auto: 'Left' <=> 'Right'" pos:[9,190] checked:true 			visible:true 
		checkbox customRenameCheck "Custom rename" offset:[-4,-4] checked:false enabled:true 	visible:true 
		edittext changeFromBox "" offset:[-8,-2] width:70 enabled:false  						visible:true 
		edittext changeToBox "" offset:[70,-22] width:70 enabled:false 							visible:true 
		label labChange "to" offset:[0,-20] enabled:false 										visible:true 
		button previewRenamingButton "Preview renaming" height:20 width:145 alighn:#left 		visible:true

	-- Functions
	function setSearchPairs = -- sets the current search pairs based on ui choices
		(
		if autoRenameCheck.checked == true then(searchPairs = defaultSearchPairs)
		else(searchPairs = #(#(changeFromBox.text,changeToBox.text)))
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
			if (superclassof i) == GeometryClass and (classof i) != BoneGeometry
			then
				(
				curMods = i.modifiers
				flipped = false
				
				-- look through its modifiers
				for j in curMods do
					(
					-- Flip any existing normal modifers
					if (classof j) == Normalmodifier
					then(
						if j.flip == true
						then (j.flip = false) else (j.flip = true)
						flipped = true
						)
					else()
					)
				
				-- Put a flipped normal modifier on if no previous normal modifiers were found
				if flipped == false
				then
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
			global MirroRig_PreviewItemNames = namesArr
			
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
		objArr= undefined
		strArr=undefined
		failcount =0
		objArr = selection as array

		--Pass only if there are objects selected
		if objArr.count > 0 then
			(	
			-- Set the selected objects names to an array, and duplicate name array for processing
			strArr = #()
			for i in 1 to objArr.count do(join strArr #(objArr[i].name))
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
					if curStr != newStr then(newStrArr[i] = newStr)else(failCount = failcount+1) -- Add corrected pair to duplicate name array
					)
				)
				
			case modeArg of
				(
				1: (previewNameWindowFunction newStrArr) -- Rename the objects with the duplicate array
				2: (for i in 1 to objArr.count do(objArr[i].name = newStrArr[i])) -- Rename the objects with the duplicate array
				default: Print "error"
				)
			)
		)

	function duplicateEnableUIFunction bool =
		(
		if bool == true then (instanceCheck.enabled = true)else (instanceCheck.enabled = false)
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
				if subObjArr[i].parent == objArr[j] -- test to preserve
				then (preserveVar = true)
				)
			join preserveArr #(preserveVar)
			)	

		for i in 1 to subObjArr.count do
			(
			if preserveArr[i] == true then ()
			else(subObjArr[i].parent = undefined)
			)
		)
		
	function flipLookatsFunction objArrArg = -- searches for any lookat constraints and flips them 
		(
		objArr = objArrArg
		
		for i in 1 to objArr.count do
			(
			try
				(
				if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == off then (lookatVal = 1)else()
				if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == on then (lookatVal = 2)else()
				if(lookatVal ==1)then(objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = on)	else()
				if(lookatVal ==2)then(objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = off)	else()
				)
			catch()
			)
		)
		
	function informationFloaterFunction =
		(
		try(closerolloutfloater InformationDialog)catch()
		rollout InformationDialog "Mirror Rig info"
			(
			label labSpace1 "Mirror Rig version 1.0"
			hyperLink DTBLink "Mirror Rig Info" address:"http://www.aarondabelow.com/v1/pages/maxscript/maxscript-mirror_rig.html" align:#center
			hyperLink aaronDabelow "Aaron Dabelow" address:"http://aarondabelow.com/" align:#center
			label lab6 "theonlyaaron@gmail.com"
			label labSpace2 ""
			)
		createDialog InformationDialog 175 100
		)

	-- Main Function 
	function flipFunction objArrArg flipDirection =
		(
		objArr = objArrArg
			
		-- breaks out any parented objects if breakout enabled
		if autoBreakCheck.checked == true then (breakoutFunction objArr)
			
		-- makes a copy of the selection
		if makeCopy.checked == true
			then
			(
				if instanceCheck.checked == true
				then (maxOps.CloneNodes objArr actualNodeList:&objArr newNodes:&newArr cloneType:#instance)
				else (maxOps.CloneNodes objArr actualNodeList:&objArr newNodes:&newArr cloneType:#copy)
	 			resetNames objArr newArr
			)
			else()
			
		--rename the objects if enabled
		searchPairs = setSearchPairs()
		if autoRenameCheck.checked == true or customRenameCheck.checked == true then ( searchPairsBool = 2 ) else ( searchPairsBool = 1)
		renameObjectsFunction selection searchPairs searchPairsBool
		
		-- Actully do the FLIP!
		try(
		tempGroup = group selection name:"TempGroup"
		tempgroup.pivot = [0,0,0]
		scale tempgroup flipDirection
		ungroup tempGroup
		) catch (messagebox "Error: Not all of your selection is independent from outside objects, try enabling 'Auto Breakout' to automatically unparent any of these objects. WARNING! This will modify your hierarchy!")
		
		-- flips any lookat constraints if enabled
		if flipLookatsCheck.checked == true then (flipLookatsFunction objArr)
		if flipNormalsCheck.checked == true then (flipNormalsFunction objArr)

		clearUndoBuffer()
		)

	-- event handlers
	on mirrorXButton pressed do (try(flipFunction selection [-1,1,1])catch(messagebox "Unexpected Error."))
	on mirrorYButton pressed do (try(flipFunction selection [1,-1,1])catch(messagebox "Unexpected Error."))
	on mirrorZButton pressed do (try(flipFunction selection [1,1,-1])catch(messagebox "Unexpected Error."))
	on makeCopy changed state do (duplicateEnableUIFunction state)
	on autoRenameCheck changed state do (renamingEnableUIFunction 2)
	on customRenameCheck changed state do (renamingEnableUIFunction 1)
	on previewRenamingButton pressed do (setSearchPairs();renameObjectsFunction selection searchPairs 1)
)
AddSubRollout MakeToolbox.theSubrollout mirrorRigModule