/*
#NAME:Colors Thinger
#VERSION:1.1
#INSTRUCTIONS:
Colors Thinger allows users to quickly change
the wireframe color of selected objects.
http://www.makevisual.com/learning/MT_ColorsThinger.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.05.2012  >> Integrated to MakeToolbox and additional colors added -ad

*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 05.25.2011 >> Release -ad
--- version 1.1 : 03.05.2012  >> Integrated to MakeToolbox
--								  and additional colors added -ad
--*****************************************************
colorsThingerModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout colorsThingerModule)catch()

(
global MT_ColorRed = color 255 0 0
global MT_ColorGreen = color 0 255 0
global MT_ColorBlue = color 0 0 255
global MT_ColorOrange = color 255 169 0
global MT_ColorWhite = color 255 255 255
global MT_ColorBlack = color 1 1 1
global MT_ColorRight = color 169 0 0
global MT_ColorLeft = color 0 112 255
	
global MT_GradientArray = #()
global MT_SplineArray = #()	
	
global MT_BlueButtonBM = bitmap 50 50 color:MT_ColorBlue
global MT_GreenButtonBM = bitmap 50 50 color:MT_ColorGreen
global MT_RedButtonBM = bitmap 50 50 color:MT_ColorRed
global MT_OrangeButtonBM = bitmap 50 50 color:MT_ColorOrange
global MT_WhiteButtonBM = bitmap 50 50 color:MT_ColorWhite
global MT_BlackButtonBM = bitmap 50 50 color:MT_ColorBlack
global MT_RightButtonBM = bitmap 50 50 color:MT_ColorRight
global MT_LeftButtonBM = bitmap 50 50 color:MT_ColorLeft
)

rollout colorsThingerModule ("Colors Thinger")
(
	button autoColorButton " Auto Rig Color " width: 160 height:20 offset:[-1,-2]
	imgtag redButton width:25 height:25 bitmap:MT_RedButtonBM pos:[3,25] tooltip: "Rig Nodes and Control Splines"
	imgtag OrangeButton width:25 height:25 bitmap:MT_OrangeButtonBM  pos:[30,25] tooltip: "Operation Nodes and Sub Controlers"
	imgtag blueButton width:25 height:25 bitmap:MT_BlueButtonBM pos:[56,25] tooltip: "Global and Group Controlers"
	imgtag greenButton width:25 height:25 bitmap:MT_GreenButtonBM pos:[83,25] tooltip: "Symmetric Controlers and Sliders"
	imgtag whiteButton width:25 height:25 bitmap:MT_WhiteButtonBM pos:[110,25] tooltip: "Anything that you want white, really"
	imgtag blackButton width:25 height:25 bitmap:MT_BlackButtonBM pos:[137,25] tooltip: "Geometry"

	imgtag RightButton width:77 height:25 bitmap:MT_RightButtonBM pos:[85,53] tooltip: "Right Hand Side Controlers"
	imgtag LeftButton width:77 height:25 bitmap:MT_LeftButtonBM pos:[3,53] tooltip: "Left Hand Side Controlers"
	
	label RightLabel "Right "pos:[85,53]
	label LeftLabel "Left "pos:[3,53]

	Checkbox GradientModeCheck "Apply color as gradient" pos:[3,80]
		
	on redButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorRed
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
	
	on greenButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorGreen
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))	
	
	on blueButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorBlue
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
		
	on OrangeButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorOrange
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)

		)
	)catch(messagebox "you must select an object"))

	on whiteButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorWhite
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
		
	on blackButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_Colorblack
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
		
	on RightButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorRight
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
		
	on LeftButton mousedown do
	(try(undo on
		(
		CurrentColor = MT_ColorLeft
		if gradientModeCheck.checked == true then
		(
		NumberOfObjects = Selection.count
		colorFloat = CurrentColor as point4
		
		colorFloatHalf = colorFloat*.5
		ColorFloatIncrement = colorFloatHalf / NumberOfObjects
		ColorFloatIncrement.w = 0
		colorFloatHalf.w = 1
		ColorFloatCurrent = ColorFloatHalf
		for i in 1 to NumberOfObjects do
			(
			ColorFloatCurrent = ColorFloatCurrent + ColorFloatIncrement
			Selection[i].wirecolor = ColorFloatCurrent
			)
		)
		else($.wirecolor = CurrentColor)
		)
	)catch(messagebox "you must select an object"))
	
	on autoColorButton pressed do
		(
		MT_SplineArray = #()
		for i in 1 to selection.count do
			(
			if selection[i].category == #Splines or selection[i].category == #Shape then (join MT_SplineArray #(selection[i]))else()
			)
		select MT_SplineArray
		for i in 1 to selection.count do
			(
			if selection[i].pos.x >= 0 then (selection[i].wirecolor = MT_ColorLeft) else ()
			if selection[i].pos.x <= 0 then (selection[i].wirecolor = MT_ColorRight) else ()
			if selection[i].pos.x == 0 then (selection[i].wirecolor = MT_ColorGreen)else ()
			if selection[i].parent == undefined then (selection[i].wirecolor = MT_ColorBlue) else ()
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout colorsThingerModule