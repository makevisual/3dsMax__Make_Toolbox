/*
#NAME:NukeImport
#VERSION:1.0.0
#INSTRUCTIONS:
Bring 
http://www.makevisual.com/learning/MT_SceneUtilities.htm
#SOURCE:neil.barck@gmail.com
#HISTORY:07.10.2020 >> Add to MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
-- Created by Neil Barck

--*****************************************************
-- HISTORY:
--- version 1.00  : 07.10.2020 >> Add to MakeToolBox
--*****************************************************
NukeImportModuleVer = " 1.0.1"
try(removeSubRollout MakeToolbox.theSubrollout NukeImportModule)catch()



rollout NukeImportModule ("Nuke Import" + (NukeImportModuleVer as string))
(	
	button Btn_ImportObject "Import Object" width:160 height:20 offset:[0,-3]
	button Btn_ImportCamera "Import Camera" width:160 height:20 offset:[0,-3]


	--Return Messeage if any transform channels are missing
	fn NoClipboardDataMessage = 
	(
		message = ( "No relevent transform data found in Clipboard. Copy node directly from nuke and try again." )
		result = messageBox message 
	)
	
	--Adds transform for each frame to array while removing non-transform or non-rotation String
	fn FormatCamData rawArray outputArray = 
	(
		for value in rawArray do
		(
			value = trimright value "}"
	
			if value != "curve" then
			(
				if value != "x1000" then
				(
					if value != "i" then
					(
	
						append outputArray (value as float)
	
					)
				)
			)
		)
	)

	-- Same as above but for Focal Lenth with conversion to FOV
	fn FormatCamFocalLenth rawArray outputArray = 
	(
		for value in rawArray do
		(
			value = trimright value "}"
	
			if value != "curve" then
			(
				if value != "x1000" then
				(
					if value != "i" then
					(

						append outputArray (cameraFOV.MMtoFOV (value as float))
	
					)
				)
			)
		)
	)

	-- Checks the clipboard and returns true if "translate" and "rotate" are present anywhere in the clipboard
	fn CheckClipboardObject =
	(
		TranslateCheck = false
		RotateCheck = false
		OutputCheck = false

		clipboardInput = getclipboardText()
		clipboardInput = FilterString clipboardInput "\n"

		for items in clipboardInput do
		(
			stringcheck = filterstring items " "
			if stringCheck[1] == "translate" then
			(
				TranslateCheck = true
			)
			if stringCheck[1] == "rotate" then
			(
				RotateCheck = true
			)
		)

		if TranslateCheck == true then
		(
			if RotateCheck == true then
			(
				OutputCheck = true
			)
		)

		return OutputCheck

	)


	-- Checks the clipboard and returns true if "translate", "rotate", and "focal" are present anywhere in the clipboard
	fn CheckClipboardCamera =
	(

		TranslateCheck = false
		RotateCheck = false
		FocalCheck = false
		OutputCheck = false

		clipboardInput = getclipboardText()
		clipboardInput = FilterString clipboardInput "\n"
		for items in clipboardInput do
		(
			stringcheck = filterstring items " "
			if stringCheck[1] == "translate" then
			(
				TranslateCheck = true
			)
			if stringCheck[1] == "rotate" then
			(
				RotateCheck = true
			)
			if stringCheck[1] == "focal" then
			(
				FocalCheck = true
			)
		)

		if TranslateCheck == true then
		(
			if RotateCheck == true then
			(
				OutputCheck = true
			)
		)

		return OutputCheck

	)

	--Main Funcion for non-camera Objects
	fn ImportObject =
	(

		--get clipboard and define transform channel arrays
		clipboardInput = getclipboardText()
		clipboardInput = FilterString clipboardInput "\n"
		cam_t_x = #()
		cam_t_y = #()
		cam_t_z = #()
		cam_r_x = #()
		cam_r_y = #()
		cam_r_z = #()
		nuke_focal = #()

		--Breaks clipboard into lines and the transform and rotation lines by X, Y, And Z
		for items in clipboardInput do
		(
			stringcheck = filterstring items " "
			if stringCheck[1] == "translate" then
			(
				tempData = filterstring items "{"

				--Passes Data to be put into transform channel arrays		
				tempDataX = filterstring tempData[2] " "
				tempDataY = filterstring tempData[3] " " 
				tempDataZ = filterstring tempData[4] " " 				
		
				formatCamData tempDataX cam_t_x
				formatCamData tempDataY cam_t_y
				formatCamData tempDataZ cam_t_z
		
		
			)
		
			if stringCheck[1] == "rotate" then
			(
		
				tempData = filterstring items "{"
		
				tempDataX = filterstring tempData[2] " "
				tempDataY = filterstring tempData[3] " " 
				tempDataZ = filterstring tempData[4] " " 				
		
				formatCamData tempDataX cam_r_x
				formatCamData tempDataY cam_r_y
				formatCamData tempDataZ cam_r_z
		
			)
		)
		
		nuke_translation = #(cam_t_x, cam_t_y, cam_t_z)
		nuke_rotation = #(cam_r_x, cam_r_y, cam_r_z)
		
		
		--------------------------------------------------------

		--Creates New point object and sets scene variables
		scaleOffset = 1--2.54
		
		frameCount = cam_t_x.count
		slidertime = animationRange.start
		
		
		-- turn float into degrees
		function ftd arg = 
		(	
		
		 --	val = arg * 360
			val = arg * 1
			return val
		)
		
		newPoint = point()
		newPoint.showTrajectory = on
		newPoint.size = .24
		newPoint.wirecolor = green 
		
		set animate on
		

		--Applies transform data to new object
		for i in 1 to frameCount do 
		(
		
			newPoint.rotation = (eulerAngles  ( ((ftd cam_r_x[i]) + 90.0) * -1 ) ( -1 * ftd cam_r_y[i] ) ( -1 * ftd cam_r_z[i] )  ) as quat
		
			newPoint.position = [ ( cam_t_x[i] * scaleOffset ), (  -1 * cam_t_z[i] * scaleOffset ), ( cam_t_y[i] * scaleOffset ) ]
			slidertime += 1 
		)
		
		set animate off
	)

	--Main Funcion for non-camera Objects
	fn ImportCamera =
	(
		--get clipboard and define transform channel arrays
		clipboardInput = getclipboardText()
		clipboardInput = FilterString clipboardInput "\n"
		filmbackHold = getRendApertureWidth()

		SetRendApertureWidth 36.0

		cam_t_x = #()
		cam_t_y = #()
		cam_t_z = #()
		cam_r_x = #()
		cam_r_y = #()
		cam_r_z = #()
		nuke_focal = #()


		--Breaks clipboard into lines and the transform and rotation lines by X, Y, And Z
		for items in clipboardInput do
		(
			
			stringcheck = filterstring items " "
			if stringCheck[1] == "translate" then
			(
				tempData = filterstring items "{"
		
				--Passes Data to be put into transform channel arrays	
		
				tempDataX = filterstring tempData[2] " "
				tempDataY = filterstring tempData[3] " " 
				tempDataZ = filterstring tempData[4] " " 				
		
				formatCamData tempDataX cam_t_x
				formatCamData tempDataY cam_t_y
				formatCamData tempDataZ cam_t_z
		
		
			)
			
			if stringCheck[1] == "rotate" then
			(
		
				tempData = filterstring items "{"
		
				tempDataX = filterstring tempData[2] " "
				tempDataY = filterstring tempData[3] " " 
				tempDataZ = filterstring tempData[4] " " 				
		
				formatCamData tempDataX cam_r_x
				formatCamData tempDataY cam_r_y
				formatCamData tempDataZ cam_r_z
		
			)

			if stringCheck[1] == "focal" then
			(
		
				tempData = filterstring items "{"
		
				tempDataF = filterstring tempData[2] " "
		
				FormatCamFocalLenth tempDataF nuke_focal
		
			)
		)
		
		nuke_translation = #(cam_t_x, cam_t_y, cam_t_z)
		nuke_rotation = #(cam_r_x, cam_r_y, cam_r_z)
		
	
		--------------------------------------------------------
		--Creates New point object and sets scene variables
		scaleOffset = 1--2.54
		
		frameCount = cam_t_x.count
		slidertime = animationRange.start
		
		
		-- turn float into degrees
		function ftd arg = 
		(	
		
		 --	val = arg * 360
			val = arg * 1
			return val
		)
		
		newCamera = freecamera()
		newCamera.showTrajectory = on
	
		
		set animate on

		--Applies transform data to new object
		
		for i in 1 to frameCount do 
		(
		
			newCamera.rotation = (eulerAngles  ( ((ftd cam_r_x[i]) + 90.0) * -1 ) ( -1 * ftd cam_r_y[i] ) ( -1 * ftd cam_r_z[i] )  ) as quat
		
			newCamera.position = [ ( cam_t_x[i] * scaleOffset ), (  -1 * cam_t_z[i] * scaleOffset ), ( cam_t_y[i] * scaleOffset ) ]
	
			newCamera.fov = nuke_focal[i]

			slidertime += 1 
		)
		
		set animate off

		SetRendApertureWidth filmbackHold
	)


	on Btn_ImportObject pressed do
	(
		try(
		if CheckClipboardObject() == true then
		(
			ImportObject()
		)
		else
		(
			NoClipboardDataMessage()
		)
		)catch("error")

	)

	on Btn_ImportCamera pressed do
	(
		try(
		if CheckClipboardCamera() == true then
		(
			ImportCamera()
		)
		else
		(
			NoClipboardDataMessage()
		)
		)catch("error")

	)
	

)
AddSubRollout MakeToolbox.theSubrollout NukeImportModule

