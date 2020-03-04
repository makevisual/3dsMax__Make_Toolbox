/*
#NAME:MT_MorpherLooper
#VERSION:
#INSTRUCTIONS:
#SOURCE:Romain Faure, rf.romainfaure@gmail.com
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Romain Faure rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--****************************************************
LooperModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout LooperModule)catch()

global LooperModule
frameStart = 0f
frameTransition = 90f
frameEnd = 100f

Fn FnTimeSnap = 
		(
		frameStart = animationRange.start
		frameEnd = animationRange.end
		frameTransition = ( animationRange.end - 10 )
		LooperModule.frameStartSpinner.value = frameStart
		LooperModule.frameEndSpinner.value = frameEnd
		LooperModule.frameTransitionSpinner.value = frameTransition
		)

Fn FnTimeSet = 
		(
		animationrange = (interval frameStart frameEnd)
		)		
		
		
Fn FnLoop =
(

		for i = 1 to selection.count do
		(
			addmodifier selection[i] (Morpher ())
			WM3_MC_BuildFromNode(execute ("$" + selection[i].name)).morpher 1 (execute ("$" + selection[i].name))
		)
	
		with animate on
	(
		for i = 1 to selection.count do
		(
			at time frameStart selection[i].modifiers[#Morpher][1].value = 0
		)
	)
	
		with animate on
	(
		for i = 1 to selection.count do
		(
			at time frameTransition selection[i].modifiers[#Morpher][1].value = 0
		)
	)
	
		with animate on
	(
		for i = 1 to selection.count do
		(
			at time (frameEnd+1) selection[i].modifiers[#Morpher][1].value = 100
		)
	)
)

rollout LooperModule "Looper"
	(
	groupBox framesGroup "Frame range" width:151 height:92 align:#left pos: [5,0]
		spinner frameStartSpinner "" range:[0,99999,0] width:70 type:#integer align:#left offset:[-2,(-1 * framesGroup.height +12)]
		spinner frameEndSpinner "" range:[0,99999,100] width:70 type:#integer offset:[4,-21]
		button timeSnap "Snap to Timeline" width: 135 height:20 align:#left offset:[0,0]
		button timeSet "Set Timeline" width: 135 height:20 align:#left offset:[0,0]
		spinner frameTransitionSpinner "Transition Start   " range:[0,99999,90] width:120 align:#left type:#integer offset:[0,10]
		button btnRun "Run Script" width:140
			
			on frameStartSpinner changed val do
		(
				frameStart = frameStartSpinner.value
		)
		
			on frameEndSpinner changed val do
		(
				frameEnd = frameEndSpinner.value
		)
		
			on frametransition changed val do
		(
				frameTransition = frameTransitionSpinner.value
		)

		on timeSnap pressed do 
		(
			FnTimeSnap()
		)
		
			on timeSet pressed do 
		(
			FnTimeSet()
			FnTimeSnap()
		)
		
		on btnRun pressed do 
		(
			if selection.count != 0 
				then 
			(
				selection as array
				
				frameStart = LooperModule.frameStartSpinner.value
				frameEnd = LooperModule.frameEndSpinner.value
				frameTransition = LooperModule.frameTransitionSpinner.value
				FnLoop()
			)
			else(print "No Selection.")
			
		)
		
	)
	
AddSubRollout MakeToolbox.theSubrollout LooperModule