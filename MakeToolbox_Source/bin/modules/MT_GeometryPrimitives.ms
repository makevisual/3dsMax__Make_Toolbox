/*
--**********************************************************************************--
--                                                                                  --
--                             GEOMETRY PRIMITIVES                                	--
--                                                                                  --
--**********************************************************************************--

#NAME: Geometry Primitives
#VERSION: 1.1
#LAST UPDATED: 2025.08.12

#DESCRIPTION:
A utility for creating procedural geometry primitives, including a spherified box 
(S-Box) and a quad-capped cylinder (Q-Cylinder).

#INSTRUCTIONS:
Click the "S-Box" or "Q-Cylinder" button and choose the desired number of 
subdivisions from the pop-up menu to create the corresponding primitive at the 
world origin.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Geometry_Primitives

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Code modernization and bug fixes.

#HISTORY:
    - v1.1 (2025.08.12): Refactored script, improved reliability, and fixed Q-Cylinder bugs.
    - v1.0 (2012.12.10): Initial release.

--**********************************************************************************--
*/
geometryPrimitivesModuleVer = 1.0
try(removeSubRollout MakeToolbox.theSubrollout geometryPrimitivesModule)catch()

rollout geometryPrimitivesModule ("Geometry Primitives v" + (geometryPrimitivesModuleVer as string))
(
	button sphereBoxButton "S-Box" pos:[2,2] width:80
	button quadCylinderButton "Q-Cylinder" pos:[82,2] width:80
	function S_Box_Maker NumDiv =
	(
		disablesceneredraw()
		SmoothedBox = Box smooth:on length:20 width:20 height:20  mapcoords:on pos:[0,0,0]
		SmoothedBox.material = meditMaterials[1]
		addModifier SmoothedBox (meshsmooth ())
		addModifier SmoothedBox (Spherify ())
		addModifier SmoothedBox (XForm())
		SmoothedBox.modifiers[#MeshSmooth].iterations = NumDiv
		SmoothedBox.showFrozenInGray = on
		SmoothedBox.wirecolor = color 0 0 0
		SmoothedBox.modifiers[1].gizmo.position = - SmoothedBox.center
		maxOps.CollapseNode SmoothedBox true
		enablesceneredraw()
		redrawviews()
	)
	function Q_Cylinder_Maker NumSides SelFaces SelEdges =
	(
		disablesceneredraw()
		QuadCylinder = Cylinder smooth:on heightsegs:1 capsegs:1 sides:NumSides height:20 radius:10 mapcoords:on pos:[0,0,0]
		QuadCylinder.material = meditMaterials[1]
		QuadCylinder.wirecolor = color 0 0 0
		QuadCylinder.showFrozenInGray = on
		converttopoly QuadCylinder
		max modify mode
		select QuadCylinder
		subobjectLevel = 4
		QuadCylinder.EditablePoly.SetSelection #Face SelFaces
		QuadCylinder.EditablePoly.buttonOp #Inset
		QuadCylinder.EditablePoly.buttonOp #Collapse
		--macros.run "Editable Polygon Object" "EPoly_Collapse"
		subobjectLevel = 2
		QuadCylinder.EditablePoly.SetSelection #Edge SelEdges
		QuadCylinder.EditablePoly.Remove()
		subobjectLevel = 0
		max create mode
		enablesceneredraw()
		redrawviews()
	)
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
						S_Box_Maker 1
					)
					
					on twoDivisions picked do 
					(
						S_Box_Maker 2
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
						Q_Cylinder_Maker 8 #{1, 10} #{25, 27, 29, 31, 34, 36, 38, 40}
					)
					
					on twelveSides picked do 
					(
						Q_Cylinder_Maker 12 #{1,14} #{37, 39, 41, 43, 45, 47, 50, 52, 54, 56, 58, 60}
					)
				)
				popUpMenu createCylPopUpMenu
			)
			catch(enablesceneredraw();redrawviews())
		)
	)
)
AddSubRollout MakeToolbox.theSubrollout geometryPrimitivesModule