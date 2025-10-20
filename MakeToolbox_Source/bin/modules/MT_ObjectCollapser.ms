/*
--**********************************************************************************--
--                                                                                  --
--                                OBJECT COLLAPSER                                	--
--                                                                                  --
--**********************************************************************************--

#NAME: Object Collapser
#VERSION: 1.0
#LAST UPDATED: 2025.02.25

#DESCRIPTION:
A utility to collapse the modifier stack of selected objects, including any applied
World Space Modifiers, into their base geometry (e.g., Editable Poly, Editable Spline).

#INSTRUCTIONS:
Select one or more objects with modifiers and click the "Collapse Objects" button.
The tool will collapse the stack for each valid object (geometry or shapes).
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Object_Collapser

#CREDITS:
    #Author: David Almeida (davidcalmeida@gmail.com)

#HISTORY:
    - v1.0 (2025.02.25): Initial development and release.

--**********************************************************************************--
*/
ObjectcollapserToolModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout ObjectcollapserToolModule)catch()

-- creates the UI
rollout ObjectcollapserToolModule ("Object Collapser " + (ObjectcollapserToolModuleVer as string))
(	
	button ObjCollapser "Collapse Objects" pos:[2,2] width:160 tooltip:"Collapse the Stack of selected objects" align:#left
-- function for collapsing all selected objects
	function ObjCollapserFunction Nd = 
	(
		undo on
		(
			try
			(
				maxops.collapsenodeto Nd 1 on
			)
			catch
			(
				--catches any errors
				messagebox "Unexpected error, please try again."
			)
		)
	)
	-- the buttons
	on ObjCollapser pressed do
	(
		if selection.count > 0 then
		(
			for i in selection do
			(
				if ((superclassof i == GeometryClass) OR (superclassof i == shape)) AND (i.modifiers.count > 0) do
				(
					ObjCollapserFunction i
				)
			)
		)
		else
		(
			messagebox "Select one or more objects."
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout ObjectcollapserToolModule