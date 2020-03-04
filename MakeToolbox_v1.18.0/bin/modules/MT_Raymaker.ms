/*
#NAME:Raymaker
#VERSION:1.0
#INSTRUCTIONS:Create and bind a spline to two objects, good for drawing pole vectors
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:06.11.2012 >> Integrated into MakeToolBox
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
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
				print startSelection

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
					
				clearselection()
				select startSelection
				enablesceneredraw()
				redrawviews()
				)
			else(messagebox ("You must select exactly two objects"))
			
			)catch
			(
			-- catches any errors
			messagebox "Unexpected error, please try again."
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