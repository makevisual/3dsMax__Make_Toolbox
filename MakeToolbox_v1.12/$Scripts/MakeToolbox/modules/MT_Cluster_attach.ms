/*
#NAME:Cluster Attach
#VERSION:1.1
#INSTRUCTIONS:
Cluster attach is a fast attach algorithm, 
useful for attaching large groups of objects together 
quickly. It has a much smaller memory footprint than 
built-in attach methods.
http://www.makevisual.com/learning/MT_Cluster_attach.htm
#SOURCE:Tyson Ibele, tyson@tysonibele.com
#HISTORY:03.22.2012 >> Info header added
03.12.2012 >> Integrated into MakeToolBox
*/
ClusterAttachModuleVer = 01.1
try(removeSubRollout MakeToolbox.theSubrollout ClusterAttachModule)catch()

	
rollout ClusterAttachModule ("Cluster Attach/Detach")
(
	groupBox attachGroup "Attach" width:160 height:82 offset:[-10,-3]
	button attachSel "Attach Selected" width:153 height:20 offset:[1,-72] tooltip:"Click to attach selected objects together into a single mesh" align:#center
	button attachAll "Attach All" width:153 height:20 offset:[1,-3] tooltip:"Click to attach all scene geometry together into a single mesh" align:#center
	checkbox allowUndo "Allow undo" align:#center tooltip:"This allows you to undo the operation, but will greatly increase memory overhead and slow things down."
	
	groupBox detachGroup "Detach" width:160 height:62 offset:[-10,0]
	button detachSel "Detach Selected" width:153 height:20 offset:[1, -52] tooltip:"Click to detach all elements of the selected objects" align:#center
	checkbox centerPiv "Center pivot" align:#center tooltip:"This will move the pivot of each detached object to its center"
	
	
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
						
											
					if classof objArr[j] != Editable_Poly then converttopoly objArr[j]
						
					if isvalidnode objArr[j+1] and iskindof objArr[j+1] geometryclass then
					(
						polyop.attach objArr[j] objArr[j+1]
						
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
		converttopoly node
		local detach = polyop.detachfaces

		
		while node.numfaces > 0 do
		(
			elem = polyop.getElementsUsingFace node 1
			act = detach node elem delete:on asnode:on 
			if act do 
			(			
				obj = objects[objects.count]
				if piv then centerPivot obj 
				append sel obj
			)
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
			if (not iskindof objs[q] geometryclass) then
			(
				deleteItem objs q
			)else
			(
				selArr =  (clusterDetachObjs objs[q] piv:centerPiv.checked)
				for g in 1 to selArr.Count do
				(
					append sel selArr[g]
				)
				deleteItem objs q
			)
		)
		
		if sel.count > 0 then (select sel)
			
	)
	
	on attachSel pressed do
	(
		objs = (selection as array)
		q = 1
		while q < objs.count do
		(
			if (not iskindof objs[q] geometryclass) then
			(
				deleteitem objs q
			)else
			(
				q += 1
			)
		)
		if (allowUndo.checked) then
			(
				undo on
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
		cont = querybox "This will attach ALL scene geometry together into a single mesh. Continue?" title:"Warning"
		
		if (cont) then
		(
			objs = (objects as array)
			q = 1
			while q < objs.count do
			(
				if (not iskindof objs[q] geometryclass) then
				(
					deleteitem objs q
				)else
				(
					q += 1
				)
			)
			if (allowUndo.checked) then
			(
				undo on
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