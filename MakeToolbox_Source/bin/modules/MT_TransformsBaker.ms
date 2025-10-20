/*
--**********************************************************************************--
--                                                                                  --
--                                TRANSFORM BAKER                                   --
--                                                                                  --
--**********************************************************************************--

#NAME: Transform Baker
#VERSION: 1.3
#LAST UPDATED: 2025.09.29

#DESCRIPTION:
A utility to bake the transforms (position, rotation, scale) of one or more objects 
onto new control objects or collapse their existing controllers over a specified 
frame range.

#INSTRUCTIONS:
Select the object(s) to bake, set the frame range and operation type, then click "Bake Transforms".
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Transforms_Baker

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Script cleanup, bug fixes, and modernization.

#HISTORY:
    - v1.3 (2025.09.29): Removed global variable dependencies, fixed bugs, and improved tooltips.
    - v1.2 (2013.02.04): Optimized script by improving the object processing loop.
    - v1.1 (2012.03.12): Initial integration into MakeToolbox.
    - v1.0 (2011.03.29): First version with group selection and controller replacement modes.

--**********************************************************************************--
*/
transformsBakerModuleVer = 1.3
try(removeSubRollout MakeToolbox.theSubrollout transformsBakerModule)catch()

rollout transformsBakerModule (("Transforms Baker v") + (transformsBakerModuleVer as string))
(
	local
	theAnimatedObject = "undefined",
	framesStart = animationrange.start,
	framesEnd = animationrange.end,
	clipboardString = "defined",
	currentFrame = 0,
	totalFrames = framesEnd - framesStart,
	controlTypeCheck = "object",
	objectTypeCheck = "selection",
	StoredSelection
	groupBox ObjectsGroup "Object" width:158 height:60 offset:[-10,-5]
	pickbutton loadUserDefined "Select Object" width:150 offset:[0,-50] enabled:false tooltip:"Applies the Transform Bake operation a single object"
	checkbox selectionCheck "Apply to selected Objects" tristate:1 offset:[-1,-2] tooltip:"Applies the Transform Bake operation to all selected objects"

	groupBox framesGroup "Frame Range" width:158 height:60 offset:[-10,1]
	spinner framesStartSpinner range:[-99999,99999,framesStart] width:60 type:#integer offset:[-80,-49] tooltip:"Sets the start frame for the baking operation"
	label SpinnerToLabel "To" offset:[0 ,-20]
	spinner framesEndSpinner range:[-99999,99999,framesEnd] width:60 type:#integer offset:[11,-19] tooltip:"Sets the end frame for the baking operation"
	button timeSnap "Snap to Timeline" width: 150 height:20 offset:[0,-1] tooltip:"Sets the current timeline start and end frame."
	
	groupBox TypeGroup "Type of operation" width:158 height:60 offset:[-10,1]
	checkButton ControlObjectButton "Bake to Control Object" width:150 height:20 offset:[-1,-51] checked:true tooltip:"Creates a point helper and bakes selected object's PRS animation to it"
	checkButton ReplaceControlerButton "Collapse Object's Controlers" width:150 height:20 offset:[0,-3] checked:false tooltip:"Collapses all the layered animation controllers down to default PRS tree with the resulting animation baked to it"
	
	groupBox Processing "Bake" width:158 height:63 offset:[-10,0]
	button BakeButton " Bake Transforms " width:150 height:20 offset:[0,-53] 
	progressbar TotalProgress   width: 149 height:10 offset:[-5,-3]  color:Blue
	progressbar objProgress   width: 149 height:10 offset:[-5,-3]  color: green
	
	------------------BAKING PROCESS-----------------------
	function FN_BakeObjects =
	(
		if theanimatedobject != "undefined" OR ((objectTypeCheck == "selection") AND (selection.count != 0)) then
		(
			disableSceneRedraw()
			oldAnimationRange = animationRange
			animationRange = interval framesStart FramesEnd
			oldSliderTime = sliderTime
			StoredSelection = selection as array
			-- Make the alignment points and array
			pointArray = #()
			for i in 1 to StoredSelection.count do
			(
				newPoint = point name:("globalPoint_" + (i as string))
				join pointArray #(newPoint)
			)
			sliderTime = framesStart
			totalFrames =(framesEnd-framesStart)
			currentFrame = 0
			max tool animmode
			set animate on
			-- Loop through all of the frames in the range
			for i in framesStart to framesEnd do
			(						
				-- Loop through all of the objects that were in the selection
				for j in 1 to selection.count do
				(
					curObj = storedSelection[j]
					curPoint = pointArray[j]
					curPoint.transform = curObj.transform
					objProgress.value = 100.*j/selection.count
				)
				sliderTime =(sliderTime+1)
				TotalProgress.value = 100.*currentFrame/totalFrames
				currentFrame = (currentFrame+1)
				-- Update other progress
			)
			max tool animmode
			set animate off
			--Assign the animation to the objects in selected
			if controlTypeCheck != "object" do
			(
				-- If applying the transforms to the  objects themselves
				for i in 1 to StoredSelection.count do
				(
					curObj = storedSelection[i]
					curPoint = pointArray[i]
						
					curObj.pos.controller = Position_XYZ ()
					curObj.rotation.controller = Euler_XYZ ()
					
					curObj.transform = curPoint.transform
					curObj.parent = undefined
						
					posCtrl = curPoint.pos.controller
					rotCtrl = curPoint.rotation.controller
					scaleCtrl = curPoint.scale.controller
					curObj.pos.controller = posCtrl
					curObj.rotation.controller = rotCtrl
					curObj.scale.controller = scaleCtrl
				)
				delete pointArray
			)
			TotalProgress.value = 0
			animationRange = oldAnimationRange 
			SliderTime = oldSliderTime
			loadUserDefined.text = "Select Object"
			theanimatedobject = "undefined"
			enableSceneRedraw()
		)
		else (messagebox "Select objects to bake animation")
	)
	-----------------------EVENT HANDLERS---------------------------
	on BakeButton pressed do
	(
		FN_BakeObjects ()
	)
	on controlObjectButton changed state do
	(
		if state == on then 
		(
			ReplaceControlerButton.checked = off
			controlTypeCheck = "object"
			print ("Operantion Mode: " + controlTypeCheck)
		)
		else
		(
			ReplaceControlerButton.checked = on
			controlTypeCheck = "controler"
			print ("Operation Mode: " + controlTypeCheck)
		)
	)
	on ReplaceControlerButton changed state do
	(
		if state == on then 
		(
			controlObjectButton.checked = off
			controlTypeCheck = "controler"
			print ("Controler Mode: " + controlTypeCheck)
		)
		else
		(
			controlObjectButton.checked = on
			controlTypeCheck = "object"
			print ("Controler Mode: " + controlTypeCheck)
		)
	)
	on selectionCheck changed thing do
	(
		If selectionCheck.checked != true then
		(
			loadUserDefined.enabled = true
			objectTypeCheck = "single"
			print ("Object Mode: " + objectTypeCheck)
		)
		else
		(
			loadUserDefined.enabled = false
			objectTypeCheck = "selection"
			print ("Object Mode: " + objectTypeCheck)
		)
	)
	on loadUserDefined picked loadUserDefinedVar do
	(
		if loadUserDefinedVar != undefined then
		(
			theAnimatedObject = loadUserDefinedVar
			loadUserDefined.text = theAnimatedObject.name
			select theanimatedobject
		)
		else
		(
			messagebox "Select valid node"
		)
	)
	on framesStartSpinner changed framesStartVal do
	(
		framesStart = framesStartVal
		print ("Start Frame: " + framesStart as string)
		if (framesStart >= framesEnd) do
		(
			framesEndUpdate = (framesStart+1)
			framesEnd = framesEndUpdate
			print framesEndUpdate
			framesEndSpinner.range = [-99999,99999,framesEndUpdate]
		)
	)
	on framesEndSpinner changed framesEndVal do
	(
		framesEnd = framesEndVal
		print ("End Frame: " + framesEnd as string)
		if (framesStart >= framesEnd) do
		(
			framesStartUpdate = (framesEnd-1)
			framesStart = framesStartUpdate
			print framesStartUpdate
			framesStartSpinner.range = [-99999,99999,framesStartUpdate]
		)
	)	
	on timeSnap pressed do
	(
		framesStartSpinner.range = [-99999,99999,animationRange.start]
		framesEndSpinner.range = [-99999,99999,animationRange.end]
		framesStart = animationRange.start
		framesEnd = animationRange.end
		framesStartVal = framesStart
		framesEndVal = framesEnd
		print ("Start Frame: " + framesStart as string)
		print ("End Frame: " + framesEnd as string)
	)
)
AddSubRollout MakeToolbox.theSubrollout transformsBakerModule