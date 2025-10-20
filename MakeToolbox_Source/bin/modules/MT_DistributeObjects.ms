/*
--**********************************************************************************--
--                                                                                  --
--                              DISTRIBUTE OBJECTS                               	--
--                                                                                  --
--**********************************************************************************--

#NAME: Distribute Objects
#VERSION: 1.1
#LAST UPDATED: 2025.08.11

#DESCRIPTION:
A utility to evenly space selected objects along a specified axis (X, Y, or Z) 
using a defined offset value.

#INSTRUCTIONS:
Select two or more objects, choose the distribution axis and offset value, then 
click "Distribute Objects". Enable "RT" for real-time feedback when adjusting the 
offset.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Distribute_Objects

#CREDITS:
    #Author: Neil Barck (neil.barck@makevisual.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): UI/UX improvements and real-time functionality.

#HISTORY:
    - v1.1 (2025.08.11): Added real-time feedback, axis selection, and tooltips.
    - v1.0 (2011.03.13): Initial release and integration into MakeToolbox.

--**********************************************************************************--
*/
DistributeObjectsModuleVer = ""
try(removeSubRollout MakeToolbox.theSubrollout DistributeObjectsModule)catch()

rollout DistributeObjectsModule ("Distribute Object" + (DistributeObjectsModuleVer as string))
(
	local Distribution_Axis = [1,0,0]
	button Btn_SpaceObjects "Distribute Objects" width:160 height:20 offset:[0,-3] tooltip:"Click to distribute objects across the specified axis and according to the offset value"
	radiobuttons Axis_RadioButton labels:#("X", "Y", "Z") tooltip:"Axis to distribute objects"
	checkbutton RealTimeSpinner "RT" height:20 offset:[-10,0] checked:true tooltip:"Enable real-time feedback on offset value change" across:2
	spinner Spn_SpaceOffest "Offset:" range:[0,10000,10] width:90 offset:[-30,2] tooltip:"Offset value used to distribute the selected objects"
	function Distribute_Objects DistObjects DistValue DistAxis =
	(
		for i = 1 to DistObjects.count do
		(
			DistObjects[i].position = [((i-1) * DistValue),((i-1) * DistValue),((i-1) * DistValue)]*DistAxis
		)
	)
	on Axis_RadioButton changed state do
	(
		case state of
		(
			(1):(Distribution_Axis = [1,0,0])
			(2):(Distribution_Axis = [0,1,0])
			(3):(Distribution_Axis = [0,0,1])
		)
		if selection.count > 1 do
		(
			Distribute_Objects (selection as array) Spn_SpaceOffest.value Distribution_Axis
		)
	)
	on Btn_SpaceObjects pressed do
	(
		if selection.count > 1 then
		(
			Distribute_Objects (selection as array) Spn_SpaceOffest.value Distribution_Axis
		)
		else
		(
			messagebox "Select 2 or more objects"
		)
	)
	on Spn_SpaceOffest changed val do
	(
		if RealTimeSpinner.checked do
		(
			if selection.count > 1 then 
			(
				Distribute_Objects (selection as array) val Distribution_Axis
			)
			else
			(
				messagebox "Select 2 or more objects"
			)
		)
		
	)
)
AddSubRollout MakeToolbox.theSubrollout DistributeObjectsModule