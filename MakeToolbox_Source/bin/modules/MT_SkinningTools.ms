/*
--**********************************************************************************--
--                                                                                  --
--                                 SKINNING TOOLS                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Skinning Tools
#VERSION: 1.4
#LAST UPDATED: 2025.09.29

#DESCRIPTION:
A utility for quickly applying rigid skinning to objects. It allows a user to skin 
one or more child objects to a single parent object or convert an existing 
parent-child hierarchy into a skinned one.

#INSTRUCTIONS:
To skin objects: Select the child object(s) first, then select the parent object last, 
and click "Skin Parent".
To convert a parented object: Select the child object and click "Convert parent to skin".
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Skinning_Tools

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): UI layout and tooltip updates.

#HISTORY:
    - v1.4 (2025.09.29): UI layout fixing and tooltip updating.
    - v1.1 (2017.11.17): Added "Convert parent to skin" functionality.
    - v1.1 (2012.06.11): Re-enabled viewport during operation and added parenting checkbox.
    - v1.0 (2012.06.06): Initial integration into MakeToolbox.

--**********************************************************************************--
*/

skinningToolsModuleVer = 1.4
try(removeSubRollout MakeToolbox.theSubrollout skinningToolsModule)catch()

-- creates the UI
rollout skinningToolsModule ("Skinning Tools v" + (skinningToolsModuleVer as string))
(
groupbox skinParent "Skin Parent" pos:[2,2] width:160 height:70
button skinParentButton "Skin Parent" offset:[-6,-60] width:150 tooltip:"Skin a mesh to an object instead of parent it, The final object selected will be the 'parent'." align:#left
button skinReParentButton "Convert parent to skin" offset:[-6,0] width:150 align:#left tooltip:"Skin the children to its parent"
checkbox parentCheckbox "Parent object as well" checked:off offset:[-5,5]

-- function for rigid skinning objects, and parenting them
	function skinParentFunction CurrentSelection parentObj = 
	(
		undo on
		(
			try
			(
				max modify mode
				-- loops the passed selection, skipping the last one (parent)
				for i in 1 to (selection.count - 1) do
				(
					childObj = CurrentSelection[i]
				
					-- tests to pass only geometry objects
					if childObj.superClassID == 16 then
					(
						modPanel.setCurrentObject childObj.baseObject
						modPanel.addModToSelection (Skin ()) ui:on
						skinOps.addBone childObj.modifiers[#Skin] parentObj 1
						childObj.modifiers[#Skin].cross_radius = 1
					)
					-- catch for non - skinnable objects
					else
					(
						theString = ("Object: "+ childObj.name +" is not a mesh, no skin applied. Would you like to continue?")
						if queryBox (theString) == true then
						(

						)
						else
						(
							exit()
						)
					)
					-- parents the object to the paretnt, if selected
					if parentCheckbox.checked == true then
					(
						childObj.parent = parentObj
					)
					else()
				)
				select parentObj
			)
			catch
			(
				-- catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)

	function skinReparentFunction obj =
	(
		curObj = obj
		
		if curObj.parent != undefined then
		(	
			curParent = obj.parent
			
			-- tests to pass only geometry objects
			if curObj.superClassID == 16 then
			(
				modPanel.setCurrentObject curObj.baseObject
				modPanel.addModToSelection (Skin ()) ui:on
				skinOps.addBone curObj.modifiers[#Skin] curParent 1
				curObj.modifiers[#Skin].cross_radius = 1
			)
			-- catch for non - skinnable objects
			else
			(
				theString = ("Object: "+ curObj.name +" is not a mesh, no skin applied. Would you like to continue?")
				if queryBox (theString) == true then ()else(exit())
			)
		)
	)
		
	on skinReParentButton pressed do
	(
		selArr = ( selection as array )
		
		for i in selArr do
		(
			try
			(
				skinReparentFunction i
			)
			catch()
		)	
	)
		
	-- the button
	on skinParentButton pressed do
	(
		-- checks selection for at least two objects
		if selection.count >= 2 then
		(
			-- gets the parent out of the array (last obj)
			childOBJ = selection as array
			parentOBJ = selection[Selection.count]
			skinParentFunction childOBJ parentOBJ
		)
		else
		(
		-- promps user to make valid selecton
		messagebox "You must select at least two objects, first child(ren) and then the parent."
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout skinningToolsModule