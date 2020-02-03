/*
#NAME:Object Conformer
#VERSION:1.0
#INSTRUCTIONS:
Conform the surface mesh of one object to another.
http://www.makevisual.com/learning/MT_ObjectConformer.htm
#SOURCE:Tyson Ibele http://www.tysonibele.com
#HISTORY:03.12.2012  >> Integrated to MakeToolbox	
*/

--*****************************************************
-- Tool part of the Make Toolbox
--Tyson Ibele, tysonibele@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Integrated to MakeToolbox						  
--*****************************************************
ObjectConformerModuleVer = 01.0
try(removeSubRollout MakeToolbox.theSubrollout ObjectConformerModule)catch()

	
rollout ObjectConformerModule ("Object Conformer")
(
	local objs = #()
	local objNames = #()
	
	function objFilter obj=
	(
		for q in 1 to objs.count do
		(
			if objs[q] == obj then return false
		)
		return true
	)
	
	groupbox selGroup "Selection" width:160 height:62 offset:[-10, -3]
	pickButton getObj1 "Pick Source Object" filter:objFilter height:20 width:133 offset:[-10,-52]
	pickButton getObj2 "Pick Target Object" filter:objFilter height:20 width:133 offset:[-10,-3]
	button remObj1 "X" height:20 width:20 offset:[68,-47]
	button remObj2 "X" height:20 width:20 offset:[68,-3]
	
	groupbox radio "Conform Type" width:160 height:50 offset:[-10, 0]
	radiobuttons search_type labels:#("Closest vertex", "Closest surface") align:#center offset:[0,-40]
	
	groupbox conf "Conform Progress" width:160 height:85 offset:[-10,0]
	button doConform "[Choose 2 objects first]" height:30 offset:[0,-75] enabled:false width:153 
	checkbox newMorpher "Add morpher to source" checked:true offset:[-5,0]
	
	progressbar prog1 height:10 width:147 align:#center

	on remObj1 pressed do
	(
		objs[1] = undefined
		getObj1.text = "Pick Source Object"
		
		resettext = false
		for q in 1 to objs.count do
		(
			if objs[q] == undefined then resettext = true
		)
		if objs.count < 2 then resettext = true
			
		if resettext then (doConform.enabled = false; doConform.text = "[Choose 2 objects first]")
	)
	on remObj2 pressed do
	(
		objs[2] = undefined
		getObj2.text = "Pick Target Object"
		
		resettext = false
		for q in 1 to objs.count do
		(
			if objs[q] == undefined then resettext = true
		)
		if objs.count < 2 then resettext = true
		
		if resettext then (doConform.enabled = false; doConform.text = "[Choose 2 objects first]")
		
	)
	
	function getObj obj inx=
	(
		if obj != undefined then
		(
			if inx == 1 and objs[2] != obj then
			(
				objs[1] = obj
				objNames[1] = (if obj.name.count > 12 then (substring obj.name 1 9 + "...")else obj.name)
				getObj1.text = "Source: " + objNames[1]
				
			)else if inx == 2 and objs[1] != obj then
			(
				objs[2] = obj
				objNames[2] = (if obj.name.count > 12 then (substring obj.name 1 9 + "...")else obj.name)
				getObj2.text = "Target: " + objNames[2]
				
			)
			
			if objs[1] != undefined and objs[2] != undefined then
			(
				doConform.enabled = true
				doConform.text = "Conform Source to Target"
			)
		)
		
	)
	
	function clamp val minVal maxVal =
	(
		if val < minVal then val = minVal else if val > maxVal then val = maxVal
		return val
	)

	function closestPointOnTriangle p1 p2 p3 sourcePosition =
	(
		edge0 = p2 - p1
		edge1 = p3 - p1
		v0 = p1 - sourcePosition
		
		a = dot edge0 edge0
		b = dot edge0 edge1
		c = dot edge1 edge1
		d = dot edge0 v0
		f = dot edge1 v0
		
		det = a*c - b*b
		s = b*f - c*d
		t = b*d - a*f
		
		if (s + t < det) then
		(
			if (s < 0.0) then
			(
				if (t < 0.0) then
				(
					if (d < 0.0) then
					(
						s = clamp (-d/a as float) 0 1
						t = 0				
						
					)else
					(
						s = 0.0
						t = clamp (-f/c as float) 0 1
						
					)	
					
					
				)else
				(
					s = 0
					t = clamp (-f/c as float) 0  1				
				)	
				
				
			)else if (t < 0) then
			(
				 s = clamp (-d/a as float) 0 1 
				t = 0
			)
			else
			(
				invDet = 1.0 / det as float;
				s *= invDet
				t *= invDet
			)
		) else
		(
			if ( s < 0 ) then
			(
				tmp0 = b+d
				tmp1 = c+f
				
				if ( tmp1 > tmp0 ) then
				(
					numer = tmp1 - tmp0
					denom = a-2*b+c
					s = clamp (numer/denom as float ) 0 1 
					t = 1-s
				)
				else
				(
					t = clamp (-f/c as float ) 0 1 
					s = 0
				)
			)
			else if ( t < 0.f ) then
			(
				if ( a+d > b+f ) then
				(
					numer = c+f-b-d
					denom = a-2*b+c
					s = clamp (numer/denom as float ) 0 1 
					t = 1-s;
				)
				else
				(
					s = clamp (-f/c as float ) 0 1 
					t = 0
				)
		   )
			else
			(
				numer = c+f-b-d;
				denom = a-2*b+c;
				s = clamp (numer/denom as float) 0 1 
				t = 1.0 - s
			)
		)
		
		return p1 + s * edge0 + t * edge1
	)

	function closestVert obj sourceP =
	(
		
		dist = 100000000000
		inx = -1
		
		numV = obj.numverts 
		for q in 1 to numV do
		(
			v = getvert obj q
			dist2 = distance sourceP v
			if dist2 < dist then
			(
				dist = dist2
				inx = q
			)
		)
		
		return (getvert obj inx)
		
	)
	
	function closestPoint obj sourceP =
	(
		
		dist = 100000000000
		inx = -1
		
		numV = obj.numverts 
		
		for q in 1 to numV do
		(
			v = getvert obj q
			dist2 = distance sourceP v
			if dist2 < dist then
			(
				dist = dist2
				inx = q
			)
		)
		
		faceList = (meshop.getfacesusingvert obj inx) as array
		
		posArr = #()
		
		for q in 1 to faceList.count do
		(
			
			f = getface obj faceList[q]
						
			arr = #()
			arr[1] = getvert obj f[1]
			arr[2] = getvert obj f[2]
			arr[3] = getvert obj f[3]
			
			append posArr (closestPointOnTriangle arr[1] arr[2] arr[3] sourceP)
			
		)
		
		dist = 100000000000.0
		inx = -1


		for q in 1 to posArr.count do
		(
			dist2 = distance sourceP posArr[q]
			
			if dist2 < dist then
			(
				dist = dist2
				inx = q
			)
			
		)
		
		return posArr[inx]

	)

	on getObj1 picked obj do
	(
		getObj obj 1
	)
	
	on getObj2 picked obj do
	(
		getObj obj 2
	)
	
	
	on doConform pressed do
	(
		for q in 1 to objs.count do
		(
			if not isvalidnode objs[q] then return false
		)
		undo on
		(
			max create mode
			obj2 = snapshotasmesh objs[2]
			
			if newMorpher.checked then
			(
				obj1 = copy objs[1]
								
			)else
			(
				obj1 = objs[1]
			)
						
			converttomesh obj1

			for q in 1 to obj1.numverts do
				
			(
				if keyboard.escpressed then exit
					
				prog1.value = (q/obj1.numverts as float)*100
				
				v1 = (getvert obj1 q)
				if search_type.state == 1 then
				(
					tVert = closestVert obj2 v1
				)else
				(
					tVert = closestPoint obj2 v1 
				)
				
				setvert obj1 q tVert
				
			)
			prog1.value = 0
			select obj1
			delete obj2
			
			if newMorpher.enabled and newMorpher.checked then
			(
				addmodifier objs[1] (morpher())
				validmodifier objs[1] (morpher())
				WM3_MC_BuildFromNode objs[1].modifiers[1] 1 obj1 
				select objs[1]
				delete obj1
			)
		)
	)


)

AddSubRollout MakeToolbox.theSubrollout ObjectConformerModule