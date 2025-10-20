/*
--**********************************************************************************--
--                                                                                  --
--                                 LOCK TRANSFORMS                                  --
--                                                                                  --
--**********************************************************************************--

#NAME: Lock Transforms
#VERSION: 1.4
#LAST UPDATED: 2025.12.08

#DESCRIPTION:
A utility to quickly lock or unlock the transforms of selected objects, all scene 
objects, or just cameras. Provides advanced per-axis control with real-time UI 
feedback on the lock state of the current selection.

#INSTRUCTIONS:
Select object(s) and use the "Lock/Unlock" buttons to toggle all transform locks.
Click the "more" button to access individual toggles for each transform axis (Move, 
Rotate, Scale).
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Lock_Transforms

#CREDITS:
    #Authors: 
        - Romain Faure (rf.romainfaure@gmail.com)
        - Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): UI/UX revamp and code modernization.

#HISTORY:
    - v1.4 (2025.12.08): Revamped UI to be fully interactive with real-time feedback and tri-state checkboxes. Added wirecolor saving/restoring and removed global variables.
    - v1.3 (2014.01.08): Added visibility toggle to custom locks.
    - v1.2 (2012.03.05): Added global and class (un)lock options.
    - v1.1 (2012.03.02): Integrated into MakeToolbox.
    - v1.01 (2012.02.26): UI Update.
    - v1.0 (2011.05.12): Initial release.

--**********************************************************************************--
*/
lockTransformsModuleVer = 01.4
try(removeSubRollout MakeToolbox.theSubrollout lockTransformsModule)catch()
rollout lockTransformsModule ("Lock Transforms " + (lockTransformsModuleVer as string))
(
	local
	TriggeredBySel = true,
	MT_camerasLockToggle = false,
	MT_objectsLockToggle = false,
	customLocksVisTog = false,
	TransformFlags,
	TransformCheckbutton,
	TransformCheckbuttonTrueColors,
	TransformCheckbuttonTristateColors,
	PosTrueColor = (color 240 73 51),
	PosTristateColor = (color 141 45 33),
	RotTrueColor = (color 10 157 93),
	RotTristateColor = (color 7 100 60),
	SclTrueColor = (color 95 138 193),
	SclTristateColor = (color 48 87 135),
	MoveXValue = true,
	MoveYValue = true,
	MoveZValue = true,
	RotateXValue = true,
	RotateYValue = true,
	RotateZValue = true,
	ScaleXValue = true,
	ScaleYValue = true,
	ScaleZValue = true
	-- the UI
	groupbox lockUnlockGroupbox "Lock / Unlock" width:158 height:55 offset:[-11,-3] 
	button lockCameras "Lock Cams" width:76 height:20  align:#left offset:[-7,(-1*lockUnlockGroupbox.height +8)] tooltip:"Lock or Unlock all cameras in the scene."
	button lockObjects "Lock Objects" width:76 height:20 align:#left offset:[69,-25] tooltip:"Lock or Unlock all objects in the scene."
	checkbox selectionCheckBox "Selection only" offset:[-7,-3] checked:true tooltip:"Lock/Unlock buttons only affect the selected objects."
	button manualLocksToggle "more" height:18 width:35 align:#left offset:[110,-20] tooltip:"Toggles per transform axis lock/unlock."
	
	groupbox manualLocksGroup "Custom Locks" width:160 height:140 pos:[2,60] visible:customLocksVisTog --offset:[-11,0]
	
	groupbox moveLocksGroup "Move" offset:[-7,-130] width:152 height:40 visible:customLocksVisTog
	checkbutton moveLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-30] tooltip:"Locks/unlocks move X." highlightColor:PosTrueColor checked:MoveXValue visible:customLocksVisTog
	checkbutton moveLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] tooltip:"Locks/unlocks move Y." highlightColor:PosTrueColor checked:MoveYValue visible:customLocksVisTog
	checkbutton moveLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] tooltip:"Locks/unlocks move Z." highlightColor:PosTrueColor checked:MoveZValue visible:customLocksVisTog
	button moveLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Locks/unlocks all move tranforms (XYZ)." visible:customLocksVisTog
	

	groupbox rotateLocksGroup "Rotate" offset:[-7,0] width:152 height:40 visible:customLocksVisTog	
	checkbutton rotateLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-30] tooltip:"Locks/unlocks rotate X." highlightColor:RotTrueColor checked:RotateXValue visible:customLocksVisTog
	checkbutton rotateLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] tooltip:"Locks/unlocks rotate Y." highlightColor:RotTrueColor checked:RotateYValue visible:customLocksVisTog
	checkbutton rotateLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] tooltip:"Locks/unlocks rotate Z." highlightColor:RotTrueColor checked:RotateZValue visible:customLocksVisTog
	button rotateLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Locks/unlocks all rotation tranforms (XYZ)." visible:customLocksVisTog
	
	
	groupbox scaleLocksGroup "Scale" offset:[-7,0] width:152 height:40 visible:customLocksVisTog
	checkbutton scaleLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-30] tooltip:"Locks/unlocks scale X." highlightColor:SclTrueColor checked:ScaleXValue visible:customLocksVisTog
	checkbutton scaleLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] tooltip:"Locks/unlocks scale Y." highlightColor:SclTrueColor checked:ScaleYValue visible:customLocksVisTog
	checkbutton scaleLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] tooltip:"Locks/unlocks scale Z." highlightColor:SclTrueColor checked:ScaleZValue visible:customLocksVisTog
	button scaleLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Locks/unlocks all scale tranforms (XYZ)." visible:customLocksVisTog
	
	
	--button customLocksButton "Apply to selection" width:152 align:#left offset:[-7,2] height:20 tooltip:"Set transforms to selection." visible:customLocksVisTog
	function FN_LoadObjWireColor SelectedObjects =
	(
		if SelectedObjects.count != 0 do
		(
			for obj in SelectedObjects do
			(
				if (getUserProp obj "Make_Wirecolor") != undefined do
				(
					NewWireColor = (execute (getUserProp obj "Make_Wirecolor"))
					if TriggeredBySel == false do
					(
						obj.wirecolor = NewWireColor
					)
				)
			)
		)
		TriggeredBySel = false
	)
	function FN_BakeObjWireColor SelectedObjects =
	(
		if SelectedObjects.count != 0 do
		(
			for obj in SelectedObjects do
			(
				if (getUserProp obj "Make_Wirecolor") == undefined do
				(
					setUserProp obj "Make_Wirecolor" obj.wirecolor
				)
			)
			if TriggeredBySel == false do
			(
				SelectedObjects.wirecolor = red
			)
		)
		TriggeredBySel = false
	)
	function Highlight_Color_Update CheckButtonUI CheckButtonColor CheckedStatus =
	(
		CheckButtonUI.highlightColor = CheckButtonColor
		CheckButtonUI.checked = NOT CheckedStatus
		CheckButtonUI.checked = CheckedStatus
	)
	function TransformLocks_Update =
	(	
		TransformFlags = #(0,0,0,0,0,0,0,0,0)
		TransformCheckbutton = #(moveLocksXButton, moveLocksYButton, moveLocksZButton, rotateLocksXButton, rotateLocksYButton, rotateLocksZButton, scaleLocksXButton, scaleLocksYButton, scaleLocksZButton)
		TransformCheckbuttonTrueColors = #(PosTrueColor, PosTrueColor, PosTrueColor, RotTrueColor, RotTrueColor, RotTrueColor, SclTrueColor, SclTrueColor, SclTrueColor)
		TransformCheckbuttonTristateColors = #(PosTristateColor, PosTristateColor, PosTristateColor, RotTristateColor, RotTristateColor, RotTristateColor, SclTristateColor, SclTristateColor, SclTristateColor)
		for i in selection do
		(
			for j in (GetTransformLockFlags i) do
			(
				TransformFlags[j] += 1
			)
		)
		LockedTransforms = false
		for i = 1 to TransformFlags.count do
		(
			if TransformFlags[i] != 0 then
			(
				if TransformFlags[i] == selection.count then
				(
					Highlight_Color_Update TransformCheckbutton[i] TransformCheckbuttonTrueColors[i] true
					LockedTransforms = true
				)
				else
				(
					Highlight_Color_Update TransformCheckbutton[i] TransformCheckbuttonTristateColors[i] true
					LockedTransforms = true
				)
			)
			else
			(
				Highlight_Color_Update TransformCheckbutton[i] TransformCheckbuttonTrueColors[i] false
			)
		)
		if LockedTransforms then
		(
			FN_BakeObjWireColor (selection as array)
		)
		else
		(
			FN_LoadObjWireColor (selection as array)
		)
	)
	function FN_CheckButton_Enabler =
	(
		if selection.count != 0 then
		(
			for currentCheckButton in TransformCheckbutton do
			(
				currentCheckButton.enabled = true
			)
		)
		else
		(
			for currentCheckButton in TransformCheckbutton do
			(
				currentCheckButton.enabled = false
			)
		)
	)
	function MK_Callback_SelectionChange =
	(
		TriggeredBySel = true
		TransformLocks_Update()
		FN_CheckButton_Enabler()
	)
	fn LockSelection SelectedTransformFlags AxisNumber =
	(
		GetSelectionTransforms = #{}	
		if selection.count != 0 then 
		(
			for obj in selection do
			(
				CurrentTransformFlags = (getTransformLockFlags obj) + SelectedTransformFlags
				if SelectedTransformFlags.count == 0 do
				(
					for CurrentAxis in AxisNumber do
					deleteItem CurrentTransformFlags CurrentAxis
				)
				for i = 1 to 9 do
				(
					if CurrentTransformFlags[i] then(append GetSelectionTransforms i) else (deleteItem GetSelectionTransforms i)
				)
				/*
				if CurrentTransformFlags[1] then(append GetSelectionTransforms 1) else (deleteItem GetSelectionTransforms 1)
				if CurrentTransformFlags[2] then(append GetSelectionTransforms 2) else (deleteItem GetSelectionTransforms 2)
				if CurrentTransformFlags[3] then(append GetSelectionTransforms 3) else (deleteItem GetSelectionTransforms 3)
				if CurrentTransformFlags[4] then(append GetSelectionTransforms 4) else (deleteItem GetSelectionTransforms 4)
				if CurrentTransformFlags[5] then(append GetSelectionTransforms 5) else (deleteItem GetSelectionTransforms 5)
				if CurrentTransformFlags[6] then(append GetSelectionTransforms 6) else (deleteItem GetSelectionTransforms 6)
				if CurrentTransformFlags[7] then(append GetSelectionTransforms 7) else (deleteItem GetSelectionTransforms 7)
				if CurrentTransformFlags[8] then(append GetSelectionTransforms 8) else (deleteItem GetSelectionTransforms 8)
				if CurrentTransformFlags[9] then(append GetSelectionTransforms 9) else (deleteItem GetSelectionTransforms 9)
				*/
				setTransformLockFlags obj GetSelectionTransforms
			)
			TransformLocks_Update()
		)
		else
		(
			messageBox ("No Object(s) Selected")
		)
	)
	--fn Ltapply =
	--(
	--	LockSelection()
	--)
	function lockAllFunction SelectedObjects =
	(
		setTransformLockFlags SelectedObjects #all
		TransformLocks_Update()
	)
	function unlockAllFunction SelectedObjects =
	(
		setTransformLockFlags SelectedObjects #none
		TransformLocks_Update()
	)
	fn FN_ToggleCustLocksUI =
	(
		visArr = #(manualLocksGroup, moveLocksGroup, moveLocksXButton, moveLocksYButton, moveLocksZButton, moveLocksTButton, rotateLocksGroup, rotateLocksXButton, rotateLocksYButton, rotateLocksZButton, rotateLocksTButton, scaleLocksGroup, scaleLocksXButton, scaleLocksYButton, scaleLocksZButton, scaleLocksTButton) --,customLocksButton)
		for i in 1 to visArr.count do
		(
			visArr[i].visible = customLocksVisTog
		)
		manualLocksGroup
	)
	on lockCameras pressed do
	(
		SceneCameras = selection as array
		undo on
		(
			disablesceneredraw()
			if MT_camerasLockToggle == false then
			(
				if selectionCheckBox.checked == false do
				(
					SceneCameras = cameras as array
				) 
				if SceneCameras.count != 0 then
				(
					FN_BakeObjWireColor SceneCameras
					lockAllFunction SceneCameras
					MT_camerasLockToggle = true
					lockCameras.text = "Unlock Cams"
				)
				else
				(
					messagebox "Select one or more cameras"
				)
			)
			else
			(
				if selectionCheckBox.checked == false do
				(
					SceneCameras = cameras as array
				)
				if SceneCameras.count != 0 then
				(
					FN_LoadObjWireColor SceneCameras
					unlockAllFunction SceneCameras
					MT_camerasLockToggle = false
					lockCameras.text = "Lock Cams"
				)
				else
				(
					messagebox "Select one or more cameras"
				)
			)
			--select tempSelection
			enablesceneredraw()
			redrawviews()
		)
	)
	on lockObjects pressed do
	(
		SceneObjects = selection as array
		undo on
		(
			disablesceneredraw()
			if MT_objectsLockToggle == false then
			(
				if selectionCheckBox.checked == false do
				(
					SceneObjects = Objects as array
				)
				if SceneObjects.count != 0 then
				(
					FN_BakeObjWireColor SceneObjects
					lockAllFunction SceneObjects
					MT_objectsLockToggle = true
					lockObjects.text = "Unlock Objects"
				)
				else
				(
					messagebox "Select one or more objects"
				)
			)
			else
			(
				if selectionCheckBox.checked == false do
				(
					SceneObjects = Objects as array
				) 
				if SceneObjects.count != 0 then
				(
					FN_LoadObjWireColor SceneObjects
					unlockAllFunction SceneObjects
					MT_objectsLockToggle = false
					lockObjects.text = "Lock Objects"
				)
				else
				(
					messagebox "Select one or more objects"
				)
			)
			--select tempSelection
			enablesceneredraw()
			redrawviews()
		)
	)
	on manualLocksToggle pressed do 
	(
		if customLocksVisTog == true then
		(
			customLocksVisTog = false
 			--manualLocksGroup.pos = [0,-1000]
			manualLocksToggle.text = "more"
			lockTransformsModule.height = 65
			TransformLocks_Update()
			FN_CheckButton_Enabler()
		)
		else
		(
			customLocksVisTog = true
 			--manualLocksGroup.pos = [2,60]
			manualLocksToggle.text = "less"
			lockTransformsModule.height = 206
			TransformLocks_Update()
			FN_CheckButton_Enabler()
		)
		FN_ToggleCustLocksUI()
	)
	on moveLocksXButton changed state do
	(
		if state then ( LockSelection #{1} #(1) ) else ( LockSelection #{} #(1) )
	)
	on moveLocksYButton changed state do
	(
		if state then ( LockSelection #{2} #(2) ) else ( LockSelection #{} #(2) )
	)
	on moveLocksZButton changed state do
	(
		if state then ( LockSelection #{3} #(3) ) else ( LockSelection #{} #(3) )
	)
	on moveLocksTButton pressed do 	
	(
		if moveLocksXButton.checked and moveLocksYButton.checked and moveLocksZButton.checked then
		(
			moveLocksXButton.state = false
			moveLocksYButton.state = false
			moveLocksZButton.state = false
			MoveXValue = false
			MoveYValue = false
			MoveZValue = false
			LockSelection #{} #(1,2,3)
		)
		else 
		(
			moveLocksXButton.state = true
			moveLocksYButton.state = true
			moveLocksZButton.state = true
			MoveXValue = true
			MoveYValue = true
			MoveZValue = true
			LockSelection #{1..3} #(1,2,3)
		)
	)
	on rotateLocksXButton changed state do
	(
		if state then ( LockSelection #{4} #(4) ) else ( LockSelection #{} #(4) )
	)
	on rotateLocksYButton changed state do
	(
		if state then ( LockSelection #{5} #(5) ) else ( LockSelection #{} #(5) )
	)
	on rotateLocksZButton changed state do
	(
		if state then ( LockSelection #{6} #(6) ) else ( LockSelection #{} #(6) )
	)
	on rotateLocksTButton pressed do 	
	(
		if rotateLocksXButton.checked and rotateLocksYButton.checked and rotateLocksZButton.checked then
		(
			rotateLocksXButton.state = false
			rotateLocksYButton.state = false
			rotateLocksZButton.state = false
			RotateXValue = false
			RotateYValue = false
			RotateZValue = false
			LockSelection #{} #(4,5,6)
		)
		else 
		(
			rotateLocksXButton.state = true
			rotateLocksYButton.state = true
			rotateLocksZButton.state = true
			RotateXValue = true
			RotateYValue = true
			RotateZValue = true
			LockSelection #{4..6} #(4,5,6)
		)
	)
	on scaleLocksXButton changed state do
	(
		if state then ( LockSelection #{7} #(7) ) else ( LockSelection #{} #(7) )
	)
	on scaleLocksYButton changed state do
	(
		if state then ( LockSelection #{8} #(8) ) else ( LockSelection #{} #(8) )
	)
	on scaleLocksZButton changed state do
	(
		if state then ( LockSelection #{9} #(9) ) else ( LockSelection #{} #(9) )
	)
	on scaleLocksTButton pressed do  
	(
		if scaleLocksXButton.checked and scaleLocksYButton.checked and scaleLocksZButton.checked then
		(
			scaleLocksXButton.state = false
			scaleLocksYButton.state = false
			scaleLocksZButton.state = false
			ScaleXValue =  false
			ScaleYValue =  false
			ScaleZValue =  false
			LockSelection #{} #(7,8,9)
		) 
		else
		(
			scaleLocksXButton.state = true
			scaleLocksYButton.state = true
			scaleLocksZButton.state = true
			ScaleXValue =  true
			ScaleYValue =  true
			ScaleZValue =  true
			LockSelection #{7..9} #(7,8,9)
		)
	)
	--on customLocksButton pressed do
	--(
	--	Ltapply()
	--)
	on lockTransformsModule open do
	(
		print "Open"
		lockTransformsModule.height = 65
		callbacks.addScript #selectionSetChanged "lockTransformsModule.MK_Callback_SelectionChange()" id:#MakeToolBoxLockTransformsID001
		print "Selection Check callback registered"
		TransformLocks_Update()
	)
	on lockTransformsModule close do
	(
		callbacks.removeScripts #selectionSetChanged id:#MakeToolBoxLockTransformsID001
		print "Selection Check callback removed"
	)
)
AddSubRollout MakeToolbox.theSubrollout lockTransformsModule