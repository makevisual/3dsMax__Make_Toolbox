/*
--**********************************************************************************--
--                                                                                  --
--                                 COLORS THINGER                                   --
--                                                                                  --
--**********************************************************************************--

#NAME: Colors Thinger
#VERSION: 1.2
#LAST UPDATED: 2025.08.11

#DESCRIPTION:
A utility to quickly change the wireframe color of selected objects using a 
predefined palette, custom colors, or an auto-coloring function for rigs.

#INSTRUCTIONS:
Select one or more objects, then click a color swatch to apply the color. The "Auto 
Rig Color" button applies colors to selected spline objects based on their position 
and hierarchy.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Colors_Thinger

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Added custom color controls and adjusted layout.

#HISTORY:
    - v1.2 (2025.08.11): Added custom color pickers and adjusted the UI layout.
    - v1.1 (2014.01.07): Added custom colors and a versioning number.
    - v1.0 (2012.03.05): Initial integration into MakeToolbox and additional colors added.
    - Initial Release (2011.05.25): First version released.

--**********************************************************************************--
*/
colorsThingerModuleVer = 01.2
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
global MT_CustomColor1 = color 50 0 0
global MT_CustomColor2 = color 0 0 50
	
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

rollout colorsThingerModule ("Colors Thinger v." + (colorsThingerModuleVer as string))
(
	button autoColorButton " Auto Rig Color " width: 106 height:25 offset:[-11,2] align:#left tooltip: "Auto color rig spline controllers if part of a hierarchy"
-- 	button customColorButton "Custom " width: 52 height:20 pos:[110,5] align:#left
	colorpicker customPick1 "" color:MT_CustomColor1 width: 31 height:10 pos:[105,-2] align:#left tooltip: "Click to select Custom Color 1"
	colorpicker customPick2 "" color:MT_CustomColor2 width: 31 height:10 pos:[132,-2] align:#left tooltip: "Click to select Custom Color 2"
	imgtag customTag1 bitmap:(bitmap 25 25 color:MT_CustomColor1) pos:[110,9] tooltip: "Custom Color 1"
	imgtag customTag2 bitmap:(bitmap 25 25 color:MT_CustomColor2) pos:[137,9] tooltip: "Custom Color 2"
	--label lab1 "C1" pos:(customPick1.pos +1)
	--label lab2 "C2" pos:(customPick2.pos +1 )
	
	imgtag redButton width:25 height:25 bitmap:MT_RedButtonBM offset:[-11,-3] across:6 tooltip: "Rig Nodes and Control Splines"
	imgtag OrangeButton width:25 height:25 bitmap:MT_OrangeButtonBM offset:[-7,-3] tooltip: "Operation Nodes and Sub Controlers"
	imgtag blueButton width:25 height:25 bitmap:MT_BlueButtonBM offset:[-3,-3] tooltip: "Global and Group Controlers"
	imgtag greenButton width:25 height:25 bitmap:MT_GreenButtonBM offset:[1,-3] tooltip: "Symmetric Controlers and Sliders"
	imgtag whiteButton width:25 height:25 bitmap:MT_WhiteButtonBM offset:[5,-3] tooltip: "Anything that you want white, really"
	imgtag blackButton width:25 height:25 bitmap:MT_BlackButtonBM offset:[9,-3] tooltip: "Geometry"

	imgtag RightButton width:79 height:25 bitmap:MT_RightButtonBM pos:[83,63] tooltip: "Right Hand Side Controlers"
	imgtag LeftButton width:79 height:25 bitmap:MT_LeftButtonBM pos:[2,63] tooltip: "Left Hand Side Controlers"
	
	label RightLabel "Right "pos:[83,63]
	label LeftLabel "Left "pos:[2,63]

	Checkbox GradientModeCheck "Apply color as gradient" offset:[0,12]--pos:[3,80]
	
	function Gradient_Color CurrentColor =
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
	on customPick1 changed new_col do
	(
		CurrentColor = MT_CustomColor1 = new_col
		customTag1.bitmap = bitmap 1 1 color:CurrentColor
		if selection.count != 0 do
		(
			if gradientModeCheck.checked == true then
			(
				Gradient_Color CurrentColor
			)
			else
			(
				$.wirecolor = CurrentColor
			)
		)
	)
	on customPick2 changed new_col do
	(
		CurrentColor = MT_CustomColor2 = new_col
		customTag2.bitmap = bitmap 1 1 color:CurrentColor
		if selection.count != 0 do
		(
			if gradientModeCheck.checked == true then
			(
				Gradient_Color CurrentColor
			)
			else
			(
				$.wirecolor = CurrentColor
			)
		)
	)
	on customTag1 mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_CustomColor1
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on customTag2 mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_CustomColor2
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on redButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorRed
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on OrangeButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorOrange
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)

			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on greenButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorGreen
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)	
	on blueButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorBlue
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on whiteButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorWhite
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on blackButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_Colorblack
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on LeftButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorLeft
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "You must select an object"
		)
	)
	on RightButton mousedown do
	(
		if selection.count != 0 then
		(
			undo on
			(
				CurrentColor = MT_ColorRight
				if gradientModeCheck.checked == true then
				(
					Gradient_Color CurrentColor
				)
				else
				(
					$.wirecolor = CurrentColor
				)
			)
		)
		else
		(
			messagebox "you must select an object"
		)
	)
	on autoColorButton pressed do
	(
		MT_SplineArray = #()
		for i in 1 to selection.count do
		(
			if (selection[i].category == #Splines) or (selection[i].category == #Shape) do
			 (
			 	join MT_SplineArray #(selection[i])
			 )
		)
		select MT_SplineArray
		for i in 1 to selection.count do
		(
			if selection[i].pos.x >= 0 do
			(
				selection[i].wirecolor = MT_ColorLeft
			)
			if selection[i].pos.x <= 0 do
			(
				selection[i].wirecolor = MT_ColorRight
			)
			if selection[i].pos.x == 0 do
			(
				selection[i].wirecolor = MT_ColorGreen
			)
			if selection[i].parent == undefined do
			(
				selection[i].wirecolor = MT_ColorBlue
			)
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout colorsThingerModule