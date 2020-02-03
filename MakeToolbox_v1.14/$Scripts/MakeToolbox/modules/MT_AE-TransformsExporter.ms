/*
#NAME:AE Position Exporter
#VERSION:1.1
#INSTRUCTIONS:
Use this script to export the position
data of an object to After Effects.
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.22.2012 >> Info header added
03.12.2012 >> Integrated into MakeToolBox
*/
--*****************************************************
-- Tool part of the Make Toolbox
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 12.25.2009 >>- v1.0 (12.25.09):
--- version 1.1 : 03.12.2012  >> Integrated to MakeToolbox						
--- version 1.2 : 01.07.2014  >> Converted to transforms exporter
--*****************************************************
AETransformsExporterModuleVer = 01.2
try(removeSubRollout MakeToolbox.theSubrollout AETransformsExporterModule)catch()
	
(
global framesStart = 0
global framesEnd = 100
global clipboardString = "defined"
global headderText
global footerText
global clipbpardString
global theAnimatedObject
global currentFrame
global totalFrames
global updateEditText()
)

(
global headderText = "Adobe After Effects 8.0 Keyframe Data
 "
	
global positionHeadderText = "Transform	Position
	Frame	X pixels	Y pixels	Z pixels"
	
global positionScaleText = "Transform	Scale
	Frame	X percent	Y percent	Z percent"
	
global positionRotationZText = "Transform	Rotation
	Frame	degrees	"
	
global positionRotationXText = "Transform	X Rotation
	Frame	degrees	"
	
global positionRotationYText = "Transform	Y Rotation
	Frame	degrees	"
	
global fovHeaderText = "Camera Options	Zoom
	Frame	pixels "

global returnText ="
"
global footerText = "
End of Keyframe Data"

global fpsText = "	Units Per Second	"

clipbpardString = "defined"

enablesceneredraw()
)

