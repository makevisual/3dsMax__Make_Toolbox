/*
--**********************************************************************************--
--                                                                                  --
--                             CLUSTER ATTACH SPLINE                              	--
--                                                                                  --
--**********************************************************************************--

#NAME: Cluster Attach Spline
#VERSION: 1.3
#LAST UPDATED: 2025.08.08

#DESCRIPTION:
A fast attach algorithm, useful for attaching large groups of spline objects together 
quickly. It has a much smaller memory footprint than built-in attach methods and can
also detach all splines from an object. This version is specifically for spline shapes.

#INSTRUCTIONS:
To attach, select the spline objects you wish to combine and click "Attach Selected",
or click "Attach All" to combine all scene splines. To detach, select an object
and click "Detach Selected".
For more details on the tool, visit: https://makevisual.com/brain/mediawiki/index.php?title=MakeToolbox_Cluster_Attach_Spline

#CREDITS:
    #Author: Tyson Ibele (tyson@tysonibele.com)
    #Contributors:
        - Aaron Dabelow (theonlyaaron@gmail.com): Integration into MakeToolbox, versioning, and bug fixes.
        - David Almeida (david.almeida@makevisual.com): Modified the tool to work with splines.

#HISTORY:
    - v1.3 (2025.08.08): Modified the core functions to work with SplineShapes instead of geometry.
    - v1.2 (2014.01.07): Now converts objects to poly before attaching to avoid instancing issues.
    - v1.1 (2012.03.22): Informational header added.
    - v1.0 (2012.03.12): Initial integration into MakeToolbox.

--**********************************************************************************--
*/
ClusterAttachSplineModuleVer = 01.2
try(removeSubRollout MakeToolbox.theSubrollout ClusterAttachModule)catch()

	
rollout ClusterAttachModule ("Cluster Attach/Detach Spline v" + (ClusterAttachSplineModuleVer as string))
(
	groupBox attachGroup "Attach" width:160 height:82 offset:[-10,-3]
	button attachSel "Attach Selected" width:153 height:20 offset:[1,-72] tooltip:"Click to attach selected splines together into a single spline" align:#center
	button attachAll "Attach All" width:153 height:20 offset:[1,-3] tooltip:"Click to attach all scene splines together into a single spline" align:#center
	checkbox allowUndo "Allow undo" align:#center tooltip:"This allows you to undo the operation, but will greatly increase memory overhead and slow things down."
	
	groupBox detachGroup "Detach" width:160 height:62 offset:[-10,0]
	button detachSel "Detach Selected" width:153 height:20 offset:[1, -52] tooltip:"Click to detach all elements of the selected splines" align:#center
	checkbox centerPiv "Center pivot" align:#center tooltip:"This will move the pivot of each detached spline to its center"
	
	
	function clusterAttachObjs objArr =
	(
		max create mode
		val = undefined
		skip = false
		if objArr == undefined then skip = true
		if objArr.count <= 0 then skip = true
			
		if skip == false then
		(			
			j = 1
			count = objArr.count
			while objArr.count > 1 do
			(
				converttosplineshape objArr[j]
				if isvalidnode objArr[j+1] and iskindof objArr[j+1] Shape then
				(
					addandweld objArr[j] (converttosplineshape objArr[j+1]) -1
				)
				deleteItem objArr (j+1)
				j += 1
				if (j + 1) > objArr.count then j = 1
			)
			val = objArr[1]
		)
		val
	)
	
	fn clusterDetachObjs node piv:false = 
	(
		local sel = #()
		max create mode
		converttosplineshape node
		--local detach = polyop.detachEdges
		for i = 1 to (numSplines node) do
		(
			CopySpline = copy node
			CopySpline.wirecolor = node.wirecolor
			for j = (numSplines node) to 1 by -1 do
			(
				if j != i do
				(
					deleteSpline CopySpline j
				)
			)
			if piv then centerPivot CopySpline
			append sel CopySpline
		)
		delete node
		sel
	)


	on detachSel pressed do
	(
		objs = (selection as array)
		q = 1
		sel = #()
		while (q <= objs.count) do
		(
			if (canConvertTo objs[q] SplineShape) then
			(
				selArr =  (clusterDetachObjs objs[q] piv:centerPiv.checked)
				for g in 1 to selArr.Count do
				(
					append sel selArr[g]
				)
				deleteItem objs q
			)
			else
			(
				deleteItem objs q
			)
		)
		if sel.count > 0 then (select sel)
		gc()
	)
	
	on attachSel pressed do
	(
		objs = (selection as array)
		q = 1
		while q < objs.count do
		(
			if (canConvertTo objs[q] SplineShape) then
			(
				q += 1
			)
			else
			(
				deleteitem objs q
			)
		)
		if (allowUndo.checked) then
		(
			undo label:"MAKE Cluster Attach Spline" on
			(	
				
				clusterAttachObjs objs
			)
		)
		else
		(
			undo off
			(	
				
				clusterAttachObjs objs
			)
			gc()
		)
	)
	
	on attachAll pressed do
	(
		cont = querybox "This will attach ALL scene splines together into a single spline. Continue?" title:"Warning"
		
		if (cont) then
		(
			objs = (objects as array)
			q = 1
			while q < objs.count do
			(
				if (canConvertTo objs[q] SplineShape) then
				(
					q += 1
				)
				else
				(
					deleteitem objs q
				)
			)
			if (allowUndo.checked) then
			(
				undo label:"MAKE Cluster Attach Spline" on
				(						
					clusterAttachObjs objs
				)
			)
			else
			(
				undo off
				(	
					
					clusterAttachObjs objs
				)
				gc()
			)
		)	
	)
	


)

AddSubRollout MakeToolbox.theSubrollout ClusterAttachModule