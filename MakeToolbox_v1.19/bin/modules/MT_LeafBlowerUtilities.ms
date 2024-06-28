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
--*****************************************************

modifierGlobalsModuleVer = 1.0

try(removeSubRollout MakeToolbox.theSubrollout modifierGlobalsModule)catch()
global theCurrentModifier=#TurboSmooth

rollout modifierGlobalsModule ("LeafBlowerUtilities v" + (modifierGlobalsModuleVer as string))
(
	-- the UI
	dropdownlist theDrop items:#("View on | Render on", "View off | Render on", "View off | Render off") height:20 width:160 tooltip:"Set leafblower settings" offset:[-11,-3]

	button setSelection "Selection" width:79 height:20  align:#left offset:[-10,-3] 
	button setScene "Scene" width:79 height:20 align:#left offset:[69,-25] 

	on setSelection pressed do 
	(
		lb_objects = #()

		for sel in selection do 
		(
			if classof sel == leafblower 
			then ( append lb_objects sel )
			else()
		)

		for lb_object in lb_objects do 
		(
			lb_object.globals_enable = ( theDrop.selection - 1 )
		)
	)

	on setScene pressed do 
	(
		lb_objects = getclassinstances leafblower 
		for lb_object in lb_objects do 
		(
			lb_object.globals_enable = ( theDrop.selection - 1 )
		)
	)

)
AddSubRollout MakeToolbox.theSubrollout modifierGlobalsModule