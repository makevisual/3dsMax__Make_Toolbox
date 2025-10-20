/*
--**********************************************************************************--
--                                                                                  --
--                               MATERIALS MANAGER                                	--
--                                                                                  --
--**********************************************************************************--

#NAME: Materials Manager
#VERSION: 1.0
#LAST UPDATED: 2013.10.09

#DESCRIPTION:
A utility for saving an object's material to a library file (.mat) and storing the 
file path within the object's User Properties. This allows for easy reloading and 
application of the material to the object and its hierarchy.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Material_Manager

#INSTRUCTIONS:
Select an object to work with.
- "Save material": Saves the selected object's material to a .mat file and links the path.
- "Load material": Links an existing .mat file to the selected object(s).
- "(re)apply material": Applies the linked material to the selected object and its children.
- "R": Reports the linked .mat file path in the status text field.

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)

#HISTORY:
    - v1.0 (2013.10.09): Initial release.

--**********************************************************************************--
*/

materialManagerModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout materialManagerModule)catch()

-- creates the UI
rollout materialManagerModule ("Materials Manager v" + (materialManagerModuleVer as string))
	(
	button buttonLoad "Load material" pos:[2,2] width:80 height:20 tooltip:"Applies a material on an object and stores the material path on its UserProperties"
	button buttonSave "Save material" pos:[82,2] width:80 height:20 tooltip:"Saves the current object's material and stores the material path on its UserProperties"
	button buttonReload "(re)apply material" pos:[2,22] width:160 height:20 tooltip:"Apply stored material to selected object's children"
	button buttonStatusUpdate "R"  pos:[2,42] width:20 height:20 tooltip:"Report stored material"
	edittext editTextStatus text:"ready" pos:[20,43] align:#left width:140 readOnly:true tooltip:"Status"
		
-- functions
		
	-- Loads a material library file, and stores its path on the currently selected object
	fn FN_LoadMaterial =
	(
-- 		if selection.count != 1
-- 		then(messagebox "Select exactly 1 object")
-- 		else
		(
			curFileName = getOpenFileName types:"Material(*.mat)|*.mat"
			editTextStatus.text = curFileName
			for i in 1 to selection.count do
			(
			setUserProp selection[i] "multiMaterial_file" curFileName
			)
		)
	)
		
	-- Save the currently selected objects material out at as a material library
	fn FN_SaveMaterial =
	(
		clearlistener()
		
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
					print theMaterial	

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
		
)

AddSubRollout MakeToolbox.theSubrollout materialManagerModule