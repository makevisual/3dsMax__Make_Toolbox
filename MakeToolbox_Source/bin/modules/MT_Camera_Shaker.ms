/*
#NAME:Camera Shaker
#VERSION:1.0
#INSTRUCTIONS:
Camera Shaker automates the 
process of adding noise controllers
to a camera, to simulate handheld camera shake,
wobble and tilt.
http://www.makevisual.com/learning/MT_Camera_Shaker.htm
#SOURCE:Tyson Ibele, tyson@tysonibele.com
#HISTORY:03.12.2012  >> Integrated to MakeToolbox	

*/


--*****************************************************
-- Tool part of the Make Toolbox
--Tyson Ibele, tysonibele@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Integrated to MakeToolbox						  
--*****************************************************
CameraShakerModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout CameraShakerModule)catch()

	
rollout CameraShakerModule ("Camera Shaker")
(
	local updateRollout	
	local objSelected
	local cam = undefined
	local lockCam = undefined
	
	
	groupbox sGroup "Selection" width:160 height:45 offset:[-10,-3]
	label camSel "[No Camera Selected]" enabled:false offset:[30, -30] align:#left
	checkbutton camLock "Lock" width:30 height:17 offset:[-5, -20] enabled: false align:#left
	
	groupbox rGroup "Rotation Controllers" width:160 height:145 offset:[-10, 7]
	listbox rotConts width:153 offset:[-7, -135] height:6
	button addRCont "Add" height:15 width:30 align:#left offset:[-5,-5]
	button remRCont "Rem" height:15 width:30 align:#left offset:[27,-20]
	button openRProp "Open Properties" height:15 width:85 align:#left offset:[59,-20]
	dropdownlist rPreset "" width:110 offset:[-5,0] items:#("  - - - presets - - -", "Light Wobble", "Heavy Wobble", "Light Jitter", "Heavy Jitter", "Light Vibrations", "Heavy Vibrations")
	button applyRPreset "Apply" width:38 offset:[57,-27] enabled:false
	
	
	on camLock changed val do
	(
		if (val) then
		(
			if isvalidnode cam then
			(
				lockCam = cam
			)else
			(
				lockCam = undefined
				objSelected undefined undefined
				
			)
		)else
		(
			lockCam = undefined
			objSelected undefined undefined
		)
	)
	on applyRPreset pressed do
	(
		
		if rPreset.selection > 1 then
		(
			
			x = 0
			y = 0
			z = 0
			freq = 0
			frac = false
			rough = 0
			n = "Noise Rotation"
			
			if rPreset.selected == "Light Wobble" then
			(
				x = .8
				y = .8
				z = .35				
				freq = .03
				n = "Light Wobble"
				
			)else if rPreset.selected == "Heavy Wobble" then
			(
				x = 6
				y = 6
				z = 2.5				
				freq = .065	
				n = "Heavy Wobble"
			)else if rPreset.selected == "Light Jitter" then
			(
				x = .3
				y = .3
				z = .2	
				freq = .015
				frac = true
				rough = .5
				n = "Light Jitter"
			)else if rPreset.selected == "Heavy Jitter" then
			(
				x = 3 
				y = 3
				z = 1
				freq = .025
				frac = true
				rough = .5
				n = "Heavy Jitter"
			)else if rPreset.selected == "Light Vibrations" then
			(
				x = .2
				y = .2
				z = .1	
				freq = .3
				frac = true
				rough = .5
				n = "Light Vibrations"
			)else if rPreset.selected == "Heavy Vibrations" then
			(
				x = 1
				y = 1
				z = .5
				frac = true
				rough = .5
				freq = .4
				n = "Heavy Vibrations"
			)
			
			if isvalidnode cam and iskindof cam camera then
			(		
				apply = querybox ("Apply '" + rPreset.selected + "' to selected Noise Rotation controller in " + cam.name + "?")
				if not apply then return false
				
				if iskindof cam.rotation.controller noise_rotation then
				(	
					cam.rotation.controller.seed = random 0 10000
					cam.rotation.controller.noise_strength =  [degtorad x, degtorad y, degtorad z]
					cam.rotation.controller.frequency = freq
					cam.rotation.controller.fractal = frac
					cam.rotation.controller.roughness = rough
				)else
				(				
					if iskindof cam.rotation.controller rotation_list then
					(					
						count = 1
						for q in 1 to cam.rotation.controller.count do
						(
							if iskindof cam.rotation.controller[q] noise_rotation then
							(
								if count == rotConts.selection then
								(
									cam.rotation.controller[q].seed = random 0 10000
									cam.rotation.controller[q].noise_strength =  [degtorad x, degtorad y, degtorad z]
									cam.rotation.controller[q].frequency = freq
									cam.rotation.controller[q].fractal = frac
									cam.rotation.controller[q].roughness = rough
									cam.rotation.controller.setName q n
									return false
								)
															
								count += 1
							)								
						)					
					)				
				)
		
			)
			
		)
		
	)
	fn changeDropdownSelection = 
	(
		if rPreset.selection <= 1 then applyRPreset.enabled = false else applyRPreset.enabled = true
			
	)
	on rPreset selected val do
	(
		changeDropdownSelection()
	)
	
	fn openRProperties = 
	(
		if rotConts.selection > 0 then
		(
			if isvalidnode cam and iskindof cam camera then
			(			
				if iskindof cam.rotation.controller noise_rotation then
				(	
					displaycontroldialog cam.rotation.controller "Properties"
				)else
				(				
					if iskindof cam.rotation.controller rotation_list then
					(					
						count = 1
						for q in 1 to cam.rotation.controller.count do
						(
							if iskindof cam.rotation.controller[q] noise_rotation then
							(
								if count == rotConts.selection then
								(
									displaycontroldialog cam.rotation.controller[q].controller "Properties"
									return false
								)
															
								count += 1
							)								
						)					
					)				
				)
		
			)
		
			updateRollout()
		)
		
	)
	on openRProp pressed do
	(
		openRProperties ()
	)
	on rotConts doubleclicked val do
	(
		openRProperties ()
	)
	on addRCont pressed do
	(
		if isvalidnode cam and iskindof cam camera then
		(	
			if not iskindof cam.rotation.controller rotation_list then
			(
				cam.rotation.controller = rotation_list()				
			)		
			
			cam.rotation.controller.available.controller = noise_rotation()
			inx = cam.rotation.controller.count
			cam.rotation.controller[inx].seed = random 0 10000
			
			updateRollout()
		)
		
	)
	on remRCont pressed do
	(
		if rotConts.selection > 0 then
		(
			if isvalidnode cam and iskindof cam camera then
			(			
				if iskindof cam.rotation.controller noise_rotation then
				(	
					cam.rotation.controller = euler_xyz()			
				)else
				(				
					if iskindof cam.rotation.controller rotation_list then
					(					
						count = 1
						for q in 1 to cam.rotation.controller.count do
						(
							if iskindof cam.rotation.controller[q] noise_rotation then
							(
								if count == rotConts.selection then
								(
									cam.rotation.controller.delete q
									return false
								)
															
								count += 1
							)								
						)					
					)				
				)
		
			)
		
			updateRollout()
		)
		
		
		
	)
	fn updateRollout =
	(
		items = #()
		rotConts.items = #()
		
		if isvalidnode lockCam and iskindof lockCam camera then
		(
			cam = lockCam
		)
		
		if isvalidnode cam and iskindof cam camera then
		(			
			if iskindof cam.rotation.controller noise_rotation then
			(	
				append items "Noise Rotation Controller"				
			)else
			(				
				if iskindof cam.rotation.controller rotation_list then
				(					
					count = 1
					for q in 1 to cam.rotation.controller.count do
					(
						if iskindof cam.rotation.controller[q] noise_rotation then
						(
							append items ("RotList [" + q as string + "]: " + (cam.rotation.controller.getname q))					
							count += 1
						)								
					)					
				)				
			)
			rotConts.items = items
		)			
		
		if items.count > 0 then
		(
			for q in 1 to CameraShakerModule.controls.count do
			(
				CameraShakerModule.controls[q].enabled = true
			)
			
		)else
		(
			for q in 1 to CameraShakerModule.controls.count do
			(
				CameraShakerModule.controls[q].enabled = false
			)
		)
		
		if isvalidnode cam and iskindof cam camera then
		(	
			addRCont.enabled = true
			sGroup.enabled = true
			camSel.enabled = true
			camSel.text = "[" + cam.name + "]"
			camlock.enabled = true
		)else
		(
			sGroup.enabled = false
			camlock.enabled = false
			camSel.text = "[No Camera Selected]"
			camlock.checked = false
			camSel.enabled = false
			
		)
		
		changeDropdownSelection()
	)
	fn objSelected ev nd=
	(
		try
		(
			cam = undefined
			items = #()
			rotConts.items = #()
			
			if selection.count <= 1 then
			(					
				cam = selection[1]
				
				updateRollout()
			)
			
			
		)catch()
	)
	

)

AddSubRollout MakeToolbox.theSubrollout CameraShakerModule

global CameraShakerCallback = undefined; gc light:true
CameraShakerCallback = NodeEventCallback mouseUp:true added:CameraShakerModule.objSelected hideChanged:CameraShakerModule.objSelected freezeChanged:CameraShakerModule.objSelected deleted:CameraShakerModule.objSelected selectionChanged:CameraShakerModule.objSelected controllerStructured:CameraShakerModule.objSelected controllerOtherEvent:CameraShakerModule.objSelected

CameraShakerModule.objSelected undefined undefined


