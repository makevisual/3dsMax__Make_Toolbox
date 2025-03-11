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
bakeAndSaveModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout bakeAndSaveModule)catch()

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

rollout bakeAndSaveModule ("Bake and Save"+ (bakeAndSaveModuleVer as string))
(
	groupBox framesGroup "Frame Range" width:158 height:60 offset:[-10,1]
			spinner framesStartSpinner range:[-99999,99999,0] width:60 type:#integer offset:[-80,-49]
			label SpinnerToLabel "To" offset:[0 ,-20]
			spinner framesEndSpinner range:[-99999,99999,100] width:60 type:#integer offset:[11,-19]
			button timeSnap "Snap to Timeline" width: 150 height:20 offset:[0,-1] tooltip:"Set the current timeline start frame and end frame."
	
 	groupBox optionsGroup "Options" width:158 height:70 offset:[-10,1]
 			checkbox transformsCheck "Save Transforms" offset:[-3,( ( optionsGroup.height * -1 ) + 10 ) ] checked:true align:#left 
 			checkbox visabilityCheck "Save Visibility" offset:[-4,-3] checked:false align:#left
 			checkbox createPlaceholderCheck "Create baked ref objs" offset:[-4,-3] checked:false align:#left
	
	groupBox grp_Save "Bake and Save " width:158 height:63 offset:[-10,10]
			button BakeButton " Bake and Save " width:150 height:20 offset:[0,-53] 
			progressbar TotalProgress   width: 149 height:10 offset:[-5,-3]  color:Blue
			progressbar objProgress   width: 149 height:10 offset:[-5,-3]  color: green
	
	groupBox grp_Load "Load" width:158 height:45 offset:[-10,0]
			button loadButton "Load" width:145 align:#left offset:[ -3 , ( ( grp_Load.height * -1 ) + 10 ) ] -- enabled:false

	groupBox grp_Utilities "Utilities" width:158 height:120 offset:[-10,10]
			button createDriversButton "Create Drivers" offset:[ -3 , ( ( grp_Utilities.height * -1 ) + 10 ) ] width:145 align:#left enabled:false
			button testNamesButton "Check sel for dupe names" offset:[-3,0] width:145 align:#left 
			button addVisibilityTracksButton "Add visibility tracks to sel" offset:[-3,0] width:145 align:#left 
			button deleteAnimationButton "Delete animation on sel" offset:[-3,0] width:145 align:#left 


	------------------BAKING PROCESS-----------------------
function fetchHeirarchyVisability argObj =
(
	-- this is gross and bad dont look at it please 

	curObj = argObj
	attempts = 0
	maxAttempts = 20

	curParent = curObj.parent 

	while attempts <= maxAttempts do
	(
		try 
		(

			visibilityValue = curObj.visibility.controller.value

			return visibilityValue

		)
		catch
		(
			curObj = curParent
			try( curParent = curObj.parent )catch(return 1.0)
		)
	)

	return 1.0
)

function setDefaultLayerActive =
(
	layer = layermanager.getlayer 0
	layer.current = true
)

function deleteAnimation =
(
	macros.run "Animation Tools" "DeleteSelectedAnimation"
)

function makeLayers =
(
	
)

function bakeObjects =
(
			
			setDefaultLayerActive()

			if theanimatedobject != "undefined" or objectTypeCheck == "selection" then
				(
		
		 			disableSceneRedraw()
										
					oldAnimationRange = animationRange
					animationRange = interval framesStart FramesEnd
					oldSliderTime = sliderTime
					StoredSelection = selection as array
								
					pointArray = #()
					for curObj in StoredSelection do 
						(
		
		 				--newPoint = point name:(curObj.name) wirecolor:red 
		 				newPoint = box name:(curObj.name) wirecolor:red
		 				newPoint.visibility = bezier_float()
		 				newPoint.visibility.controller.value = 1.0

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

									
								if transformsCheck.checked then ( curPoint.transform = curObj.transform ) else()
								if visabilityCheck.checked then ( curPoint.visibility.controller.value = fetchHeirarchyVisability curObj ) else()

									
		 						objProgress.value = 100.*j/selection.count
								)
							sliderTime =(sliderTime+1)
							
							TotalProgress.value = 100.*currentFrame/totalFrames
							currentFrame = (currentFrame+1)
							-- Update other progress
						)
						
					max tool animmode
					set animate off
		
					select pointArray 

					animationOutput = undefined 
		 			animationOutput = LoadSaveAnimation.saveAnimationDlg()
		

		
					if animationOutput != undefined then
					(
						LoadSaveAnimation.saveAnimation animationOutput pointArray "" ""
					)


		 			if createPlaceholderCheck.checked then 
		 			(

		 			)
		 			else 
		 			(
		 				delete selection 
		 			)

		 			select StoredSelection 
		
					

					--Assign the animation to the objects in selected
		
		
					-- USE THIS FOR LOAD --
		
		
						-- 	if controlTypeCheck == "object"
						-- 	then () -- If leaving the point helpers in the scene
						-- 	else	(  -- If applying the transforms to the  objects themselves
						-- 		for i in 1 to StoredSelection.count do
						-- 			(
						-- 			curObj = storedSelection[i]
						-- 			curPoint = pointArray[i]
												
						-- 		curObj.pos.controller = Position_XYZ ()
						-- 		curObj.rotation.controller = Euler_XYZ ()
											
						-- 		curObj.transform = curPoint.transform
						-- 		curObj.parent = undefined
												
						-- 			posCtrl = curPoint.pos.controller
						-- 			rotCtrl = curPoint.rotation.controller
						-- 			scaleCtrl = curPoint.scale.controller
						-- 			curObj.pos.controller = posCtrl
						-- 			curObj.rotation.controller = rotCtrl
						-- 			curObj.scale.controller = scaleCtrl
						-- 			)
						-- 		delete pointArray
						-- 		)
		
					objProgress.value = 0
					TotalProgress.value = 0
						
					animationRange = oldAnimationRange 
					SliderTime = oldSliderTime
						
				 -- loadUserDefined.text = "Select Object"
					theanimatedobject = "undefined"
						
		 			enableSceneRedraw()
				 -- )catch(Messagebox "Script Error")
				)else(messagebox"Load object")
)	
	
