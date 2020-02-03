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
--    - v1.0 (8.12.2013):
--		Added clone / instance ability - ad
--*****************************************************

try(removeSubRollout MakeToolbox.theSubrollout mirrorRigModule)catch()

-- creates the UI
rollout mirrorRigModule "Mirror Rig"
(
button mirrorXButton "Mirror X" pos:[2,2] width:53 tooltip:"Flip your selection using world X axis."
button mirrorYButton "Mirror Y" pos:[55,2] width:53  tooltip:"Flip your selection using world Y axis."
button mirrorZButton "Mirror Z" pos:[108,2] width:53 tooltip:"Flip your selection using world Z axis."
checkBox makeCopy "Duplicate" offset:[-6,0] checked:true --"Make Copy"
checkBox flipLookats "Flip Lookats" offset:[72,-20] checked:true
checkBox checkboxInstance "Instance" offset:[-6,-2] checked:false enabled:true

function flipFunction flipDirection =
	(
	-- makes a copy of the selection
	case checkboxInstance.checked of
		(
		false: cloneType = #copy
		true: cloneType = #instance
		)
	
	print cloneType
		
	if makeCopy.checked == true then(maxOps.CloneNodes selection cloneType:cloneType)else()
		
	tempGroup = group selection name:"TempGroup"
	tempgroup.pivot = [0,0,0]
	scale tempgroup flipDirection
	ungroup tempGroup
	
	--flips the lookats
	if flipLookats.checked == true then
		(
		for i in 1 to selection.count do
			(
			try
				(
				if selection[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == off then (lookatVal = 1)else()
				if selection[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == on then (lookatVal = 2)else()
				if(lookatVal ==1)then(selection[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = on)	else()
				if(lookatVal ==2)then(selection[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = off)	else()
				)
			catch()
			)
		)else()
		
	clearUndoBuffer()
	)

-- button event handlers
on mirrorXButton pressed do (try(flipFunction  [-1,1,1])catch(messagebox "You must make a valid selection."))
on mirrorYButton pressed do (try(flipFunction  [1,-1,1])catch(messagebox "You must make a valid selection."))
on mirrorZButton pressed do (try(flipFunction  [1,1,-1])catch(messagebox "You must make a valid selection."))
on makeCopy changed stated do (if makeCopy.checked == true then (checkboxInstance.enabled = true)else(checkboxInstance.enabled = false))
)
AddSubRollout MakeToolbox.theSubrollout mirrorRigModule