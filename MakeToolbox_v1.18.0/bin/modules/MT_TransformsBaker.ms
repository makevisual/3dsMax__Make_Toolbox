/*
#NAME:Transform Baker
#VERSION:1.2
#INSTRUCTIONS:
Transform Baker bakes the transforms of
one object onto another object, over a 
specified frame range.
http://www.makevisual.com/learning/MT_TransformsBaker.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.29.11 >>  added group selection mode, added replace controler mode, cleaned up UI
03.12.2012  >> Integrated to MakeToolbox		
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
-- version 1.0 : 03.29.11 >>  added group selection mode, added replace controler mode, cleaned up UI
-- version 1.1 : 03.12.2012  >> Integrated to MakeToolbox						  
-- version 1.2 : 02.04.2013  >> Layered looping so that each object is processes on each frame, significantly speeding up the script
--*****************************************************
-- INFOS
-- Written for MAX v.9.0 and up
--*****************************************************
transformsBakerModuleVer = 1.2
try(removeSubRollout MakeToolbox.theSubrollout transformsBakerModule)catch()

global framesStart
global framesEnd
global theAnimatedObject
global currentFrame
global totalFrames
global controlTypeCheck
global objectTypeCheck
global StoredSelection
	
theanimatedobject = "undefined"
framesStart = 0
framesEnd = 100
clipboardString = "defined"
currentFrame = 0
totalFrames = 100
controlTypeCheck = "object"
objectTypeCheck = "selection"

rollout transformsBakerModule ("Transforms Baker") /*+ (transformsBakerModuleVer as string))*/
(
	groupBox ObjectsGroup "Object" width:158 height:60 offset:[-10,-5]
	pickbutton loadUserDefined "Select Object" width:150 offset:[0,-50] tooltip:"Select an object to bake animation on."
	checkbox selectionCheck "Apply to selected Objects" tristate:1 offset:[-1,-2]

	groupBox framesGroup "Frames Range" width:158 height:60 offset:[-10,1]
	spinner framesStartSpinner range:[-99999,99999,0] width:60 type:#integer offset:[-80,-49]
	label SpinnerToLabel "To" offset:[0 ,-20]
	spinner framesEndSpinner range:[-99999,99999,100] width:60 type:#integer offset:[11,-19]
	button timeSnap "Snap to Timeline" width: 150 height:20 offset:[0,-1] tooltip:"Set the current timeline start frame and end frame."
	
	groupBox TypeGroup "Type of operation" width:158 height:60 offset:[-10,1]
	checkButton ControlObjectButton "Bake to Control Object" width:150 height:20 offset:[-1,-51] checked:true tooltip:"Bake object animation (M,R,S) to an helper controller."
	checkButton ReplaceControlerButton "Replace Objects Controler" width:150 height:20 offset:[-4,-3] checked:false tooltip:"Suppose to do something."
	
	groupBox Processing "Bake" width:158 height:63 offset:[-10,0]
	button BakeButton " Bake Transforms " width:150 height:20 offset:[0,-53] 
	progressbar TotalProgress   width: 149 height:10 offset:[-5,-3]  color:Blue
	progressbar objProgress   width: 149 height:10 offset:[-5,-3]  color: green
	
	------------------BAKING PROCESS-----------------------
function FN_BakeObjects =
	(
	
	if theanimatedobject != "undefined" or objectTypeCheck == "selection" then
		(
-- 		try(
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
			if controlTypeCheck == "object"
			then () -- If leaving the point helpers in the scene
			else	(  -- If applying the transforms to the  objects themselves
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
-- 			)catch(Messagebox "Script Error")
		)else(messagebox"Load object")
	)	
	
	
on BakeButton pressed do
	(
	FN_BakeObjects ()
	)
	
	-----------------------UI STUFF---------------------------
on informationButton pressed do
	(rollout InformationDialog "AE Position Exporter Info"
		(
		hyperLink DTBLink "Transform Baker v1.1  Help" address:"http://www.aarondabelow.com/pages/AE_Pos_Export.html" align:#center
		label lab4 ""
		label lab5 "Select an object and click on" align:#left
		label lab6 "bake transforms to create a new" align:#left
		label lab7 "point object with the collapsed" align:#left
		label lab8 "transforms of the original object" align:#left
		label lab9 ""
		hyperLink aaronDabelow "Aaron Dabelow" address:"http://aarondabelow.com/" align:#center
		label lab21 "theonlyaaron@gmail.com"
		)
	createDialog InformationDialog 225 200
	)
	
on controlObjectButton changed state do
	(
		if state == on then 
		(
		ReplaceControlerButton.checked = off
		controlTypeCheck = "object"
		-- print ("Operantion Mode: " + controlTypeCheck)
		)
		else
		(
		ReplaceControlerButton.checked = on
		controlTypeCheck = "controler"
		-- print ("Operation Mode: " + controlTypeCheck)
		)
	)
	
on ReplaceControlerButton changed state do
	(
		if state == on then 
		(
		controlObjectButton.checked = off
		controlTypeCheck = "controler"
		-- print ("Controler Mode: " + controlTypeCheck)
		)
		else
		(
		controlObjectButton.checked = on
		controlTypeCheck = "object"
		-- print ("Controler Mode: " + controlTypeCheck)
		)
	)
	
on selectionCheck changed thing do
	(
		If selectionCheck.checked != true then
		(
			loadUserDefined.enabled = true
			objectTypeCheck = "single"
			-- print ("Object Mode: " + objectTypeCheck)
		)
		else
		(
			loadUserDefined.enabled = false
			objectTypeCheck = "selection"
			-- print ("Object Mode: " + objectTypeCheck)
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
		else(messagebox "Select valid node")
	)

on framesStartSpinner changed framesStartVal do
		(
		framesStart = framesStartVal
		-- print ("Start Frame: " + framesStart as string)
			
		if (framesStart >= framesEnd) then
			(
			framesEndUpdate = (framesStart+1)
			framesEnd = framesEndUpdate
			-- print framesEndUpdate
			framesEndSpinner.range = [-99999,99999,framesEndUpdate]
			)
		else ()
			
		)
	
on framesEndSpinner changed framesEndVal do
		(
		framesEnd = framesEndVal
		-- print ("End Frame: " + framesEnd as string)
			
		if (framesStart >= framesEnd) then
			(
			framesStartUpdate = (framesEnd-1)
			framesStart = framesStartUpdate
			-- print framesStartUpdate
			framesStartSpinner.range = [-99999,99999,framesStartUpdate]
			)
		else ()
			
		)	
		
on timeSnap pressed do
		(
		framesStartSpinner.range = [-99999,99999,animationRange.start]
		framesEndSpinner.range = [-99999,99999,animationRange.end]
		framesStart = animationRange.start
		framesEnd = animationRange.end
		framesStartVal = framesStart
		framesEndVal = framesEnd
		-- print ("Start Frame: " + framesStart as string)
		-- print ("End Frame: " + framesEnd as string)
		)	
)
AddSubRollout MakeToolbox.theSubrollout transformsBakerModule