rollout AETransformsExporterModule ("AE Transforms Exporter " + (AETransformsExporterModuleVer as string))
(
	groupBox GrabGroup "Static Transforms" width:160 height:58 pos: [2,2]
		button copyToClipboardStatic " Copy To Clipboard " width: 150 height:18 pos: [7,18] tooltip: "Copy selected objects position data to your clipboard to be pasted into After Effects."
		button saveTextStatic " Save to File " width: 150 height:18 pos: [7,36] tooltip: "Save selected objects position data as a .txt file to be copied into After Effects."
	
	groupBox animatedGroup "Animated Transforms" width:160 height:262 align:#left offset:[-11,2]--pos:[2,50]
		groupbox optionsGroup "Options" width:152 height:65 align:#left offset:[-8,(-1*animatedGroup.height + 8)]--pos:[2,50]
			checkbox checkboxPosition "Positions" checked:true align:#left offset:[-2,(-1 * optionsGroup.height + 10)] --pos: [15,20]
			checkbox checkboxRotation "Rotations" align:#left checked:true offset:[-2,-4]-- pos: [15,35]
			checkbox checkboxScale "Scale" checked:true align:#left checked:true offset:[-2,-4] --pos: [15,50]
			checkbox checkboxFOV "FOV (cam)" checked:false visible:true align:#left offset:[70,-52] width:67
		groupBox framesGroup "Frame range" width:151 height:60 align:#left  pos: [5,142]
			spinner framesStartSpinner "" range:[0,99999,0] width:58 type:#integer align:#left offset:[-2,(-1 * framesGroup.height +12)]-- pos: [13,88]
			spinner framesEndSpinner "To " range:[0,99999,100] width:70 type:#integer offset:[4,-21]--pos: [78,88]
			button timeSnap "Snap to Timeline" width: 135 height:20 align:#left offset:[0,-5]-- pos: [13,105]
		groupBox Processing "Generation" width:151 height:73 pos: [5,203]
			button processPositions " Export Animated Postition " width: 135 height:25 offset:[0,(-1 * Processing.height + 10)]-- pos: [13,150]
			label lab1 "Status: Ready"
			progressbar objProgress   width: 134 height:7 offset:[0,-4]--pos: [13,195]
		groupbox groupboxCustomFormatting "Custom Formatting" pos:[5,278] width:151 height:40
			button buttonCustomHeadder "Headder" align:#left offset:[-2,(-1 * groupboxCustomFormatting.height + 10 )] width:70 --pos:[10,20]
			button buttonCustomFooter "Footer" align:#left offset:[68,-26]width:70 --pos:[80,20]
	
	function parseTransformsStatic obj =
		(
		currentFrameText = "	"+((currentTime as integer)/TicksPerFrame) as string
				
		xPosition =((floor (obj.pos.x * 1000)) / 1000)
		yPosition =((floor (obj.pos.y * 1000)) / 1000)
		zPosition =((floor (obj.pos.z * 1000)) / 1000)

-- 		xPositionMod = xPosition
-- 		yPositionMod = -zPosition
-- 		zPositionMod = yPosition	
		
		xPositionMod = xPosition
		yPositionMod = yPosition
		zPositionMod = zPosition	
			
		xPositionText = "	"+xPosition as string
		yPositionText = "	"+( -1 * zPosition) as string
		zPositionText = "	"+yPosition as string	
		
		xScaleText = "	"+ (int(obj.scale[1] * 100) as string)
		yScaleText = "	"+ (int(obj.scale[2] * 100) as string)
		zScaleText = "	"+ (int(obj.scale[3] * 100) as string)
		
		fn float4dec arg = ((floor (1000 * arg)) / 1000)

		quatRotations = quatToEuler obj.rotation order:3
		eulerRotations = [-(float4dec quatRotations.x),-(float4dec quatRotations.y),-(float4dec quatRotations.z)]

									-------------------------------------- HERE IS WHERE TO DICK AROUND -------------------------------
		xRotationText = positionRotationXText + returnText + currentFrameText + "	" + (1 * eulerRotations[3]) as string + returnText
		yRotationText = positionRotationYText + returnText + currentFrameText +  "	" + ( -1 * eulerRotations[2] ) as string + returnText
		zRotationText = positionRotationZText + returnText + currentFrameText +  "	" + (-1 * eulerRotations[1]) as string + returnText
				
		comboString = headderText + returnText +  positionHeadderText + returnText + currentFrameText + xPositionText + yPositionText + zPositionText + returnText + returnText + positionScaleText + returnText + currentFrameText + xScaleText + yScaleText + zScaleText  + returnText  + returnText + zRotationText + returnText + xRotationText + returnText + yRotationText + footerText

		return comboString
		)
	
	on copyToClipboardStatic pressed do
		(
			if selection.count ==1 then
				(
				try(
					comboString = parseTransformsStatic selection[1]
					setclipboardText comboString
					--print comboString as string
		
					messagebox "AE keyframe Data has been copied to your clipboard."
				)
				catch(Messagebox "Error")
			)
			else (messagebox "You must select one (1) object")
		)
	
	on saveTextStatic pressed do
		(
			if selection.count == 1 then
			(
				try
					(
					saveForAEFileStaticName = "c:/StaticPositionForAE.txt"
						
					if saveForAEFileStaticName != undefined then
					 (
						saveForAEFileStatic = createfile saveForAEFileStaticName
					
						comboString = parseTransformsStatic selection[1]
						--print comboString as string
						 
						format "%\n" comboString to:saveForAEFileStatic  ---  SAVE THE COMBO
						
						close saveForAEFileStatic
						shelllaunch "notepad.exe" saveForAEFileStaticName
						)
					else()	
					)
				catch(Messagebox "unexpected error")
			)
			else (Messagebox "You must select one (1) object")
		)

	
	function float4dec arg = ((floor (1000 * arg)) / 1000)
		
	function parsePositionsAnimated obj =
		(
		xPosition =((floor (obj.pos.x * 1000)) / 1000) --as string
		yPosition =((floor (obj.pos.y * 1000)) / 1000) --as string
		zPosition =((floor (obj.pos.z * 1000)) / 1000) --as string
			
		return [xPosition,yPosition,zPosition]
		)
		
		function parseFOV obj =
		(
			zoomVal = (renderwidth/(2.0*tan((obj.fov/2.0))))
			
			#(zoomVal)
		)
	
	function parseScalesAnimated obj =
		(
		xScaleText =int(obj.scale[1] * 100) --as string)
		yScaleText =int(obj.scale[2] * 100) --as string)
		zScaleText =int(obj.scale[3] * 100) --as string)
			
		return [xScaleText,yScaleText,zScaleText]
		)
		
	function parseRotationsAnimated obj =
		(
		quatRotations = quatToEuler obj.rotation order:1 --order:3
			
		return [-(float4dec quatRotations.x),-(float4dec quatRotations.y),(float4dec quatRotations.z)]
		--return [-(float4dec quatRotations.x),-(float4dec quatRotations.y),-(float4dec quatRotations.z)]
		)	
	
	function functionTimeSnap = 
		(
		framesStartSpinner.range = [-99999,99999,animationRange.start]
		framesEndSpinner.range = [-99999,99999,animationRange.end]
		framesStart = animationRange.start
		framesEnd = animationRange.end
		framesStartVal = framesStart
		framesEndVal = framesEnd
		)
	
	on AnimatedPositionsExporter open do
		(
		functionTimeSnap()
		)

	on framesStartSpinner changed framesStartVal do
		(
		framesStart = framesStartVal
		--print ("Start Frame: " + framesStart as string)
			
		if (framesStart >= framesEnd) then
			(
			framesEndUpdate = (framesStart+1)
			framesEnd = framesEndUpdate
			--print framesEndUpdate
			framesEndSpinner.range = [0,99999,framesEndUpdate]
			)
		else ()
			
		)
	
	on framesEndSpinner changed framesEndVal do
		(
		framesEnd = framesEndVal
		--print ("End Frame: " + framesEnd as string)
			
		if (framesStart >= framesEnd) then
			(
			framesStartUpdate = (framesEnd-1)
			framesStart = framesStartUpdate
			--print framesStartUpdate
			framesStartSpinner.range = [0,99999,framesStartUpdate]
			)
		else ()
			
		)	
		
	on timeSnap pressed do
		(
		functionTimeSnap()
		)

	on processPositions pressed do
		(
		try(
		if selection.count == 1 then
			(
				lab1.text = "Status: Initalizing"
				
				disableSceneRedraw()
				obj = selection[1]
				
				-- Prepare Timeline Data
				oldAnimationRange = animationRange
				animationRange = interval framesStart FramesEnd
				oldSliderTime = sliderTime
				
				-- Prepare Save File
				saveForAEFileAnimatedName = "c:/AnimatedPositionForAE.txt"
				saveForAEFileAnimated = createfile saveForAEFileAnimatedName
				 
				-- Set Timeline for start
				sliderTime = framesStart
				totalFrames =(framesEnd-framesStart)
				currentFrame = 0
					
				------ PREPARE READER and OBJ -------
				readerPoint = point()
				
				 ----- WRITE HEADDER DATA -----
				format "%\n" headderText to:saveForAEFileAnimated
				format "%\n" (fpsText + (framerate as string)) to:saveForAEFileAnimated 
					
				headderjunk = "	Source Width	100
 	Source Height	100
 	Source Pixel Aspect Ratio	1
 	Comp Pixel Aspect Ratio	1"
					
				format "%\n" headderjunk to:saveForAEFileAnimated
					
					
				----- CLEAR CANNEL STRINGS ----------
				positionChannelString =  returnText + positionHeadderText
				scaleChannelString = returnText + positionScaleText 
				rotationZChannelString = returnText + positionRotationZText
				rotationXChannelString = returnText + positionRotationXText
				rotationYChannelString = returnText + positionRotationYText
				fovString = "\n" + fovHeaderText

				lab1.text = "Status: Baking"
					
				 ------ LOOP THROUGH FRAMERANGE ------
				 for i in framesStart to framesEnd do
					(
					currentFrameText =((currentTime as integer)/TicksPerFrame) as string
					readerPoint.transform = obj.transform
						
					if checkboxPosition.checked == true then 
						(
						curPos = parsePositionsAnimated readerPoint
						positionChannelString = positionChannelString + returnText + "	" + currentFrameText + "	" +(curPos[1] as string) + "	" +((-1 * curPos[3]) as string) + "	" +((1 * curPos[2]) as string) 
						)else()
						
					if checkboxRotation.checked == true then
						(
						curRots = parseRotationsAnimated readerPoint 
						rotationZChannelString = rotationZChannelString + returnText + "	" + currentFrameText + "	" +(curRots[1] as string)
						rotationXChannelString = rotationXChannelString + returnText + "	" + currentFrameText + "	" +(curRots[2] as string)
						rotationYChannelString = rotationYChannelString + returnText + "	" + currentFrameText + "	" +(curRots[3] as string)
						)else()
						
					if checkboxScale.checked == true then 
						(
						curScale = parseScalesAnimated readerPoint 
						scaleChannelString = scaleChannelString + returnText + "	" + currentFrameText + "	" +(curScale[1] as string) + "	" +(curScale[2] as string) + "	" +(curScale[3] as string) 
						)else()
						
					if checkboxFOV.checked then
						(
							if (iskindof obj camera) then
							(
								curFOV = parseFOV obj
								fovString = fovString + "\n" + "	" + currentFrameText + "	" + (curFOV[1] as string) 
							)
						)else()
						
					-- Update UI and i 
					sliderTime =(sliderTime+1)
					objProgress.value = 100.*currentFrame/totalFrames
					currentFrame = (currentFrame+1)
					)
					
				 -------- WRITE CREATED DATA IN PROPER ORDER ------------
				lab1.text = "Status: Writing File"
					
				if checkboxPosition.checked == true then
					(
					format "%\n" positionChannelString to:saveForAEFileAnimated	
					)else()
					
				if checkboxScale.checked == true then
					(
					format "%\n" scaleChannelString to:saveForAEFileAnimated		
					)else()
					
				if checkboxRotation.checked == true then
					(
					format "%\n" rotationZChannelString to:saveForAEFileAnimated	
					format "%\n" rotationXChannelString to:saveForAEFileAnimated	
					format "%\n" rotationYChannelString to:saveForAEFileAnimated	
					)else()
					
				if checkboxFOV.checked == true then
					(
					format "%\n" fovString to:saveForAEFileAnimated	
					)else()
					
				 ------ CREATE FOOTER DATA and WRITE FILE TO DISK-----------
				format "%\n" footerText to:saveForAEFileAnimated	
				close saveForAEFileAnimated
				 
				 -------- RESET TIMELINE and VIEWS ---------------
				delete readerPoint
				animationRange = oldAnimationRange 
				SliderTime = oldSliderTime
				redraw = on
				enableSceneRedraw()
				redrawViews()
				 
				 ------ OPEN FILE -----------
				shelllaunch "notepad.exe" saveForAEFileAnimatedName
				
			)else(messagebox"Select 1 object")
		)catch(messagebox (getcurrentexception()))
		lab1.text = "Status: Completed"
		)	

	on buttonCustomHeadder pressed do 
	(
		rollout customHeadderRollout "Set custom keframe data headder"
		(
		editText editTextHeadder width:300 height:150 text:headderText pos:[5,8]
		button acceptButton "accept" pos:[210,160]
		button cancelButton "cancel" pos:[259,160]
			
		on acceptButton pressed do
			(
			headderText = editTextHeadder.text
			try (destroydialog customHeadderRollout) catch()
			)
			
		on cancelButton pressed do 
			(
			try (destroydialog customHeadderRollout) catch()
			)
		)
		createDialog customHeadderRollout 315 185
	)
	
	on buttonCustomFooter pressed do
		(
		rollout customFooterRollout "Set custom keframe data Footer"
		(
		editText editTextFooter width:300 height:150 text:FooterText pos:[5,8]
		button acceptButton "accept" pos:[210,160]
		button cancelButton "cancel" pos:[259,160]
			
		on acceptButton pressed do
			(
			FooterText = editTextFooter.text
			try (destroydialog customFooterRollout) catch()
			)
			
		on cancelButton pressed do 
			(
			try (destroydialog customFooterRollout) catch()
			)
		)
		createDialog customFooterRollout 315 185
		)
)

-- (
-- global AETransformsExporter=newrolloutfloater "AE Transforms Exporter"  175 442 198 82
-- addrollout StaticPositionExporter AETransformsExporter
-- addrollout AnimatedPositionsExporter AETransformsExporter
-- addrollout settingsRollout AETransformsExporter
-- )

AddSubRollout MakeToolbox.theSubrollout AETransformsExporterModule