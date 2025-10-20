/*
--**********************************************************************************--
--                                                                                  --
--                                 BAKE AND SAVE                                    --
--                                                                                  --
--**********************************************************************************--

#NAME: Bake and Save
#VERSION: 1.3
#LAST UPDATED: 2025.08.07

#DESCRIPTION:
A utility to bake animation data (transforms, visibility) from selected objects to an
external file. Includes options to load baked data onto other objects and several
scene utilities.

#INSTRUCTIONS:
Select the object(s) to bake. Set the desired frame range and baking options
(transforms, visibility). Click 'Bake and Save' and choose a location for the
animation file. To load, select target object(s) and click 'Load'.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Bake_and_Save

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
    - David Almeida (david.almeida@makevisual.com): Script cleanup and bugfixing

#HISTORY:
    - v1.3 (2025.08.07): Script cleanup and adjusted the checkNaming function.
    - v1.2 (2013.02.04): Optimized baking loop for significant speed increase.
    - v1.1 (2012.03.12): Initial integration into MakeToolbox.
    - v1.0 (2011.03.29): Added group selection, replace controller mode, and UI cleanup.

--**********************************************************************************--
*/
bakeAndSaveModuleVer = 1.3
try(removeSubRollout MakeToolbox.theSubrollout bakeAndSaveModule)catch()

rollout bakeAndSaveModule ("Bake and Save"+ (bakeAndSaveModuleVer as string))
(
	local
	theAnimatedObject = "undefined",
	framesStart = 0,
	framesEnd = 100,
	clipboardString = "defined",
	currentFrame = 0,
	totalFrames = 100,
	controlTypeCheck = "object",
	objectTypeCheck = "selection",
	StoredSelection = undefined
	groupBox framesGroup "Frame Range" width:158 height:60 offset:[-10,1]
			spinner framesStartSpinner range:[-99999,99999,0] width:60 type:#integer offset:[-80,-49] tooltip:"Sets the start frame for the baking process."
			label SpinnerToLabel "To" offset:[0 ,-20]
			spinner framesEndSpinner range:[-99999,99999,100] width:60 type:#integer offset:[11,-19] tooltip:"Sets the end frame for the baking process."
			button timeSnap "Snap to Timeline" width: 150 height:20 offset:[0,-1] tooltip:"Set the current timeline start frame and end frame."
	
 	groupBox optionsGroup "Options" width:158 height:70 offset:[-10,1]
 			checkbox transformsCheck "Save Transforms" offset:[-3,( ( optionsGroup.height * -1 ) + 10 ) ] checked:true align:#left tooltip:"Bakes the Position, Rotation and Scale transforms of the selected nodes."
 			checkbox visabilityCheck "Save Visibility" offset:[-4,-3] checked:false align:#left tooltip:"Bakes the visibility value of selected nodes."
 			checkbox createPlaceholderCheck "Create baked ref objs" offset:[-4,-3] checked:false align:#left tooltip:"Creates geometry objects with all the selected baked animation on the scene."
	
	groupBox grp_Save "Bake and Save " width:158 height:63 offset:[-10,10]
			button BakeButton " Bake and Save " width:150 height:20 offset:[0,-53] tooltip:"Bakes the animation of the selected nodes"
			progressbar TotalProgress   width: 149 height:10 offset:[-5,-3]  color:Blue
			progressbar objProgress   width: 149 height:10 offset:[-5,-3]  color: green
	
	groupBox grp_Load "Load" width:158 height:45 offset:[-10,0]
			button loadButton "Load" width:145 align:#left offset:[ -3 , ( ( grp_Load.height * -1 ) + 10 ) ] tooltip:"Loads the animation on the selected nodes"

	groupBox grp_Utilities "Utilities" width:158 height:98 offset:[-10,10]
			--button createDriversButton "Create Drivers" offset:[ -3 , ( ( grp_Utilities.height * -1 ) + 10 ) ] width:145 align:#left enabled:false
			button testNamesButton "Check sel for dupe names" offset:[ -3 , ( ( grp_Utilities.height * -1 ) + 10 ) ] width:145 align:#left tooltip:"Checks and reports the presence of duplicate names on the selected nodes."
			button addVisibilityTracksButton "Add visibility tracks to sel" offset:[-3,0] width:145 align:#left tooltip:"Adds an animatable controller to the visibility track of the selected nodes."
			button deleteAnimationButton "Delete animation on sel" offset:[-3,0] width:145 align:#left tooltip:"Deletes all animation on the selected nodes."


	------------------BAKING PROCESS-----------------------
	function fetchHierarchyVisibility argObj =
	(
		CurrentParent = argObj.parent
		while CurrentParent != undefined do
		(
			if CurrentParent[1].controller != undefined then
			(
				return (CurrentParent[1].controller.value)
			)
			else
			(
				argObj = CurrentParent
				CurrentParent = argObj.parent
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

	function bakeObjects =
	(
				
		setDefaultLayerActive()

		if theAnimatedObject != "undefined" or objectTypeCheck == "selection" then
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
					if visabilityCheck.checked then ( curPoint.visibility.controller.value = fetchHierarchyVisibility curObj ) else()

					
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


 			if NOT createPlaceholderCheck.checked do 
 			(
 				delete selection
 			)

 			select StoredSelection 
			objProgress.value = 0
			TotalProgress.value = 0
				
			animationRange = oldAnimationRange 
			SliderTime = oldSliderTime
				
			theAnimatedObject = "undefined"
				
 			enableSceneRedraw()
		)
		else
		(
			messagebox "Load object"
		)
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

	function checkNaming =
	(
		arr = ( for i in selection collect i.name )
		clearlistener()
		dupeArr = #()
		for i in 1 to ( arr.count - 1 ) do
		(
			for j = (i + 1) to arr.count do
			(
				if arr[i] == arr[j] do
				(
					print ("DUPLICATE NAME: " + arr[i] )
					append dupeArr arr[i]
				)
			)
		)
		if dupeArr.count == 0 then
		(
			messagebox "No duplicate names found."
		)
		else
		(
			print (((dupeArr.count * 2) as string) + " objects with duplicate names")
			messagebox "Duplicate names found. Open the Listener (F11) to see the list of duplicate names."
		)
	)

	function loadObjects =
	(
		addVisTrack()
		deleteAnimation()
		LoadSaveAnimation.loadAnimationDlg() -- relative:false insert:false

	)
	on BakeButton pressed do
	(
		if selection.count == 0 then
		(
			messagebox "Select one or more objects to bake animation"
		)
		else
		(
			bakeObjects()
		)
	)
	on loadButton pressed do 
	(
		if selection.count == 0 then
		(
			messagebox "Select one or more objects to load animation"
		)
		else
		(
			loadObjects()
		)
	)
	on testNamesButton pressed do 
	(
		if selection.count == 0 then
		(
			messagebox "Select two or more objects to check for duplicate names"
		)
		else
		(
			checkNaming()
		)
	)

	on addVisibilityTracksButton pressed do 
	(
		if selection.count == 0 then
		(
			messagebox "Select one or more objects to add a Visibility track on selection"
		)
		else
		(
			addVisTrack()
		)
	)
	on deleteAnimationButton pressed do 
	(
		if selection.count == 0 then
		(
			messagebox "Select one or more objects to delete their animation"
		)
		else
		(
			deleteAnimation()
		)
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