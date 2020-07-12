/*
#NAME:Edit Pivots
#VERSION:1.1
#INSTRUCTIONS:
Use this script to quickly edit the pivot
points of selected objects.
http://www.makevisual.com/learning/MT_EditPivots.htm
#SOURCE:Aaron Dabelow, theonlyaaron@gmail.com
#HISTORY:03.07.2012 >> First version
#HISTORY:01.07.2014 >> Changed level pivot to bottom out pivot
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--    - v1.0 (3.7.2012):
--        1st version
--*****************************************************
editPivotsModuleVer = 1.1
try (removesubrollout MakeToolbox.theSubrollout editPivotsModule) catch()

-- creates the UI
rollout editPivotsModule ("Edit Pivots v." + (editPivotsModuleVer as string))
(
button centerOriginButton "Center Origin" pos:[2,2] width:80
button alignPivotButton "Align Origin" pos:[82,2] width:80
button gimbalNodeButton " Gimbal Node " offset:[-1,-3] width:160
button bottomPivotButton "Bottom Pivot" pos:[2,48] width:80
button centerPivotButton "Center Pivot" pos:[82,48] width:80

on bottomPivotButton pressed do
(
	for obj in selection do
	(
		if obj == group then(
		group.pivot = [group.center.x,group.center.y,group.min.z]

		)
		else (
			obj.pivot = [obj.center.x,obj.center.y,obj.min.z]
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
	try(
		undo on(	
			$.pivot = [0,0,0]
		)
		)	catch()
)
	
on centerPivotButton pressed do
(
	for i in 1 to selection.count do
	(
	undo on
		(
		-- Sets the objects piviot to the objects center
		selection[i].pivot = selection[i].center
		)
	)
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