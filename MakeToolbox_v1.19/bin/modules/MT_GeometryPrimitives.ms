--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.00 : 12.10.2012 >> Release -ad
--*****************************************************
geometryPrimitivesModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout geometryPrimitivesModule)catch()

rollout geometryPrimitivesModule ("Geometry Primitives v" + (geometryPrimitivesModuleVer as string))
(
button sphereBoxButton "S-Box" pos:[2,2] width:80
button quadCylinderButton "Q-Cylinder" pos:[82,2] width:80

on sphereBoxButton pressed do
	(
	with undo on
		(
		try
			(
				rcmenu createBoxPopUpMenu
				(
					--menuItem zoom "     Select Divisions     "
					menuItem oneDivisions "One Division"
					menuItem twoDivisions "Two Divisions"
			
					on oneDivisions picked do
						(
							disablesceneredraw()
							Box smooth:on length:20 width:20 height:20  mapcoords:on pos:[0,0,0] isSelected:on
							$.material = meditMaterials[1]
							modPanel.addModToSelection (meshsmooth ()) ui:on
							modPanel.addModToSelection (Spherify ()) ui:on
							$.modifiers[#MeshSmooth].iterations = 1
							$.showFrozenInGray = on
							$.wirecolor = color 0 0 0
							macros.run "Modifier Stack" "Convert_to_Poly"
							$.pivot = $.center
							enablesceneredraw()
							redrawviews()
						)
					
					on twoDivisions picked do 
						(
							disablesceneredraw()
							Box smooth:on length:20 width:20 height:20  mapcoords:on pos:[0,0,0] isSelected:on
							$.material = meditMaterials[1]
							modPanel.addModToSelection (meshsmooth ()) ui:on
							modPanel.addModToSelection (Spherify ()) ui:on
							$.modifiers[#MeshSmooth].iterations = 2
							$.showFrozenInGray = on
							$.wirecolor = color 0 0 0
							macros.run "Modifier Stack" "Convert_to_Poly"
							$.pivot = $.center
							enablesceneredraw()
							redrawviews()
						)
					)
			popUpMenu createBoxPopUpMenu
			)
			catch(enablesceneredraw();redrawviews())
		)
	)
	
on quadCylinderButton pressed do
	(
	with undo on
		(
			try
			(
				rcmenu createCylPopUpMenu
				(
					--menuItem zoom "     Select Divisions     "
					menuItem eightSides "Eight Sides"
					menuItem twelveSides "Twelve Sides"
			
					on eightSides picked do
						(
							disablesceneredraw()
							Cylinder smooth:on heightsegs:1 capsegs:1 sides:8 height:20 radius:10 mapcoords:on pos:[0,0,0] isSelected:on
							$.material = meditMaterials[1]
							$.wirecolor = color 0 0 0
							$.showFrozenInGray = on
							macros.run "Modifier Stack" "Convert_to_Poly"
							subobjectLevel = 4
							$.EditablePoly.SetSelection #Face #{9, 10}
							$.EditablePoly.buttonOp #Inset
							macros.run "Editable Polygon Object" "EPoly_Collapse"
							subobjectLevel = 2
							$.EditablePoly.SetSelection #Edge #{25, 27, 29, 31, 34, 36, 38, 40}
							$.EditablePoly.Remove ()
							subobjectLevel = 0
							enablesceneredraw()
							redrawviews()
						)
					
					on twelveSides picked do 
						(
							disablesceneredraw()
							Cylinder smooth:on heightsegs:1 capsegs:1 sides:12 height:20 radius:10 mapcoords:on pos:[0,0,0] isSelected:on
							$.material = meditMaterials[1]
							$.wirecolor = color 0 0 0
							$.showFrozenInGray = on
							macros.run "Modifier Stack" "Convert_to_Poly"
							subobjectLevel = 4
							$.EditablePoly.SetSelection #Face #{13..14}
							$.EditablePoly.buttonOp #Inset
							macros.run "Editable Polygon Object" "EPoly_Collapse"
							subobjectLevel = 2
							$.EditablePoly.SetSelection #Edge #{37, 39, 41, 43, 45, 47, 50, 52, 54, 56, 58, 60}
							$.EditablePoly.Remove ()
							subobjectLevel = 0
							enablesceneredraw()
							redrawviews()
						)
				)
			popUpMenu createCylPopUpMenu
			)catch(enablesceneredraw();redrawviews())
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout geometryPrimitivesModule