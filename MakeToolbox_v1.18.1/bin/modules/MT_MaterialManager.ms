--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (10.9.2013):
--        1st version
--    - v1.1 (4.20.2021):
--        added xref material support
--*****************************************************

materialManagerModuleVer = 1.1
try(removeSubRollout MakeToolbox.theSubrollout materialManagerModule)catch()

-- creates the UI
rollout materialManagerModule ("Materials Manager v" + (materialManagerModuleVer as string))
	(
	groupbox grpMat ".mat" offset:[-5,0] width:150 height:90
		button buttonLoad "Load .mat" offset:[-1,((  grpMat.height * -1 ) + 10 )] width:70 height:20 align:#left tooltip:"Store a material on an object" --pos:[2,2]
		button buttonSave "Save .mat" offset:[35,-25]width:70 height:20 tooltip:"Save current objects material" --pos:[82,2] 
		button buttonReload "(re)apply .mat" offset:[0,00] width:140 height:20 tooltip:"Apply stored material to objects children" --pos:[2,22]
		edittext editTextStatus text:"ready" offset:[-2,0] align:#left width:120 readOnly:true tooltip:"Status" --pos:[20,43]
		button buttonStatusUpdate "R" offset:[60,-24] width:20 height:20 tooltip:"Report stored material" -- pos:[2,42]

	groupbox grpXref "X-ref + .mat" offset:[-5,5] width:150 height:105
		button buttonXrefSave "X-Ref Selected" offset:[-1,((  grpXref.height * -1 ) + 10 )] width:140 height:20 tooltip:"Creates xref and .mat of selected materials" --pos:[2,22]
		checkbox chkCreateSceneNodes "Create scene nodes" checked:true
		checkbox chkApplyToSrc "Apply to Src objects"
		edittext editTextXrefPath offset:[-2,0] align:#left width:120 readOnly:true tooltip:"X-ref export path" --pos:[20,43]
		button buttonXrefPathSet "..." offset:[60,-24] width:20 height:20 tooltip:"Report stored material" -- pos:[2,42]
		
-- functions
		
	-- Loads a material library file, and stores its path on the currently selected object
	fn FN_LoadMaterial =
	(
		(
			curFileName = getOpenFileName types:"Material(*.mat)|*.mat"
			editTextStatus.text = curFileName
			for i in 1 to selection.count do
			(
			setUserProp selection[i] "multiMaterial_file" curFileName
			)
		)
	)

	fn FN_SetXrefPath =
	(
		curFileName = getSaveFileName types:"Max(*.max)"
	)
	
	fn FN_SaveXrefMaterial =
	(
		print "---- Save xref material ----"

		if ( doesFileExist editTextXrefPath.text ) then 
		(
			print "path exists"
		)
		else
		(
			print "path does not exist"
		)

		if chkCreateSceneNodes.checked then
		(
			print "gen nodes"
		)

		if chkApplyToSrc.checked then 
		(
			print "apply to src"
		)
	)

	-- Save the currently selected objects material out at as a material library
	fn FN_SaveMaterial =
	(
		
		if selection.count != 1
		then(messagebox "Select exactly 1 object")
		else
		(
			theObj = selection[1]
			theMaterial = theObj.material
			
			-- Clear the temporary library and add the current material to it
			for i in 1 to currentMaterialLibrary.count do(deleteItem currentMaterialLibrary 1)
			loadDefaultMatLib()
			append currentMaterialLibrary theMaterial
			
			-- Get the save filename, and save the temporary library
			curFileName = undefined
			curFileName = getSaveFileName types:"Material(*.mat)|*.mat"
			if curFileName != undefined then
			(
				saveMaterialLibrary curFileName
				setUserProp selection[1] "multiMaterial_file" curFileName
			)else()
		)
	)

	-- Applies the stored material to the child nodes of that object
	fn FN_ReloadMaterial =
	(
		for j in 1 to selection.count do
		(
			if selection[j].parent == undefined then
			(
				try
				(
					multiMaterial_file = (getUserProp selection[j] "multiMaterial_file")
					
					for i in 1 to currentMaterialLibrary.count do(deleteItem currentMaterialLibrary 1)
					loadMaterialLibrary multiMaterial_file
					theMaterial = currentMaterialLibrary[1]
					-- print theMaterial	

					theObjects = selection[j].children

					for i in 1 to theObjects.count do
					(
					theObjects[i].material = theMaterial
					)
					
					selection[j].material = theMaterial
					
				)
				catch(messagebox ("No material library set for " + (selection[j].name) ))
			)
			else()
		)
	)

	-- Reads and reports the stored material in the UI
	fn FN_UpdateStatus =
	(
		-- For 1 object, print the stored material library, if there is one
		if selection.count == 1 then
		(
			try
			(
				multiMaterial_file = (getUserProp selection[1] "multiMaterial_file")
				editTextStatus.text = multiMaterial_file
			)
			catch
			(
				editTextStatus.text = "no material stored"
			)
		)
		
		-- For more than 1 objects, report how many objects have valid libraries stored
		if selection.count > 1 then
		(
			goodCount = 0
			
			for i in 1 to selection.count do
			(
			multiMaterial_file = (getUserProp selection[i] "multiMaterial_file")
			if multiMaterial_file != undefined then (goodcount = (goodcount + 1))
			)	
			editTextStatus.text = ((goodcount as string) + " of " +(selection.count as string) + " have valid data")
		)
		
		-- Tell the user to get their game together
		if selection.count == 0 then
		(
			editTextStatus.text = "please select an object"
		)
	)

-- event handlers
	on buttonLoad pressed do (FN_LoadMaterial();FN_ReloadMaterial())
	on buttonSave pressed do (FN_SaveMaterial())
	on buttonReload pressed do (FN_ReloadMaterial())
	on buttonStatusUpdate pressed do (FN_UpdateStatus())
	on buttonXrefSave pressed do (FN_SaveXrefMaterial())
	on buttonXrefPathSet pressed do (FN_SetXrefPath())
)

AddSubRollout MakeToolbox.theSubrollout materialManagerModule



----------------------
targetDir = @"Y:\Projects\Paw Patrol F21 TVCs\Tests\AD\xRef_Materials"
generateObjects = false

selArr = selection as array 

for sel in selArr do 
(
	curMat = sel.material
	curName = curMat.name
	newMat = ( copy curMat )
	newName = ( curName + "_xRef" )
	newMat.name = newName 

	print newMat 

	newBox = Box()
	newBox.material = newMat
	newBox.name = newName

	exportPath = ( targetDir + @"\" + curName + ".max")
	saveNodes newBox exportPath quiet:true
	delete newBox


	curXref = xrefs.addNewXRefObject exportPath newName modifiers:#drop manipulators:#merge dupMtlNameAction:#useXRefed reparentAction:#neverReparent
	print curXref.material 

	curXrefMat = curXref.material 
	
	-- Clear the temporary library and add the current material to it
	for i in 1 to currentMaterialLibrary.count do(deleteItem currentMaterialLibrary 1)
	loadDefaultMatLib()
	append currentMaterialLibrary curXrefMat
	
	exportPath = ( targetDir + @"\" + curName + ".mat")
	saveMaterialLibrary exportPath

	if generateObjects == false then ( delete curXref )
	else()
)