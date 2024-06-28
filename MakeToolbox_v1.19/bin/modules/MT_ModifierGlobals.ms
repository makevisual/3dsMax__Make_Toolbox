/*
#NAME:Modifier Globals
#VERSION:1.0
#INSTRUCTIONS:
Quickly turn all scene instances of a particular
modifier on or off.
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
--    - v1.1 (7.31.2012):
--        Flipped some shit around for Kevin.
--    - v1.2 (6.6.2013):
--        Added Point Cache
--    - v1.3 (8.22.2013):
--        Added Turbosmooth pro
--    - v1.4 (2.9.2015):
--		  Added version number
--		  Fixed off index dropdown
--        Added Displace
--        Added Quad_Chamfer
--    - v1.5 (5.20.2015):
--		  Added version number
--*****************************************************

modifierGlobalsModuleVer = 1.6

try(removeSubRollout MakeToolbox.theSubrollout modifierGlobalsModule)catch()
global theCurrentModifier=#TurboSmooth

rollout modifierGlobalsModule ("Modifier Globals v" + (modifierGlobalsModuleVer as string))
(
	-- the UI
	dropdownlist theDrop items:#("Turbosmooth","Meshsmooth","Subdivide","Shell","Hair and Fur","Flex","Cloth","Push","Optimize","Point Cache","PointCacheWSM","Turbosmooth_Pro","Displace","Quad_Chamfer","Skin","MAKE Match Geo") height:20 width:160 tooltip:"Globally overrides selected modifier." offset:[-11,-3]
	checkbox selectionCheckBox "Apply to selection only" offset:[-10,-3]
	button allModsOn "Turn On" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn on selected modifier in viewport and in renderer."
	button allModsOff "Turn Off" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in viewport and in renderer."
	button allModsViewOnly "Off in Render" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn off selected modifier in viewport only."
	button allModsRenderOnly  "Off in View" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in renderer only."
	
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
		if i == 10 then(theCurrentModifier="Point Cache")else()
		if i == 11 then(theCurrentModifier=#PointCacheWSM )else()
		if i == 12 then(theCurrentModifier=#TurboSmooth_Pro )else()
		if i == 13 then(theCurrentModifier=#Displace )else()
		if i == 14 then(theCurrentModifier=#Quad_Chamfer)else()
		if i == 15 then(theCurrentModifier=#Skin)else()
		if i == 16 then(theCurrentModifier=#MAKE_Match_Geo)else()
		if i == 17 then(theCurrentModifier=#Flex)else()
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