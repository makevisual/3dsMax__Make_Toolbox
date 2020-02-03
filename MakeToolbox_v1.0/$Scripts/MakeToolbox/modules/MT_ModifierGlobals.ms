/*
#NAME:Modifier Globals
#VERSION:1.0
#INSTRUCTIONS:
Quickly turn all scene instances of a particular
modifier on or off.
http://www.makevisual.com/learning/MT_ModifierGlobals.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.12.2012 >> 1st version
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (3.2.2012):
--        1st version
--*****************************************************

try(removeSubRollout MakeToolbox.theSubrollout modifierGlobalsModule)catch()
global theCurrentModifier=#TurboSmooth

rollout modifierGlobalsModule "Modifier Globals"
(
	-- the UI
	dropdownlist theDrop items:#("Turbosmooth","Meshsmooth","Subdivide","Shell","Hair and Fur","Flex","Cloth","Push","Optimize") height:20 width:160 tooltip:"Globally overrides selected modifier." offset:[-11,-3]
	checkbox selectionCheckBox "Apply to selection only" offset:[-10,-3]
	button allModsOn "Turn On" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn on selected modifier in viewport and in renderer."
	button allModsOff "Turn Off" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in viewport and in renderer."
	button allModsViewOnly "Viewport Only" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn off selected modifier in viewport only."
	button allModsRenderOnly  "Render Only" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in renderer only."
	
	on theDrop selected i do
		(
		if i == 1 then(theCurrentModifier=#TurboSmooth)else()
		if i == 2 then(theCurrentModifier=#meshsmooth)else()
		if i == 3 then(theCurrentModifier=#subdivide)else()
		if i == 4 then(theCurrentModifier=#Shell)else()
		if i == 5 then(theCurrentModifier=#Hair_and_fur)else()
		if i == 6 then(theCurrentModifier=#Flex)else()
		if i == 7 then(theCurrentModifier=#Cloth)else()
		if i == 8 then(theCurrentModifier=#Push)else()
		if i == 9 then(theCurrentModifier=#Optimize)else()
		)
		
	--Functions
	function setModifierSelectionFunction =
	(
	if selectionCheckBox.checked == true then (modifierSelection=selection) else (modifierSelection=objects)
	)
		
	function updateCommandPanel =
	(
	setCommandPanelTaskMode #create
	setCommandPanelTaskMode #modify
	enablesceneredraw()
	redrawviews()
	)
		
	function allModsOnFunction = 
	(
		undo on
		(
			disablesceneredraw()
			if selectionCheckBox.checked == true then (modifierSelection=selection) else (modifierSelection=objects)
			
			for i in modifierSelection do try 
			(
				i.modifiers[theCurrentModifier].enabledInViews = true
				i.modifiers[theCurrentModifier].enabled = true
				i.modifiers[theCurrentModifier].enabledInRenders = true
			)
			catch ()
		)
	updateCommandPanel()
	)
	
	function allModsOffFunction = 
	(
		undo on
		(
			disablesceneredraw()
			if selectionCheckBox.checked == true then (modifierSelection=selection) else (modifierSelection=objects)
			
			for i in modifierSelection do try 
			(
				i.modifiers[theCurrentModifier].enabledInViews = false
				i.modifiers[theCurrentModifier].enabled = false
				i.modifiers[theCurrentModifier].enabledInRenders = false
			)
			catch ()
		)
	updateCommandPanel()
	)

	function allModsViewOnlyFunction = 
	(
		undo on
		(
			disablesceneredraw()
			if selectionCheckBox.checked == true then (modifierSelection=selection) else (modifierSelection=objects)
			
			for i in modifierSelection do try 
			(
				i.modifiers[theCurrentModifier].enabledInViews = true
				i.modifiers[theCurrentModifier].enabled = true
				i.modifiers[theCurrentModifier].enabledInRenders = false
			)
			catch ()
		)
	updateCommandPanel()
	)

	function allModsRenderOnlyFunction = 
	(
		undo on
		(
			disablesceneredraw()
			if selectionCheckBox.checked == true then (modifierSelection=selection) else (modifierSelection=objects)
			
			for i in modifierSelection do try 
			(
			i.modifiers[theCurrentModifier].enabledInViews = false
			i.modifiers[theCurrentModifier].enabled = true
			i.modifiers[theCurrentModifier].enabledInRenders = true
			)
			catch ()
		)
	updateCommandPanel()
	)
		
	-- event handlers
	on allModsOn pressed do(allModsOnFunction())
	on allModsOff pressed do(allModsOffFunction())
	on allModsViewOnly pressed do(allModsViewOnlyFunction())
	on allModsRenderOnly pressed do(allModsRenderOnlyFunction())
)
AddSubRollout MakeToolbox.theSubrollout modifierGlobalsModule