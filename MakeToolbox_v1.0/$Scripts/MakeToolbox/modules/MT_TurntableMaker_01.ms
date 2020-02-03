/*
#NAME:TurntableMaker
#VERSION:1.0
#INSTRUCTIONS:
Make a turntable.
#SOURCE:Romain Faure, rf.romainfaure@gmail.com
#HISTORY: 05.14.2012 >> Release 
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Romain Faure rf.romainfaure@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.14.2012 >> Release
--****************************************************
TurntableMakerModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout TurntableMakerModule)catch()

-- Variables 

global FnCreateTurntable

SpnStartDurationEnabled = true
SpnFrameRateEnabled = false
SpnFrameResWidthEnabled = false
SpnFrameResHeightEnabled = false
SpnFrameRateV = 24
SpnStartDurationV = 100
SpnFrameResWidthV = 1920
SpnFrameResHeightV = 1080

CkbCameraCheck = true
CkbLinkCheck = false
ChkModeCheck = false

TtCtrl = $Turntable_Controller
TtCam = $Turntable_Camera

fn FnCreateTurntable =
(
	TtCtrl = circle radius:20
	TtCtrl.name = "Turntable_Controller"
	TtCtrl.wirecolor = blue
	ObjectController = linear_rotation()
	TtCtrl.rotation.controller = ObjectController

	set animate on
	slidertime = 0f
	Key = addNewKey ObjectController 0
	rotate TtCtrl (angleaxis 0 [0,0,1])

	Key = addNewKey ObjectController SpnStartDurationV
	 
	rotate TtCtrl (angleaxis 360 [0,0,1])
	set animate off
		
	animationRange = interval 0 (SpnStartDurationV-1)
	rendTimeType = 3
	rendStart = 0
	rendEnd = (SpnStartDurationV-1)

)

fn FnCreateACamera =
(
	TtCam = Freecamera pos:[0,-200,40]
	rotate TtCam (angleaxis 90 [1,0,0])
	TtCam.wirecolor = blue
	TtCam.name = "Turntable_Camera"
)

rollout TurntableMakerModule ("TurntableMaker")
(
	groupBox GrpTOptions "Tools Options" width:160 height:58 offset:[-10,-3]
	checkbox CkbCamera "Create A Camera" offset:[0,-45] checked:CkbCameraCheck tooltip:"Create a camera."
	checkbox ChkMode "Selection Mode"  checked:ChkModeCheck tooltip:"Link every selected object(s) to the turntable."
	
	groupBox GrpSOptions "Scene Options" width:160 height:120 offset:[-10,0]
	
	checkbox ChkDuration "Set Duration" offset:[0,-108] tooltip:"Set the lenght in frames (default : 100)." checked:true
	spinner SpnStartDuration width:40 range:[0,999,SpnStartDurationV] type:#integer offset:[20,-20] enabled:SpnStartDurationEnabled

	checkbox ChkFrameRate "Set Frame Rate" tooltip:"Set the frame rate per second."
	spinner SpnFrameRate width:40 range:[0,999,SpnFrameRateV] type:#integer offset:[20,-20] enabled:SpnFrameRateEnabled

 	checkbox ChkResolution "Set Resolution" tooltip:"Set the output size."
	spinner SpnFrameResWidth width:60 range:[0,5000,SpnFrameResWidthV] type:#integer offset:[-74,0] enabled:SpnFrameResWidthEnabled
	label LbLFrameRes "x" offset:[1 ,-20]
	spinner SpnFrameResHeight width:60 range:[0,5000,SpnFrameResHeightV] type:#integer offset:[10,-19] enabled:SpnFrameResHeightEnabled
	
	button BtnCreate "Create" width:160 height:20 offset:[0,3]

	on ChkDuration changed theState do 
	(
		if SpnStartDuration.enabled == false
		then 
		(
			SpnStartDuration.enabled = true
		)
		else 
		(
			SpnStartDuration.enabled = false
		)
	)

		on ChkFrameRate changed theState do 
	(
		if SpnFrameRate.enabled  == false 
		then
		(
			SpnFrameRate.enabled  = true
		)
		else
		(
			SpnFrameRate.enabled  = false
		)
	)

		on ChkResolution changed theState do 
	(
		if SpnFrameResWidth.enabled  == false and SpnFrameResHeight.enabled == false
		then
		(
			SpnFrameResWidth.enabled  = true
			SpnFrameResHeight.enabled = true
		)
		else
		(
			SpnFrameResWidth.enabled  = false
			SpnFrameResHeight.enabled = false
		)
	)
	
	on BtnCreate pressed do 
	(
		clearUndoBuffer()
		undo on 
		(
			SpnFrameRateV = SpnFrameRate.value
			SpnStartDurationV = SpnStartDuration.value
			SpnFrameResWidthV = SpnFrameResWidth.value
			SpnFrameResHeightV = SpnFrameResHeight.value
			
			if CkbCamera.checked == true and ChkMode.checked == false
			then
			(
				FnCreateACamera()
				FnCreateTurntable()
				TtCam.parent = TtCtrl
				if ChkFrameRate.checked == true then (frameRate = SpnFrameRateV)
				if ChkResolution.checked == true 
				then 
				(
					renderWidth = SpnFrameResWidthV
					renderHeight = SpnFrameResHeightV
					renderPixelAspect = 1.00
				)
			)
		
			if ChkMode.checked == true and CkbCamera.checked == false
			then
			(
				if selection.count != 0
				then 
				(
					(	
						FnCreateTurntable()
						$.parent = TtCtrl
						if ChkFrameRate.checked == true then (frameRate = SpnFrameRateV)
						if ChkResolution.checked == true 
						then 
						(
							renderWidth = SpnFrameResWidthV
							renderHeight = SpnFrameResHeightV
							renderPixelAspect = 1.00
						)
					)	
				) 
				else
				(
					messagebox ("No object(s) selected.")
				)
			)
			
			if CkbCamera.checked == true and ChkMode.checked == true
			then 
			(
				if selection.count != 0
				then 
				(
						FnCreateACamera()
						FnCreateTurntable()
						TtCam.parent = TtCtrl
						$.parent = TtCtrl
						if ChkFrameRate.checked == true then (frameRate = SpnFrameRateV)
						if ChkResolution.checked == true 
						then 
						(
							renderWidth = SpnFrameResWidthV
							renderHeight = SpnFrameResHeightV
							renderPixelAspect = 1.00
						)
				
				)
				else
				(
					messagebox ("No object(s) selected.")
				)
			)
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout TurntableMakerModule