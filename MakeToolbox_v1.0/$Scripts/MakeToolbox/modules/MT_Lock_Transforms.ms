/*
#NAME:Lock Transforms
#VERSION:1.2
#INSTRUCTIONS:
Quickly lock the transforms of an object, or 
a group of selected objects.
http://www.makevisual.com/learning/MT_Lock_Transforms.htm
#SOURCE:Romain Faure rf.romainfaure@gmail.com, Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.22.2012 >> Info header added
05.12.2011 >> Release -rf
02.26.2012  >> UI Update -rf
03.02.2012  >> Integrated to MakeToolbox -ad
03.05.2012  >> added global and class (un)locks -ad
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Romain Faure rf.romainfaure@gmail.com
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.12.2011 >> Release -rf
--- version 1.01 : 02.26.2012  >> UI Update -rf
--- version 1.1 : 03.02.2012  >> Integrated to MakeToolbox -ad
--- version 1.2 : 03.05.2012  >> added global and class (un)locks -ad
--*****************************************************
lockTransformsModuleVer = 01.2
try(removeSubRollout MakeToolbox.theSubrollout lockTransformsModule)catch()

global MT_camerasLockToggle = false
global MT_objectsLockToggle = false

global LockTransforms
global LockSelection 
global UnFreezeMove
global Ltaaply
global Ltcancel

MoveXValue = true
MoveYValue = true
MoveZValue = true
RotateXValue = true
RotateYValue = true
RotateZValue = true
ScaleXValue =  true
ScaleYValue =  true
ScaleZValue =  true

fn LockSelection =
	(
	GetSelectionTransforms = #{}
			
	if selection.count >= 1 then 
		(
		if MoveXValue == true then(append GetSelectionTransforms 1) else (deleteItem GetSelectionTransforms 1)
		if MoveYValue == true then(append GetSelectionTransforms 2) else (deleteItem GetSelectionTransforms 2)
		if MoveZValue == true then(append GetSelectionTransforms 3) else (deleteItem GetSelectionTransforms 3)
		if RotateXValue == true then(append GetSelectionTransforms 4) else (deleteItem GetSelectionTransforms 4)
		if RotateYValue == true then(append GetSelectionTransforms 5) else (deleteItem GetSelectionTransforms 5)
		if RotateZValue == true then(append GetSelectionTransforms 6) else (deleteItem GetSelectionTransforms 6)
		if ScaleXValue == true then(append GetSelectionTransforms 7) else (deleteItem GetSelectionTransforms 7)
		if ScaleYValue == true then(append GetSelectionTransforms 8) else (deleteItem GetSelectionTransforms 8)
		if ScaleZValue == true then(append GetSelectionTransforms 9) else (deleteItem GetSelectionTransforms 9)
			
		setTransformLockFlags selection GetSelectionTransforms
		)else (messageBox ("No Object(s) Selected"))
	)
						
fn Ltapply =
	(
	LockSelection()
	)

function lockAllFunction =(setTransformLockFlags selection #all)
	
function unlockAllFunction =(setTransformLockFlags selection #none)
	
rollout lockTransformsModule ("Lock Transforms")/* + (lockTransformsModuleVer as string))*/
(
	-- the UI
	groupbox lockUnlockGroupbox "Lock / Unlock" width:160 height:55 offset:[-11,-3] 
	button lockCameras "Lock Cams" width:76 height:20  align:#left offset:[-7,-45] tooltip:"Lock or Unlock all cameras in the scene."
	button lockObjects "Lock Objects" width:76 height:20 align:#left offset:[69,-25] tooltip:"Lock or Unlock all objects in the scene."
	checkbox selectionCheckBox "Apply to selection only" offset:[-7,-3]
	
	groupbox manualLocksGroup "Custom Locks" width:160 height:148 offset:[-11,3]
	
	groupbox moveLocksGroup "Move" offset:[-7,-140] width:152 height:45
	checkbutton moveLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-35] checked:MoveXValue
		on moveLocksXButton changed state do MoveXValue = state
	checkbutton moveLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] checked:MoveYValue
		on moveLocksYButton changed state do MoveYValue = state
	checkbutton moveLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] checked:MoveZValue
		on moveLocksZButton changed state do MoveZValue = state
	button moveLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Checked all move tranforms (XYZ)."
		on moveLocksTButton pressed do 	
			(
				if moveLocksXButton.checked and moveLocksYButton.checked and moveLocksZButton.checked == true 
					then
						(
							moveLocksXButton.state = false
							moveLocksYButton.state = false
							moveLocksZButton.state = false
							MoveXValue = false
							MoveYValue = false
							MoveZValue = false
						)
					else 
						(
							moveLocksXButton.state = true
							moveLocksYButton.state = true
							moveLocksZButton.state = true
							MoveXValue = true
							MoveYValue = true
							MoveZValue = true
						)
				)

	groupbox rotateLocksGroup "Rotate" offset:[-7,-5] width:152 height:40
				
	checkbutton rotateLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-30] checked:RotateXValue
		on rotateLocksXButton changed state do RotateXValue = state
	checkbutton rotateLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] checked:RotateYValue
		on rotateLocksYButton changed state do RotateYValue = state
	checkbutton rotateLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] checked:RotateZValue
		on rotateLocksZButton changed state do RotateZValue = state
	button rotateLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Checked all rotation tranforms (XYZ)."
		on rotateLocksTButton pressed do 	
			(
				if rotateLocksXButton.checked and rotateLocksYButton.checked and rotateLocksZButton.checked == true 
					then
						(
							rotateLocksXButton.state = false
							rotateLocksYButton.state = false
							rotateLocksZButton.state = false
							RotateXValue = false
							RotateYValue = false
							RotateZValue = false
						)
					else 
						(
							rotateLocksXButton.state = true
							rotateLocksYButton.state = true
							rotateLocksZButton.state = true
							RotateXValue = true
							RotateYValue = true
							RotateZValue = true
						)
			)
	
	groupbox scaleLocksGroup "Scale" offset:[-7,-5] width:152 height:40
	checkbutton scaleLocksXButton "X"  width:30 height:20 align:#left offset:[-1,-30] checked:ScaleXValue
		on scaleLocksXButton changed state do ScaleXValue = state
	checkbutton scaleLocksYButton "Y"  width:30 height:20 align:#left offset:[32,-25] checked:ScaleYValue
		on scaleLocksYButton changed state do ScaleYValue = state
	checkbutton scaleLocksZButton "Z"  width:30 height:20 align:#left offset:[64,-25] checked:ScaleZValue
		on scaleLocksZButton changed state do ScaleZValue = state
	button scaleLocksTButton "toggle"  width:45 height:20 align:#left offset:[96,-25] tooltip:"Checked all scale tranforms (XYZ)."
		on scaleLocksTButton pressed do  
			(
				if scaleLocksXButton.checked and scaleLocksYButton.checked and scaleLocksZButton.checked == true
					then
						(
							scaleLocksXButton.state = false
							scaleLocksYButton.state = false
							scaleLocksZButton.state = false
							ScaleXValue =  false
							ScaleYValue =  false
							ScaleZValue =  false
						) 
					else
						(
							scaleLocksXButton.state = true
							scaleLocksYButton.state = true
							scaleLocksZButton.state = true
							ScaleXValue =  true
							ScaleYValue =  true
							ScaleZValue =  true
						)
			)
	
	button customLocksButton "Apply to selection" width:152 align:#left offset:[-7,2] height:20 tooltip:"Set transforms to selection."
			on customLocksButton pressed do Ltapply()
	
	on lockCameras pressed do
	(
	tempSelection = selection as array
	undo on
		(
		disablesceneredraw()
		if MT_camerasLockToggle == false then
			(
			lockCameras.text = "Unlock Cams"
			if selectionCheckBox.checked == true then() else(select cameras)
			try(lockAllFunction ())catch(messagebox "select something")
			MT_camerasLockToggle = true
			)
		else
			(
			lockCameras.text = "Lock Cams"
			if selectionCheckBox.checked == true then() else(select cameras)
			try(unlockAllFunction ())catch(messagebox "select something")
			MT_camerasLockToggle = false
			)
		select tempSelection
		enablesceneredraw()
		redrawviews()
		)
	)
	
	on lockObjects pressed do
	(
	tempSelection = selection as array
	undo on
		(
		disablesceneredraw()
		if MT_objectsLockToggle == false then
			(
			lockObjects.text = "Unlock Objects"
			if selectionCheckBox.checked == true then() else(select Objects)
			try(lockAllFunction ())catch(messagebox "select something")
			MT_objectsLockToggle = true
			)
		else
			(
			lockObjects.text = "Lock Objects"
			if selectionCheckBox.checked == true then() else(select Objects)
			try(unlockAllFunction ())catch(messagebox "select something")
			MT_objectsLockToggle = false
			)
		select tempSelection
		enablesceneredraw()
		redrawviews()
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout lockTransformsModule