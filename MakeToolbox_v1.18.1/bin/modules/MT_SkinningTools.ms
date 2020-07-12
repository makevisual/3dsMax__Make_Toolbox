/*
#NAME:Skinning Tools
#VERSION:1.0
#INSTRUCTIONS:
Rigid skin a mesh to one bone or object
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:06.6.2012 >> Integrated into MakeToolBox
#HISTORY:06.11.2012 >> re-enabled the viewport during operation
#HISTORY:06.11.2012 >> added checkbox for regular parenting too
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (6.6.2012):
--        1st version
--    - v1.1 (6.11.2012):
--        re-enabled the viewport during operation
--		added checkbox for regular parenting too
--    - v1.1 (11.17.2017):
--	  added convert parent to skin thing
--*****************************************************

skinningToolsModuleVer = 1.3
try(removeSubRollout MakeToolbox.theSubrollout skinningToolsModule)catch()

-- creates the UI
rollout skinningToolsModule ("Skinning Tools v" + (skinningToolsModuleVer as string))
(
groupbox skinParent "Skin Parent" pos:[2,2] width:160 height:60
button skinParentButton "Skin Parent" offset:[-6,-50] width:150 tooltip:"Skin a mesh to an object instead of parent it, The final object selected will be the 'parent'." align:#left
button skinReParentButton "Convert parent to skin" offset:[-6,0] width:150 align:#left
checkbox parentCheckbox "Parent object as well" checked:off offset:[-5,0]

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
					if queryBox (theString) == true then ()else(exit())
					)
				-- parents the object to the paretnt, if selected
				if parentCheckbox.checked == true then (childObj.parent = parentObj)else()
				)
			select parentObj
			)catch
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
		try ( skinReparentFunction i ) catch ()
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