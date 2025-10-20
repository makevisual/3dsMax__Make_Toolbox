/*
--**********************************************************************************--
--                                                                                  --
--                                     RAYMAKER                                     --
--                                                                                  --
--**********************************************************************************--

#NAME: Raymaker
#VERSION: 1.1
#LAST UPDATED: 2025.09.29

#DESCRIPTION:
A utility to create a dynamic two-point spline (a "ray") that is bound between 
two selected objects. This is commonly used in character rigging to create visual 
indicators for things like pole vectors or look-at targets.

#INSTRUCTIONS:
Select exactly two objects in the viewport that you want to connect. Click the 
"Make Bound Ray" button. The tool will generate a line spline between the objects 
and use a Skin modifier to bind its vertices to them, ensuring it follows their 
movements.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Raymaker

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Bugfixes.

#HISTORY:
    - v1.1 (2025.09.29): Added a small bugfix to the error-catching routine.
    - v1.0 (2012.06.11): Initial integration into MakeToolbox.

--**********************************************************************************--
*/
raymakerToolModuleVer = 1.1
try(removeSubRollout MakeToolbox.theSubrollout raymakerToolModule)catch()

-- creates the UI
rollout raymakerToolModule ("Raymaker Tool " + (raymakerToolModuleVer as string))
(
	button makeRayButton "Make Bound Ray" pos:[2,4] width:160 tooltip:"Creates a spline object bound to the two objects selected." align:#left

	-- function for creating a ray between two objects
	function makeRayFunction = 
	(
		undo on
		(
 			try
			(
				if selection.count == 2 then 
				(
					disablesceneredraw()
					
					startSelection = selection as array
					curTime = sliderTime
					
					slidertime = animationrange.start 
					
					max modify mode
					
					
					p1 = startSelection[1]
					p2 = startSelection[2]

					p1t = p1.pos
					p2t = p2.pos


					newRayName = ("RAY_"+p1.name+"-to-"+p2.name)

					newRay = line pos:p1t name:newRayName wirecolor:red render_renderable:off render_displayRenderMesh:false
					addNewSpline newRay
					addKnot newRay 1 #corner #line p1t
					addKnot newRay 1 #corner #line p2t
					updateShape newRay

					newRay.parent = p1

					modPanel.setCurrentObject newRay.baseObject
					modPanel.addModToSelection (Skin ()) ui:on
					skinOps.addBone newRay.modifiers[#Skin] p1 1
					skinOps.addBone newRay.modifiers[#Skin] p2 1
					newRay.modifiers[#Skin].cross_radius = 1
						
					sliderTime = curtime 
						
					clearselection()
					select startSelection
					enablesceneredraw()
					redrawviews()
				)
				else
				(
					messagebox ("You must select exactly two objects")
				)
			
			)
			catch
			(
				--catches any errors
				messagebox "Unexpected error, please try again."
				EnableSceneRedraw()
			)
		)
	)
	-- the button
	on makeRayButton pressed do
	(
		makeRayFunction()
	)
)
AddSubRollout MakeToolbox.theSubrollout raymakerToolModule