function addVisTrack =
(
	objArr = selection as array

	for obj in objArr do 
	(
			obj.visibility = bezier_float()
			obj.visibility.controller.value = 1.0
	)
)

function makeDrivers = 
(

)

function checkNaming =
(
	arr = ( for i in selection collect i.name )
	clearlistener()
	dupeArr = #()

	for i in 1 to ( arr.count - 1 ) do
	(
		if arr[i] == arr[(i+1)]
		then ( print ("DUPLICATE NAME: " + arr[i] ) )
		else(
	 		--print arr[i]
			append dupeArr arr[i]
		)
	)

	if dupeArr.count != 0 then print("No Conflicts")
)

function loadObjects =
(
	addVisTrack()
	deleteAnimation()
	LoadSaveAnimation.loadAnimationDlg() -- relative:false insert:false

)

on loadButton pressed do 
(
	loadObjects()
)

on testNamesButton pressed do 
(
		checkNaming()
)

on addVisibilityTracksButton pressed do 
(
		addVisTrack()
)

on deleteAnimationButton pressed do 
(
		deleteAnimation()
)
	
on BakeButton pressed do
	(
	bakeObjects ()
	)
	
	-----------------------UI STUFF---------------------------
on bakeAndSaveModule open do 
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
		else(messagebox "Select valid node")
	)

on framesStartSpinner changed framesStartVal do
		(
		framesStart = framesStartVal
		print ("Start Frame: " + framesStart as string)
			
		if (framesStart >= framesEnd) then
			(
			framesEndUpdate = (framesStart+1)
			framesEnd = framesEndUpdate
			print framesEndUpdate
			framesEndSpinner.range = [-99999,99999,framesEndUpdate]
			)
		else ()
			
		)
	
on framesEndSpinner changed framesEndVal do
		(
		framesEnd = framesEndVal
		print ("End Frame: " + framesEnd as string)
			
		if (framesStart >= framesEnd) then
			(
			framesStartUpdate = (framesEnd-1)
			framesStart = framesStartUpdate
			print framesStartUpdate
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
		print ("Start Frame: " + framesStart as string)
		print ("End Frame: " + framesEnd as string)
		)	
)
AddSubRollout MakeToolbox.theSubrollout bakeAndSaveModule