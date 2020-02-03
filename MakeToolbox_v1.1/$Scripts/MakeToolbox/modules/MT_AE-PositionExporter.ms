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
--*****************************************************
AEPositionExporterModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout AEPositionExporterModule)catch()

global framesStart
global framesEnd
global clipboardString
global headderText
global footerText
global clipbpardString
global theAnimatedObject
global currentFrame
global totalFrames
	
theanimatedobject = "undefined"
framesStart = 0
framesEnd = 100
clipboardString = "defined"
xPosition = 1.000
yPosition = 2.000
zPosition = 3.000
currentFrame = 0
totalFrames = 100

--------------------------------------------------------------
----------------------SRING SETUP------------------------
--------------------------------------------------------------

headderText = "Adobe After Effects 8.0 Keyframe Data

	Units Per Second	24
	Source Width	1920
	Source Height	1080
	Source Pixel Aspect Ratio	1
	Comp Pixel Aspect Ratio	1

Transform Position
	Frame X pixels	Y pixels Z pixels"
returnText ="\n"
footerText = "\n End of Keyframe Data"
clipbpardString = "defined"

rollout AEPositionExporterModule ("AE Position Exporter")/* + (AEPositionExporterModuleVer as string))*/
(
	--- Static Position Exporter
	groupBox GrabGroup "Grab Static Position" width:159 height:63 offset:[-10,-5]
	button copyToClipboardStatic " Copy To Clipboard " width: 154 height:20 tooltip: "Copy selected objects position data to your clipboard to be pasted into After Effects." offset:[1,-52]
	button saveTextStatic " Save Position as .txt " width: 154 height:20 tooltip: "Save selected objects position data as a .txt file to be copied into After Effects." offset:[0,-3]
	
	on copyToClipboardStatic pressed do
		(
			if selection.count ==1 then
				(
				try(
					currentFrameText = "	"+((currentTime as integer)/TicksPerFrame) as string
				
					xPosition =((floor ($.pos.x * 1000)) / 1000)
					yPosition =((floor ($.pos.y * 1000)) / 1000)
					zPosition =((floor ($.pos.z * 1000)) / 1000)

					xPositionMod = xPosition
					yPositionMod = -zPosition
					zPositionMod = yPosition	
						
					xPositionText = "	"+xPositionMod as string
					yPositionText = "	"+yPositionMod as string
					zPositionText = "	"+zPositionMod as string	
								
					setclipboardText((headderText as string)+("")+(currentFrameText as string)+(xPositionText as string)+(yPositionText as string)+(zPositionText as string)+(footerText as string))
					print clipboardString as string
		
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
					saveForAEFileStaticName = GetSaveFileName filename:"c:/idontexist/StaticPositionForAE.txt" types:"text(*.txt)"
					if saveForAEFileStaticName != undefined then
					 (
						saveForAEFileStatic = createfile saveForAEFileStaticName
					
						currentFrameText = "	"+((currentTime as integer)/TicksPerFrame) as string
						print currentFrameText
					
						xPosition =((floor ($.pos.x * 1000)) / 1000)
						yPosition =((floor ($.pos.y * 1000)) / 1000)
						zPosition =((floor ($.pos.z * 1000)) / 1000)

						xPositionMod = xPosition
						yPositionMod = -zPosition
						zPositionMod = yPosition	
							
						xPositionText = "	"+xPositionMod as string
						yPositionText = "	"+yPositionMod as string
						zPositionText = "	"+zPositionMod as string	
									
						format "%\n" headderText to:saveForAEFileStatic
						format "%" currentFrameText to:saveForAEFileStatic
						format "%" xPositionText to:saveForAEFileStatic
						format "%" yPositionText to:saveForAEFileStatic
						format "%" zPositionText to:saveForAEFileStatic
						format "%" returnText to:saveForAEFileStatic
						format "%" footerText to:saveForAEFileStatic
						
						close saveForAEFileStatic
						edit saveForAEFileStaticName
						)
					else()	
					)
				catch(Messagebox "unexpected error")
			)
			else (Messagebox "You must select one (1) object")
		)
		
	--- Animated Position Exporter
	groupBox AnimatedPosition "Animated Position" width:159 height:170 offset:[-10,0]
	
	groupBox ObjectsGroup "Object" width:151 height:39 offset:[-5,-163]
	pickbutton loadUserDefined "Select Object" width:143 height:20 offset:[1,-29]

	groupBox framesGroup "Frames Range" width:151 height:59 offset:[-5,2]
	spinner framesStartSpinner "" range:[0,99999,0] width:60 type:#integer offset:[-74,-49]
	label SpinnerToLabel "To" offset:[1 ,-20]
	spinner framesEndSpinner range:[0,99999,100] width:60 type:#integer offset:[9,-19]
	button timeSnap "Snap to Timeline" width:143 height:20 offset:[1,-1] tooltip:"Set the current timeline start frame and end frame."
	
	groupBox Processing "Generation" width:151 height:52 offset:[-5,0]
	button processPositions "Export Animated Postition" width:143 height:20 offset:[3,-42] tooltip:"Export the object position XYZ in a text file."
	progressbar objProgress  width:142 height:10 offset:[-0,-2]
	
--------------------------------------------------------------
----------------------SCRIPT BODY------------------------
--------------------------------------------------------------

	on loadUserDefined pressed do
		(
			
		if isValidNode ladUserDefinedVar do
			(
				userDefinedFileList.items = (userDefinedFileList.items + #("B"))
			)
		)
		
	on loadUserDefined picked loadUserDefinedVar do
	(
		
		if loadUserDefinedVar != undefined then
		(
			 loadUserDefined.text = $.name
			theAnimatedObject = loadUserDefinedVar
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
			framesEndSpinner.range = [0,99999,framesEndUpdate]
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
			framesStartSpinner.range = [0,99999,framesStartUpdate]
			)
		else ()
			
		)	
		
	on timeSnap pressed do
		(
		framesStartSpinner.range = [0,99999,animationRange.start]
		framesEndSpinner.range = [0,99999,animationRange.end]
		framesStart = animationRange.start
		framesEnd = animationRange.end
		framesStartVal = framesStart
		framesEndVal = framesEnd
		print ("Start Frame: " + framesStart as string)
		print ("End Frame: " + framesEnd as string)
		)	

	on processPositions pressed do
		(
		if theanimatedobject != "undefined" then
			(
			try
				(
				disableSceneRedraw()
					
				oldAnimationRange = animationRange
				animationRange = interval framesStart FramesEnd
				
				oldSliderTime = sliderTime
				
				saveForAEFileAnimatedName = GetSaveFileName filename:"c:/idontexist/AnimatedPositionForAE.txt" types:"text(*.txt)"
				if saveForAEFileAnimatedName != undefined then
					(
					saveForAEFileAnimated = createfile saveForAEFileAnimatedName
						
					deselect
					select theanimatedobject
						
					format "%\n" headderText to:saveForAEFileAnimated
					
					sliderTime = framesStart
						
					totalFrames =(framesEnd-framesStart)
					currentFrame = 0
						
					 for i in framesStart to framesEnd do
						(
						currentFrameText = "	"+((currentTime as integer)/TicksPerFrame) as string
						print currentFrameText
					
						xPosition =((floor ($.pos.x * 1000)) / 1000)
						yPosition =((floor ($.pos.y * 1000)) / 1000)
						zPosition =((floor ($.pos.z * 1000)) / 1000)

						xPositionMod = xPosition
						yPositionMod = -zPosition
						zPositionMod = yPosition	
							
						xPositionText = "	"+xPositionMod as string
						yPositionText = "	"+yPositionMod as string
						zPositionText = "	"+zPositionMod as string	
									
						format "%" currentFrameText to:saveForAEFileAnimated
						format "%" xPositionText to:saveForAEFileAnimated
						format "%" yPositionText to:saveForAEFileAnimated
						format "%" zPositionText to:saveForAEFileAnimated
						format "%" returnText to:saveForAEFileAnimated
						
						sliderTime =(sliderTime+1)
						
						objProgress.value = 100.*currentFrame/totalFrames
						currentFrame = (currentFrame+1)
						
						)
						
					format "%" footerText to:saveForAEFileAnimated
					close saveForAEFileAnimated
					edit saveForAEFileAnimatedName
						
					objProgress.value = 0
						
					)else()
					
				animationRange = oldAnimationRange 
				SliderTime = oldSliderTime
				redraw = on
				
				theanimatedobject = "undefined"
				loadUserDefined.text = "Select Object"
				
				enableSceneRedraw()
				
				)catch(Messagebox "Script Error")
			)else(messagebox"Load object")
		)	
)
AddSubRollout MakeToolbox.theSubrollout AEPositionExporterModule