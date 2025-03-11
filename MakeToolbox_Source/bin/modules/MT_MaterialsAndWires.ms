/*
#NAME:Materials and Wires
#VERSION:1.0
#INSTRUCTIONS:
Quickly apply various materials and wirecolors to 
selected objects
http://www.makevisual.com/learning/MT_MaterialsAndWires.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.2.2012 >> Integrated into MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (3.2.2012):
--        1st version
--*****************************************************
materialsAndWiresModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout materialsAndWiresModule)catch()
-- creates the UI
rollout materialsAndWiresModule "Materials And Wires"
(
button greyItButton "Grey-It" pos:[2,2] width:80 tooltip:"Assign a grey shader and a black wire color to selected object(s)."
button randomWiresButton "Rand-Wires" pos:[82,2] width:80 tooltip:"Assign randoms wires colors to selected object(s)."

button undefineMaterialsButton "Remove materials" width:160 align:#left offset:[-11,-2] tooltip:"Remove assigned shader(s) to selected object(s)."
	
spinner distributeMaterialSpinner "" type:#integer width:35 range:[1,24,6] offset:[-98,-2] 
button distributeMaterialButton "Distribute first 6 mats." offset:[16,-21] height:16 width:126 tooltip:"Assign randoms shaders from the material editor slots to selected object(s)."
	
button wireByTypeButton "Set wirecolor by" offset:[-11,-2] width:95 align:#left tooltip:"Similiraty : EditablePoly, box, spline, sphere, etc... \n Class : Geometry, Shape, Helpers, etc..."
dropdownlist typeDropDownList "" items:#("class","similarity") offset:[82,-26] width:65
	
-- functions
function updateDistributeMaterialButton =
	(
	distributeMaterialButton.text = ("Distribute first "+(distributeMaterialSpinner.value as string)+" mats.")
	)
	
function greyItFunction =
	(
	try
		(
		if selection != undefined then
			(
			disablesceneredraw()
			-- Create new standard material, and places it in the first slot of the editor
			undo on(
			meditMaterials[1] = copy meditMaterials[2]
			meditMaterials[1] = Standardmaterial ()
			meditMaterials[1].name = "Default Grey"
				
			-- Applies the shader to the objects that you have selected
			$.material = meditMaterials[1]
			$.wirecolor = color 0 0 0
			$.showFrozenInGray = off
				
			enablesceneredraw()
			)
			)else()
		)catch(messagebox "Select the object(s) you wish to modify")
	)

function randomWiresFunction =
	(
		try
		(
			if selection != undefined then
				(
				undo on(
					for i in 1 to selection.count do
						(
						selection[i].wireColor = random (color 0 0 0) (color 255 255 255)
						)
					)
				)else()
		)catch(messagebox "Select the object(s) you wish to modify")
	)
	
function undefineMaterialsFunction =
	(
	$.material = undefined
	)

function distributeMaterialFunction =
	(
	iterationRollover = distributeMaterialSpinner.value
	global pickBagArray = #()
	pickBagTotal = selection.count
		
	for i in 1 to pickBagTotal do
		(
		newValue = i
		while newValue > iterationRollover do (newValue -= iterationRollover)
		append pickBagArray newValue
		)
		
	pickBagIteration = pickBagTotal
	for i in 1 to pickBagTotal do
		(
		randomIndex = (random 1 pickBagIteration)
		selection[i].material =  meditMaterials[pickBagArray[randomIndex]]
		deleteItem pickBagArray randomIndex
		pickBagIteration -= 1
		)
	)

function setWireByClass = 
	(
	for i in 1 to selection.count do
		(
		currentSuperClass = (superclassof selection[i])
		try(
			case currentSuperClass of 
				(
				GeometryClass: (selection[i].wirecolor = black)
				light: (selection[i].wirecolor = (color 255 229 0))
				camera: (selection[i].wirecolor = (color 87 120 204))
				helper: (selection[i].wirecolor = (color 14 255 2))
				shape: (selection[i].wirecolor = (color 0 0 83))
				spacewarps: (selection[i].wirecolor = (color 153 228 184))
				)
			)catch(selection[i].wirecolor = red)
		)
	)

function setWireBySimilar =
	(
		try
		(
			disablesceneredraw()
			undo on
			(
				macros.run "Tools" "Isolate_Selection"
				while selection.count > 0 do
					(
					macros.run "Tools" "Isolate_Selection"
					select selection[1]
					actionMan.executeAction 0 "40099" -- select similar
					$.wirecolor =  (color (random 0 255) (random 0 255) (random 0 255))
					max select invert
					)
				d = for hwnd in UIAccessor.GetPopupDialogs() where UIAccessor.GetWindowText hwnd == "Warning: Isolated Selection" do exit with hwnd
				if d != ok do UIAccessor.PressButtonByName d "Exit Isolation Mode"
			)
			enablesceneredraw()
			redrawviews()
		)catch
		(
		enablesceneredraw()
		redrawviews()
		)
	)

function setWireByPower =
	(
	)
	
-- event handlers
on distributeMaterialSpinner changed state do (updateDistributeMaterialButton())
on greyItButton pressed do (greyItFunction())
on randomWiresButton pressed do (randomWiresFunction())
on undefineMaterialsButton pressed do (undefineMaterialsFunction())
on distributeMaterialButton pressed do (distributeMaterialFunction())
on wireByTypeButton pressed do
	(
	case typeDropDownList.selection of
		(
		1: setWireByClass()
		2: setWireBySimilar()
		3: setWireByPower()
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout materialsAndWiresModule