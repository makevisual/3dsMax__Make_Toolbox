/*
--**********************************************************************************--
--                                                                                  --
--                                  EDIT PIVOTS                                  	--
--                                                                                  --
--**********************************************************************************--

#NAME: Edit Pivots
#VERSION: 1.2
#LAST UPDATED: 2025.08.12

#DESCRIPTION:
A utility to quickly edit the pivot points of selected objects. It includes options 
to center the pivot, move it to the object's base, move objects to the world origin, 
and create gimbal helper nodes.

#INSTRUCTIONS:
Select one or more objects and click the desired button to modify their pivots or 
positions. Check "Use XForm modifier" to perform pivot operations non-destructively.
For more details, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Edit_Pivots

#CREDITS:
    #Author: Aaron Dabelow (theonlyaaron@gmail.com)
    #Contributors:
        - David Almeida (david.almeida@makevisual.com): Added XForm modifier mode.

#HISTORY:
    - v1.2 (2025.08.12): Added an option to use an XForm modifier for non-destructive pivot editing.
    - v1.1 (2014.01.07): Changed the "Level Pivot" functionality to "Bottom Pivot".
    - v1.0 (2012.03.07): Initial release.

--**********************************************************************************--
*/
editPivotsModuleVer = 1.2
try (removesubrollout MakeToolbox.theSubrollout editPivotsModule) catch()

-- creates the UI
rollout editPivotsModule ("Edit Pivots v." + (editPivotsModuleVer as string))
(
	button centerOriginButton "Center Origin" pos:[2,2] width:80 tooltip:"Moves the selected object(s) to the world origin."
	button alignPivotButton "Align Origin" pos:[82,2] width:80 tooltip: "Moves the selected object(s) to the world origin and resets their rotation to zero."
	button gimbalNodeButton " Gimbal Node " offset:[-1,-3] width:160 tooltip: "Creates a Point helper for each selected object and parents the objects to it."
	group "Pivot Ops"
	(
		button bottomPivotButton "Bottom Pivot" width:74 across:2 tooltip:"Moves the pivot point to the bottom center of the object's bounding box"
		button centerPivotButton "Center Pivot" width:74 offset:[4,0] tooltip:"Moves the pivot point of each selected object to its geometric center"
		checkbox UseXFormMod_Checkbox "Use XForm modifier" offset:[12,0] tooltip:"Performs the pivot operations on an Xform modifier, like a proper ResetXForm operation"
	)
	function Pivot_on_Bottom CurrentNode PivotPos =
	(
		if UseXFormMod_Checkbox.checked then
		(
			-- add an XForm modifier to each object
			addModifier CurrentNode (XForm())
			-- Calculates the gizmo offset of the XForm modifier
			Offset = (PivotPos*(inverse(CurrentNode.transform)))
			-- Applies the offset to the gizmo of the XForm modifier
			CurrentNode.modifiers[1].gizmo.position = -Offset
			-- Moves the object the same amount of the offset value to maintain it on the same position on the scene
			move CurrentNode Offset
		)
		else
		(
			CurrentNode.pivot = PivotPos
		)
	)
	on bottomPivotButton pressed do
	(
		for obj in selection do
		(
			if obj == group then
			(
				group.pivot = [group.center.x,group.center.y,group.min.z]
			)
			else
			(
				PivotPos = [obj.center.x,obj.center.y,obj.min.z]
				Pivot_on_Bottom obj PivotPos
			)
		)
	)	
	
	on centerPivotButton pressed do
	(
		for i in 1 to selection.count do
		(
		undo on
			(
				for obj in selection do
				(
					if obj == group then
					(
						group.pivot = group.center
					)
					else
					(
						PivotPos = obj.center
						Pivot_on_Bottom obj PivotPos
					)
				)
			)
		)
	)

	on alignPivotButton pressed do
	(
		for i in 1 to selection.count do
		(
		undo on
			(
			--Aligns the objects position and rotation to the origin
			selection[i].position =  [0,0,0]
			selection[i].rotation = (quat 0 0 0 0)
			)
		)
	)		
		
	on pivotOriginButton pressed do 
	(
		try
		(
			undo on
			(	
				$.pivot = [0,0,0]
			)
		)
		catch()
	)
		
	

	on centerOriginButton pressed do
	(
		for i in 1 to selection.count do
		(
		undo on
			(
			--Aligns the objects position to the origin
			selection[i].position =  [0,0,0]
			)
		)
	)	

	on gimbalNodeButton pressed do
	(
		try
		(
			undo on
			(
			selectionVar = false
			if selection.count == 1 then(selectionVar = true)else()
			for i in 1 to selection.count do
				(
					
					-- determines the aproptriate size for the node
					bMin = (nodelocalboundingbox selection[i])[1]
					bMax = (nodelocalboundingbox selection[i])[2]
					averageEdge = ((abs (bMax.x - bMin.x)) + (abs (bMax.y - bMin.y)) + (abs (bMax.y - bMin.y)/2)/3.0)*.25
					
					-- creates the point and moves it the the correct location
					nodePoint = point centermarker:off axistripod:off cross:on Box:on size:averageEdge
					nodePoint.wirecolor = color 169 0 0
					nodePoint.transform = selection[i].transform
					nodePoint.scale = [1,1,1]
					
					-- sets the parent and sets other properties
					selection[i].parent = nodePoint
					if selectionVar == true then (select nodePoint) else()
					nodePoint.setSkinPose ()
				)
			)
		)catch(messagebox("Select Object(s)"))
	)

)
AddSubRollout MakeToolbox.theSubrollout editPivotsModule