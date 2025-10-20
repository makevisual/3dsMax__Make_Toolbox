/*
--**********************************************************************************--
--                                                                                  --
--                               MODIFIER GLOBALS                                 	--
--                                                                                  --
--**********************************************************************************--

#NAME: Modifier Globals
#VERSION: 1.7
#LAST UPDATED: 2025.09.12

#DESCRIPTION:
A utility to quickly turn all instances of a specific modifier on or off, either 
for the entire scene or for a selection of objects. This helps manage scene 
performance and toggle viewport/render settings.

#INSTRUCTIONS:
Select a modifier from the dropdown list. Optionally, check "Apply to selection only" 
to limit the operation to the current selection. Use the buttons to turn the modifier 
on, off, or toggle its visibility in the viewport versus the final render.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Modifier_Globals

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Script updates and maintenance.

#HISTORY:
    - v1.7 (2025.09.12): Removed deprecated modifiers, added Chamfer, and fixed tooltips.
    - v1.5 (2015.05.20): Version number update.
    - v1.4 (2015.02.09): Fixed dropdown index bug and added Displace and Quad_Chamfer modifiers.
    - v1.3 (2013.08.22): Added support for Turbosmooth Pro.
    - v1.2 (2013.06.06): Added support for the Point Cache modifier.
    - v1.1 (2012.07.31): User interface adjustments.
    - v1.0 (2012.03.12): Initial release.

--**********************************************************************************--
*/

modifierGlobalsModuleVer = 1.7

try(removeSubRollout MakeToolbox.theSubrollout modifierGlobalsModule)catch()
global theCurrentModifier=#TurboSmooth

rollout modifierGlobalsModule ("Modifier Globals v" + (modifierGlobalsModuleVer as string))
(
	-- the UI
	dropdownlist theDrop items:#("Turbosmooth","Meshsmooth","Subdivide","Shell","Hair and Fur","Flex","Cloth","Push","Optimize","Point Cache","PointCacheWSM","Chamfer","Displace","Skin") height:20 width:160 tooltip:"Globally overrides selected modifier." offset:[-11,-3]
	checkbox selectionCheckBox "Apply to selection only" offset:[-10,-3]
	button allModsOn "Turn On" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn on selected modifier in viewport and in renderer."
	button allModsOff "Turn Off" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in viewport and in renderer."
	button allModsViewOnly "Off in Render" width:79 height:20  align:#left offset:[-10,-3] tooltip:"Turn off selected modifier in renderer only."
	button allModsRenderOnly  "Off in View" width:79 height:20 align:#left offset:[69,-25] tooltip:"Turn off selected modifier in viewport only."
	
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
		if i == 12 then(theCurrentModifier=#chamfer )else()
		if i == 13 then(theCurrentModifier=#Displace )else()
		if i == 14 then(theCurrentModifier=#Skin)else()
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