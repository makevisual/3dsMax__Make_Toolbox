/*
#NAME:ObjectCollapser
#VERSION:0.10
#INSTRUCTIONS:Collapse all selected objects, including any applied World Space Modifiers
#SOURCE:David Almeida, davidcalmeida@gmail.com
#HISTORY:02.25.2025 >> Start Development
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
ObjectcollapserToolModuleVer = 0.1
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
				if (superclassof i == GeometryClass) AND (i.modifiers.count > 0) do
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